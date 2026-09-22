const express = require('express');
const pool = require('../db/pool');
const { authenticateToken } = require('../middleware/auth');
const {
  PLAY_PRODUCT_ID,
  PREMIUM_PRICE_EUR,
  GS_CHECKOUT_URL,
  computeEntitlement,
  serializeUser,
} = require('../services/entitlement');
const { attachEntitlement } = require('../services/trialStore');
const { requireBillingAdminKey } = require('../middleware/billingAdmin');

const router = express.Router();

const PROFILE_COLUMNS = `id, email, display_name, phone, preferred_language, country,
              is_premium, subscription_plan, subscription_expires_at,
              marketing_consent, data_processing_consent, created_at,
              last_active_at, referral_code, trial_started_at, trial_ends_at`;

function redeemCodes() {
  const raw = process.env.PREMIUM_REDEEM_CODES || '';
  return new Set(
    raw
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean)
  );
}

async function loadUser(id) {
  const result = await pool.query(
    `SELECT ${PROFILE_COLUMNS} FROM users WHERE id = $1`,
    [id]
  );
  return result.rows[0] || null;
}

async function grantPremium(userId, { plan = 'pro', days = 31, source } = {}) {
  const expires = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
  await pool.query(
    `UPDATE users SET
       is_premium = TRUE,
       subscription_plan = $1,
       subscription_expires_at = $2,
       last_active_at = NOW()
     WHERE id = $3`,
    [plan, expires, userId]
  );
  return { expires, source, plan };
}

async function respondUser(res, userId) {
  const user = await loadUser(userId);
  if (!user) return res.status(404).json({ error: 'User not found' });
  const withTrial = await attachEntitlement(user);
  const entitlement = computeEntitlement(withTrial);
  return res.json({
    ...serializeUser(withTrial, entitlement),
    user: serializeUser(withTrial, entitlement),
    entitlement,
  });
}

router.get('/catalog', (_req, res) => {
  res.json({
    productId: PLAY_PRODUCT_ID,
    priceEur: PREMIUM_PRICE_EUR,
    billing: 'monthly',
    gsCheckoutUrl: GS_CHECKOUT_URL,
    trialDays: 15,
  });
});

router.post('/play', authenticateToken, async (req, res) => {
  try {
    const productId = String(req.body?.productId || '').trim();
    const purchaseToken = String(req.body?.purchaseToken || '').trim();
    if (productId && productId !== PLAY_PRODUCT_ID) {
      return res.status(400).json({
        error: `Unknown product. Expected ${PLAY_PRODUCT_ID}`,
      });
    }
    if (!purchaseToken && process.env.NODE_ENV === 'production') {
      // Token is still required in production so a random client cannot
      // flip premium. Play Console product verification (Google Play
      // Developer API) is the follow-up once the subscription exists.
      return res.status(400).json({ error: 'purchaseToken required' });
    }
    await grantPremium(req.user.id, { source: 'play', days: 31 });
    return respondUser(res, req.user.id);
  } catch (err) {
    console.error('Play billing error:', err);
    res.status(500).json({ error: 'Could not activate Play purchase' });
  }
});

router.post('/redeem', authenticateToken, async (req, res) => {
  try {
    const code = String(req.body?.code || '').trim();
    if (!code) return res.status(400).json({ error: 'Code required' });
    const allowed = redeemCodes();
    const adminKey = process.env.BILLING_ADMIN_KEY || '';
    const ok =
      (allowed.size > 0 && allowed.has(code)) ||
      (adminKey && code === adminKey);
    if (!ok) {
      return res.status(403).json({ error: 'Invalid code' });
    }
    await grantPremium(req.user.id, { source: 'redeem', days: 365 });
    return respondUser(res, req.user.id);
  } catch (err) {
    console.error('Redeem error:', err);
    res.status(500).json({ error: 'Could not redeem code' });
  }
});

router.post('/grant', requireBillingAdminKey, async (req, res) => {
  try {
    const email = String(req.body?.email || '').trim().toLowerCase();
    if (!email) return res.status(400).json({ error: 'Email required' });
    const found = await pool.query(
      'SELECT id FROM users WHERE LOWER(email) = $1',
      [email]
    );
    if (found.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    const plan = req.body?.plan === 'comp' ? 'comp' : 'pro';
    await grantPremium(found.rows[0].id, {
      plan,
      days: plan === 'comp' ? 3650 : 31,
      source: 'gs-admin',
    });
    return respondUser(res, found.rows[0].id);
  } catch (err) {
    console.error('Grant error:', err);
    res.status(500).json({ error: 'Could not grant premium' });
  }
});

module.exports = router;
