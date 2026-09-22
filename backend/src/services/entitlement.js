/**
 * Freemium entitlement for MilieuAlert.
 *
 * Trial: 15 days from first account register OR first app open
 * (trial_started_at on the user row + client prefs). After that,
 * unpaid users keep only the basic navigator unless premium / complimentary.
 *
 * Play / GS product: milieualert_premium_2_99 — €2.99 / month subscription.
 */

const TRIAL_DAYS = 15;
const PREMIUM_PRICE_EUR = '2.99';
const PLAY_PRODUCT_ID = 'milieualert_premium_2_99';
const GS_CHECKOUT_URL = 'https://gestionesemplificata.com/prodotti#milieualert';

const COMPLIMENTARY_PLANS = new Set([
  'staff',
  'comp',
  'complimentary',
  'business',
  'admin',
]);

const DEFAULT_COMPLIMENTARY_EMAILS = [
  'admin@gestionesemplificata.com',
  'assistenza@gestionesemplificata.com',
  'info@gestionesemplificata.com',
  'francibasile603@gmail.com',
];

const COMPLIMENTARY_NAME_RE =
  /giancarlo\s+borzi|roberto\s+dasso|francesco\s+basile|\bborzi\b|\bdasso\b/i;

function extraComplimentaryEmails() {
  const raw = process.env.COMPLIMENTARY_EMAILS || '';
  return raw
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);
}

function complimentaryEmailSet() {
  return new Set(
    [...DEFAULT_COMPLIMENTARY_EMAILS, ...extraComplimentaryEmails()].map((e) =>
      e.toLowerCase()
    )
  );
}

function parseDate(value) {
  if (!value) return null;
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) return null;
  return d;
}

function addDays(date, days) {
  return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
}

function isComplimentary(user) {
  if (!user) return false;
  const email = String(user.email || '').trim().toLowerCase();
  if (email && complimentaryEmailSet().has(email)) return true;
  const plan = String(user.subscription_plan || '').trim().toLowerCase();
  if (COMPLIMENTARY_PLANS.has(plan)) return true;
  const name = String(user.display_name || '').trim();
  if (name && COMPLIMENTARY_NAME_RE.test(name)) return true;
  if (email && (email.startsWith('admin@') || /borzi|dasso|francibasile/.test(email))) {
    return true;
  }
  return false;
}

function isPremiumFlag(user, now = new Date()) {
  if (!user) return false;
  if (user.is_premium === true || user.is_premium === 't' || user.is_premium === 1) {
    const expires = parseDate(user.subscription_expires_at);
    if (!expires) return true;
    return expires.getTime() > now.getTime();
  }
  const plan = String(user.subscription_plan || '').trim().toLowerCase();
  if (['pro', 'premium', 'paid'].includes(plan)) {
    const expires = parseDate(user.subscription_expires_at);
    if (!expires) return true;
    return expires.getTime() > now.getTime();
  }
  return false;
}

/**
 * Pure entitlement from a user row (no DB writes).
 */
function computeEntitlement(user, now = new Date()) {
  const complimentary = isComplimentary(user);
  const premium = complimentary || isPremiumFlag(user, now);
  const trialStartedAt = parseDate(user && user.trial_started_at);
  const trialEndsAt =
    parseDate(user && user.trial_ends_at) ||
    (trialStartedAt ? addDays(trialStartedAt, TRIAL_DAYS) : null);
  const trialActive =
    !premium && !!trialEndsAt && now.getTime() < trialEndsAt.getTime();
  const navigatorOnly = !premium && !trialActive;

  return {
    trialActive,
    trialStartedAt: trialStartedAt ? trialStartedAt.toISOString() : null,
    trialEndsAt: trialEndsAt ? trialEndsAt.toISOString() : null,
    premium,
    complimentary,
    navigatorOnly,
    plan: complimentary
      ? (user.subscription_plan || 'comp')
      : premium
        ? (user.subscription_plan || 'pro')
        : trialActive
          ? 'trial'
          : 'navigator',
    priceEur: PREMIUM_PRICE_EUR,
    playProductId: PLAY_PRODUCT_ID,
    gsCheckoutUrl: GS_CHECKOUT_URL,
    trialDays: TRIAL_DAYS,
  };
}

function pickTrialStart({ createdAt, clientStartedAt, now = new Date() }) {
  const candidates = [parseDate(createdAt), parseDate(clientStartedAt), now].filter(
    Boolean
  );
  return candidates.reduce((earliest, d) =>
    d.getTime() < earliest.getTime() ? d : earliest
  );
}

function serializeUser(user, entitlement) {
  if (!user) return user;
  const {
    password_hash, // eslint-disable-line camelcase
    ...safe
  } = user;
  return {
    ...safe,
    entitlement,
  };
}

module.exports = {
  TRIAL_DAYS,
  PREMIUM_PRICE_EUR,
  PLAY_PRODUCT_ID,
  GS_CHECKOUT_URL,
  COMPLIMENTARY_PLANS,
  DEFAULT_COMPLIMENTARY_EMAILS,
  isComplimentary,
  isPremiumFlag,
  computeEntitlement,
  pickTrialStart,
  addDays,
  parseDate,
  serializeUser,
};
