const express = require('express');
const pool = require('../db/pool');
const { requireBillingAdminKey } = require('../middleware/billingAdmin');
const { computeEntitlement } = require('../services/entitlement');
const { PROFILE_COLUMNS } = require('../services/trialStore');

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

module.exports = router;
