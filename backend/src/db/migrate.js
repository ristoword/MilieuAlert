const fs = require('fs');
const path = require('path');
const pool = require('./pool');

async function runMigrations() {
  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    await pool.query(schema);
    // One-shot: drop the false unofficial autovelox pin (Edisonstraat / The Hague).
    await pool.query(
      `DELETE FROM hazard_reports
       WHERE id = 'a2fcf2fd-9389-403c-9215-69632d4d3978'`
    );
    console.log('Database migrations completed successfully');
  } catch (err) {
    console.error('Migration error:', err.message, err.stack);
  }
}

module.exports = { runMigrations };
