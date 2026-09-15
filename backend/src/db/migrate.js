const fs = require('fs');
const path = require('path');
const pool = require('./pool');

async function runMigrations() {
  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    await pool.query(schema);
    console.log('Database migrations completed successfully');
  } catch (err) {
    console.error('Migration error:', err.message, err.stack);
  }
}

module.exports = { runMigrations };
