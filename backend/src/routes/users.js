const express = require('express');
const pool = require('../db/pool');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, email, display_name, phone, preferred_language, country,
              is_premium, subscription_plan, subscription_expires_at,
              marketing_consent, data_processing_consent, created_at,
              last_active_at, referral_code
       FROM users WHERE id = $1`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const vehicles = await pool.query(
      'SELECT * FROM user_vehicles WHERE user_id = $1 ORDER BY is_default DESC',
      [req.user.id]
    );

    res.json({ ...result.rows[0], vehicles: vehicles.rows });
  } catch (err) {
    console.error('Profile error:', err);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

router.put('/profile', authenticateToken, async (req, res) => {
  try {
    const { display_name, phone, preferred_language, country, marketing_consent } = req.body;

    const result = await pool.query(
      `UPDATE users SET
        display_name = COALESCE($1, display_name),
        phone = COALESCE($2, phone),
        preferred_language = COALESCE($3, preferred_language),
        country = COALESCE($4, country),
        marketing_consent = COALESCE($5, marketing_consent),
        last_active_at = NOW()
       WHERE id = $6
       RETURNING id, email, display_name, preferred_language`,
      [display_name, phone, preferred_language, country, marketing_consent, req.user.id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router;
