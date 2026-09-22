/**
 * Notify Gestione Semplificata when a MilieuAlert user registers or gets premium.
 * Uses the same shared secret as BILLING_ADMIN_KEY / MILIEUALERT_BILLING_ADMIN_KEY.
 */

const DEFAULT_GS = 'https://gestionesemplificata.com';

function gsBaseUrl() {
  const raw =
    process.env.GS_API_URL ||
    process.env.GESTIONE_SEMPLIFICATA_BASE_URL ||
    DEFAULT_GS;
  return String(raw).replace(/\/$/, '');
}

function syncKey() {
  return (
    process.env.GS_BILLING_ADMIN_KEY ||
    process.env.BILLING_ADMIN_KEY ||
    ''
  ).trim();
}

function shouldSync() {
  return Boolean(gsBaseUrl() && syncKey());
}

async function postCustomer(body) {
  if (!shouldSync()) {
    return { skipped: true, reason: 'GS sync not configured' };
  }
  const url = `${gsBaseUrl()}/api/integrations/milieualert/customer`;
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-billing-admin-key': syncKey(),
      },
      body: JSON.stringify(body),
    });
    const text = await res.text();
    let json;
    try {
      json = JSON.parse(text);
    } catch {
      json = { raw: text.slice(0, 200) };
    }
    if (!res.ok) {
      console.warn('[gsSync] HTTP', res.status, json.error || json.raw || text.slice(0, 120));
      return { ok: false, status: res.status, body: json };
    }
    return { ok: true, body: json };
  } catch (err) {
    console.warn('[gsSync] request failed:', err.message);
    return { ok: false, error: err.message };
  }
}

function fireAndForget(promise) {
  promise.catch((err) => console.warn('[gsSync]', err.message));
}

/** After in-app registration (15-day trial). */
function notifyRegistration(user) {
  if (!user?.email) return;
  fireAndForget(
    postCustomer({
      email: user.email,
      event: 'register',
      displayName: user.display_name || user.displayName || '',
      country: user.country || '',
      trialEndsAt: user.trial_ends_at || user.trialEndsAt || null,
      maUserId: user.id,
      source: 'register',
    })
  );
}

/** After Play / redeem / GS grant premium. */
function notifyPremium(user, { complimentary = false, source = 'premium' } = {}) {
  if (!user?.email) return;
  const event = complimentary ? 'comp' : 'premium';
  fireAndForget(
    postCustomer({
      email: user.email,
      event,
      displayName: user.display_name || user.displayName || '',
      country: user.country || '',
      subscriptionExpiresAt: user.subscription_expires_at || user.subscriptionExpiresAt || null,
      maUserId: user.id,
      source,
    })
  );
}

/** Backfill: sync one user row (awaitable). */
async function syncUserRow(user, { event } = {}) {
  if (!user?.email) return { skipped: true, reason: 'no email' };
  const complimentary =
    user.subscription_plan === 'comp' ||
    String(user.subscription_plan || '').toLowerCase() === 'complimentary';
  const isPremium = user.is_premium === true || user.is_premium === 't' || user.is_premium === 1;
  let ev = event;
  if (!ev) {
    if (complimentary || (isPremium && user.subscription_plan === 'comp')) ev = 'comp';
    else if (isPremium) ev = 'premium';
    else ev = 'register';
  }
  return postCustomer({
    email: user.email,
    event: ev,
    displayName: user.display_name || '',
    country: user.country || '',
    trialEndsAt: user.trial_ends_at || null,
    subscriptionExpiresAt: user.subscription_expires_at || null,
    maUserId: user.id,
    source: 'backfill',
  });
}

module.exports = {
  notifyRegistration,
  notifyPremium,
  syncUserRow,
  postCustomer,
  shouldSync,
};
