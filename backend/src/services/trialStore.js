const pool = require('../db/pool');
const {
  TRIAL_DAYS,
  addDays,
  pickTrialStart,
  computeEntitlement,
  parseDate,
} = require('./entitlement');

const PROFILE_COLUMNS = `id, email, display_name, phone, preferred_language, country,
              is_premium, subscription_plan, subscription_expires_at,
              marketing_consent, data_processing_consent, created_at,
              last_active_at, referral_code, trial_started_at, trial_ends_at`;

async function attachEntitlement(user, clientStartedAt) {
  if (!user) return user;
  if (user.trial_started_at) {
    if (!user.trial_ends_at) {
      const start = parseDate(user.trial_started_at);
      const ends = addDays(start, TRIAL_DAYS);
      await pool.query(
        'UPDATE users SET trial_ends_at = $1 WHERE id = $2 AND trial_ends_at IS NULL',
        [ends, user.id]
      );
      user.trial_ends_at = ends;
    }
    return user;
  }

  const start = pickTrialStart({
    createdAt: user.created_at,
    clientStartedAt,
    now: new Date(),
  });
  const ends = addDays(start, TRIAL_DAYS);
  await pool.query(
    `UPDATE users SET
       trial_started_at = COALESCE(trial_started_at, $1),
       trial_ends_at = COALESCE(trial_ends_at, $2)
     WHERE id = $3
     RETURNING trial_started_at, trial_ends_at`,
    [start, ends, user.id]
  );
  user.trial_started_at = user.trial_started_at || start;
  user.trial_ends_at = user.trial_ends_at || ends;
  return user;
}

async function loadUserWithEntitlement(userId, clientStartedAt) {
  const result = await pool.query(
    `SELECT ${PROFILE_COLUMNS} FROM users WHERE id = $1`,
    [userId]
  );
  if (result.rows.length === 0) return null;
  const user = await attachEntitlement(result.rows[0], clientStartedAt);
  user.entitlement = computeEntitlement(user);
  return user;
}

function clientTrialHeader(req) {
  return (
    req.get('x-trial-started-at') ||
    (req.body && req.body.trial_started_at) ||
    (req.query && req.query.trial_started_at) ||
    null
  );
}

module.exports = {
  PROFILE_COLUMNS,
  attachEntitlement,
  loadUserWithEntitlement,
  clientTrialHeader,
};
