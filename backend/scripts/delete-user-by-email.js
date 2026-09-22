#!/usr/bin/env node
/** One-off: DELETE user row by exact email (case-insensitive). */
require('dotenv').config();
const pool = require('../src/db/pool');

async function main() {
  const email = String(process.argv[2] || '').trim().toLowerCase();
  if (!email) {
    console.error('Usage: node delete-user-by-email.js <email>');
    process.exit(1);
  }
  const found = await pool.query(
    'SELECT id, email, display_name FROM users WHERE LOWER(email) = $1',
    [email]
  );
  if (found.rows.length === 0) {
    console.log(JSON.stringify({ deleted: false, reason: 'not_found', email }));
    await pool.end();
    return;
  }
  const row = found.rows[0];
  const del = await pool.query('DELETE FROM users WHERE id = $1 RETURNING id, email', [
    row.id,
  ]);
  console.log(JSON.stringify({ deleted: true, user: del.rows[0] }));
  await pool.end();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
