#!/usr/bin/env node
/** One-off: list users by email pattern (argv: SQL LIKE patterns). */
require('dotenv').config();
const pool = require('../src/db/pool');

async function main() {
  const patterns = process.argv.slice(2);
  if (patterns.length === 0) {
    console.error('Usage: node find-user-by-email.js <like-pattern> ...');
    process.exit(1);
  }
  const clauses = patterns.map((_, i) => `LOWER(email) LIKE $${i + 1}`);
  const sql = `SELECT id, email, display_name, is_premium, subscription_plan, created_at
    FROM users WHERE ${clauses.join(' OR ')}`;
  const r = await pool.query(sql, patterns.map((p) => p.toLowerCase()));
  console.log(JSON.stringify(r.rows, null, 2));
  await pool.end();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
