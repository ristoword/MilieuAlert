const fs = require('fs');
const path = require('path');
const pool = require('./pool');

async function runMigrations() {
  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    await pool.query(schema);
    await pool.query(`
      ALTER TABLE users ADD COLUMN IF NOT EXISTS trial_started_at TIMESTAMPTZ;
      ALTER TABLE users ADD COLUMN IF NOT EXISTS trial_ends_at TIMESTAMPTZ;
    `);
    await pool.query(`
      UPDATE users
         SET trial_started_at = COALESCE(trial_started_at, created_at, NOW()),
             trial_ends_at = COALESCE(
               trial_ends_at,
               COALESCE(trial_started_at, created_at, NOW()) + INTERVAL '15 days'
             )
       WHERE trial_started_at IS NULL OR trial_ends_at IS NULL
    `);
    await pool.query(`
      UPDATE users SET
        is_premium = TRUE,
        subscription_plan = CASE
          WHEN LOWER(COALESCE(subscription_plan, '')) IN ('staff', 'comp', 'complimentary', 'admin', 'business')
            THEN subscription_plan
          ELSE 'comp'
        END
      WHERE is_premium IS NOT TRUE
        AND (
          LOWER(email) IN (
            'admin@gestionesemplificata.com',
            'assistenza@gestionesemplificata.com',
            'info@gestionesemplificata.com',
            'stefano.montegrande@iochef.it',
            'chef@iochef.it',
            'francibasile603@gmail.com'
          )
          OR LOWER(COALESCE(display_name, '')) ~ 'giancarlo[[:space:]]+borzi|roberto[[:space:]]+dasso|stefano[[:space:]]+montegrande|francesco[[:space:]]+basile'
          OR LOWER(email) LIKE 'admin@%'
          OR LOWER(COALESCE(subscription_plan, '')) IN ('staff', 'comp', 'complimentary', 'admin')
        )
    `);
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
