const express = require('express');
const bcrypt = require('bcryptjs');
const pool = require('../db/pool');
const { requireBillingAdminKey } = require('../middleware/billingAdmin');
const { computeEntitlement, addDays } = require('../services/entitlement');
const { PROFILE_COLUMNS } = require('../services/trialStore');
const { notifyRegistration } = require('../services/gsSync');

const MIN_PASSWORD_LENGTH = 8;

function validatePassword(password) {
  if (typeof password !== 'string' || password.length < MIN_PASSWORD_LENGTH) {
    return `Password must be at least ${MIN_PASSWORD_LENGTH} characters`;
  }
  return null;
}

const router = express.Router();

router.use(requireBillingAdminKey);

function mapUserRow(row) {
  const entitlement = computeEntitlement(row);
  return {
    id: row.id,
    email: row.email,
    displayName: row.display_name || null,
    country: row.country || null,
    preferredLanguage: row.preferred_language || null,
    plan: entitlement.plan,
    premium: entitlement.premium,
    complimentary: entitlement.complimentary,
    trialActive: entitlement.trialActive,
    trialEndsAt: entitlement.trialEndsAt,
    subscriptionPlan: row.subscription_plan || null,
    subscriptionExpiresAt: row.subscription_expires_at || null,
    createdAt: row.created_at,
    lastActiveAt: row.last_active_at || null,
  };
}

/**
 * List in-app MilieuAlert accounts (not Google Play anonymous installs).
 * Protected by BILLING_ADMIN_KEY — same secret GS uses for /api/billing/grant.
 */
router.get('/users', async (req, res) => {
  try {
    const limitRaw = parseInt(String(req.query.limit || '200'), 10);
    const offsetRaw = parseInt(String(req.query.offset || '0'), 10);
    const limit = Math.min(Math.max(Number.isFinite(limitRaw) ? limitRaw : 200, 1), 500);
    const offset = Math.max(Number.isFinite(offsetRaw) ? offsetRaw : 0, 0);
    const q = String(req.query.q || '').trim().toLowerCase();

    let where = '';
    const params = [];
    if (q) {
      params.push(`%${q}%`);
      where = `WHERE LOWER(email) LIKE $1 OR LOWER(COALESCE(display_name, '')) LIKE $1`;
    }

    const countResult = await pool.query(
      `SELECT COUNT(*)::int AS total FROM users ${where}`,
      params
    );
    const total = countResult.rows[0]?.total ?? 0;

    const listParams = [...params, limit, offset];
    const limitIdx = params.length + 1;
    const offsetIdx = params.length + 2;
    const listResult = await pool.query(
      `SELECT ${PROFILE_COLUMNS}
       FROM users
       ${where}
       ORDER BY created_at DESC
       LIMIT $${limitIdx} OFFSET $${offsetIdx}`,
      listParams
    );

    res.json({
      source: 'milieualert-in-app-registrations',
      disclaimer:
        'Named accounts from MilieuAlert sign-up only. Google Play does not expose individual downloaders for free apps.',
      total,
      limit,
      offset,
      users: listResult.rows.map(mapUserRow),
    });
  } catch (err) {
    console.error('Admin users list error:', err);
    res.status(500).json({ error: 'Could not list users' });
  }
});

/**
 * Create an in-app account on behalf of a customer (same 15-day trial as /api/auth/register).
 */
router.post('/users', async (req, res) => {
  try {
    const email = String(req.body?.email || '').trim().toLowerCase();
    const { password, display_name, country, preferred_language } = req.body || {};
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ error: 'Valid email is required' });
    }
    const passwordError = validatePassword(password);
    if (passwordError) return res.status(400).json({ error: passwordError });

    const existing = await pool.query('SELECT id FROM users WHERE LOWER(email) = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    const password_hash = await bcrypt.hash(password, 12);
    const referral_code = 'MA' + Math.random().toString(36).substring(2, 10).toUpperCase();
    const trialStart = new Date();
    const result = await pool.query(
      `INSERT INTO users (
         email, password_hash, display_name, preferred_language, country, referral_code,
         trial_started_at, trial_ends_at
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING ${PROFILE_COLUMNS}`,
      [
        email,
        password_hash,
        display_name || null,
        preferred_language || 'it',
        country || null,
        referral_code,
        trialStart,
        addDays(trialStart, 15),
      ]
    );

    const user = result.rows[0];
    notifyRegistration(user);
    res.status(201).json({ user: mapUserRow(user) });
  } catch (err) {
    console.error('Admin create user error:', err);
    res.status(500).json({ error: 'Could not create user' });
  }
});

/** Set a new password chosen by the admin (MilieuAlert has no self-service reset flow). */
router.post('/users/:id/password', async (req, res) => {
  try {
    const passwordError = validatePassword(req.body?.password);
    if (passwordError) return res.status(400).json({ error: passwordError });

    const password_hash = await bcrypt.hash(req.body.password, 12);
    const result = await pool.query(
      'UPDATE users SET password_hash = $1 WHERE id = $2 RETURNING id, email',
      [password_hash, req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ success: true, id: result.rows[0].id, email: result.rows[0].email });
  } catch (err) {
    console.error('Admin set password error:', err);
    res.status(500).json({ error: 'Could not update password' });
  }
});

module.exports = router;
