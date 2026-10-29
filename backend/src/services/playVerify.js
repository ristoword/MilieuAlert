/**
 * Google Play subscription verification (Play Developer API, subscriptionsv2).
 *
 * Env:
 *   GOOGLE_PLAY_SERVICE_ACCOUNT_JSON  service-account key (raw JSON or base64)
 *   ANDROID_PACKAGE_NAME              defaults to com.milieuzone.milieu_alert
 *
 * The service account must be invited in Play Console (Users and permissions)
 * with "View financial data" + "Manage orders and subscriptions".
 */

const jwt = require('jsonwebtoken');

const PACKAGE_NAME =
  process.env.ANDROID_PACKAGE_NAME || 'com.milieuzone.milieu_alert';
const SCOPE = 'https://www.googleapis.com/auth/androidpublisher';
const API = 'https://androidpublisher.googleapis.com/androidpublisher/v3';

const ACTIVE_STATES = new Set([
  'SUBSCRIPTION_STATE_ACTIVE',
  'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
]);

let cachedToken = null;

function serviceAccount() {
  const raw = (process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON || '').trim();
  if (!raw) return null;
  try {
    const text = raw.startsWith('{')
      ? raw
      : Buffer.from(raw, 'base64').toString('utf8');
    const json = JSON.parse(text);
    if (!json.client_email || !json.private_key) return null;
    return json;
  } catch (_) {
    return null;
  }
}

function isConfigured() {
  return serviceAccount() !== null;
}

async function accessToken() {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.value;
  }
  const sa = serviceAccount();
  if (!sa) throw new Error('Play service account not configured');
  const now = Math.floor(Date.now() / 1000);
  const assertion = jwt.sign(
    {
      iss: sa.client_email,
      scope: SCOPE,
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + 3600,
    },
    sa.private_key,
    { algorithm: 'RS256' }
  );
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  if (!res.ok) throw new Error(`Google OAuth failed: ${res.status}`);
  const data = await res.json();
  cachedToken = {
    value: data.access_token,
    expiresAt: Date.now() + (data.expires_in || 3600) * 1000,
  };
  return cachedToken.value;
}

/**
 * Pure check of a subscriptionsv2 response. Returns
 * { active, expiresAt, needsAck } for [productId].
 */
function evaluateSubscription(sub, productId, now = new Date()) {
  if (!sub || typeof sub !== 'object') {
    return { active: false, expiresAt: null, needsAck: false };
  }
  const items = Array.isArray(sub.lineItems) ? sub.lineItems : [];
  let expiresAt = null;
  for (const item of items) {
    if (item.productId !== productId) continue;
    const d = item.expiryTime ? new Date(item.expiryTime) : null;
    if (d && !Number.isNaN(d.getTime()) && (!expiresAt || d > expiresAt)) {
      expiresAt = d;
    }
  }
  const active =
    ACTIVE_STATES.has(sub.subscriptionState) &&
    !!expiresAt &&
    expiresAt.getTime() > now.getTime();
  const needsAck =
    sub.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING';
  return { active, expiresAt, needsAck };
}

async function fetchSubscription(purchaseToken) {
  const token = await accessToken();
  const url = `${API}/applications/${encodeURIComponent(
    PACKAGE_NAME
  )}/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (res.status === 404 || res.status === 400 || res.status === 410) {
    return null;
  }
  if (!res.ok) throw new Error(`Play API error: ${res.status}`);
  return res.json();
}

async function acknowledge(productId, purchaseToken) {
  const token = await accessToken();
  const url = `${API}/applications/${encodeURIComponent(
    PACKAGE_NAME
  )}/purchases/subscriptions/${encodeURIComponent(
    productId
  )}/tokens/${encodeURIComponent(purchaseToken)}:acknowledge`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: '{}',
  });
  if (!res.ok && res.status !== 400) {
    throw new Error(`Play acknowledge failed: ${res.status}`);
  }
}

/**
 * Verifies [purchaseToken] with Google and acknowledges it when needed.
 * Returns { active, expiresAt } or null when Google does not know the token.
 */
async function verifySubscription(productId, purchaseToken) {
  const sub = await fetchSubscription(purchaseToken);
  if (!sub) return null;
  const result = evaluateSubscription(sub, productId);
  if (result.active && result.needsAck) {
    try {
      await acknowledge(productId, purchaseToken);
    } catch (err) {
      // The app also acknowledges via completePurchase; log and continue.
      console.error('Play acknowledge error:', err.message);
    }
  }
  return { active: result.active, expiresAt: result.expiresAt };
}

module.exports = {
  PACKAGE_NAME,
  isConfigured,
  evaluateSubscription,
  verifySubscription,
};
