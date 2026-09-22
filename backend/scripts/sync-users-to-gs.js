#!/usr/bin/env node
/**
 * One-shot: push all MilieuAlert users to GS (clienti + licenze).
 * Usage (from backend/): node scripts/sync-users-to-gs.js
 * Requires DATABASE_URL, BILLING_ADMIN_KEY (or GS_BILLING_ADMIN_KEY), GS_API_URL optional.
 */
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const pool = require('../src/db/pool');
const { syncUserRow, shouldSync } = require('../src/services/gsSync');
const { computeEntitlement } = require('../src/services/entitlement');

const SKIP_COMP_STEFANO = /stefano/i;

async function main() {
  if (!shouldSync()) {
    console.error('Configure GS_API_URL and BILLING_ADMIN_KEY (or GS_BILLING_ADMIN_KEY).');
    process.exit(1);
  }
  const { rows } = await pool.query(
    `SELECT id, email, display_name, country, is_premium, subscription_plan,
            subscription_expires_at, trial_ends_at, created_at
     FROM users ORDER BY created_at ASC`
  );
  let ok = 0;
  let fail = 0;
  for (const row of rows) {
    const ent = computeEntitlement(row);
    if (ent.complimentary && SKIP_COMP_STEFANO.test(row.email || '') && SKIP_COMP_STEFANO.test(row.display_name || '')) {
      console.log('skip comp auto-sync stefano:', row.email);
      continue;
    }
    const result = await syncUserRow(row);
    if (result.ok) {
      ok += 1;
      console.log('synced', row.email, result.body?.data?.license?.kind || '');
    } else {
      fail += 1;
      console.warn('failed', row.email, result.status || result.error);
    }
  }
  console.log(`Done. ok=${ok} fail=${fail} total=${rows.length}`);
  await pool.end();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
