const express = require('express');
const pool = require('../db/pool');
const { authenticateToken, optionalAuth } = require('../middleware/auth');

const router = express.Router();

router.post('/log', optionalAuth, async (req, res) => {
  try {
    const { zone_id, zone_name, event_type, latitude, longitude, was_allowed } = req.body;

    if (!event_type || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ error: 'event_type, latitude, and longitude are required' });
    }

    const result = await pool.query(
      `INSERT INTO trip_logs (user_id, zone_id, zone_name, event_type, latitude, longitude, was_allowed)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id, timestamp`,
      [req.user?.id || null, zone_id, zone_name, event_type, latitude, longitude, was_allowed]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Trip log error:', err);
    res.status(500).json({ error: 'Failed to log trip event' });
  }
});

router.get('/history', authenticateToken, async (req, res) => {
  try {
    const limit = Math.min(parseInt(req.query.limit) || 50, 200);
    const offset = parseInt(req.query.offset) || 0;

    const result = await pool.query(
      `SELECT * FROM trip_logs WHERE user_id = $1
       ORDER BY timestamp DESC LIMIT $2 OFFSET $3`,
      [req.user.id, limit, offset]
    );

    res.json({ trips: result.rows, limit, offset });
  } catch (err) {
    console.error('Trip history error:', err);
    res.status(500).json({ error: 'Failed to fetch trip history' });
  }
});

module.exports = router;
