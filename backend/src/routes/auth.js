const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db/pool');
const { authenticateToken } = require('../middleware/auth');
const userRoutes = require('./users');
const { computeEntitlement, addDays, pickTrialStart } = require('../services/entitlement');
const { attachEntitlement, clientTrialHeader } = require('../services/trialStore');
const { notifyRegistration } = require('../services/gsSync');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'fallback-secret-change-me';

router.post('/register', async (req, res) => {
  try {
    const { email, password, display_name, preferred_language, country } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    const password_hash = await bcrypt.hash(password, 12);
    const referral_code = 'MA' + Math.random().toString(36).substring(2, 10).toUpperCase();
    const trialStart = pickTrialStart({
      clientStartedAt: req.body?.trial_started_at,
      now: new Date(),
    });
    const trialEnds = addDays(trialStart, 15);

    const result = await pool.query(
      `INSERT INTO users (
         email, password_hash, display_name, preferred_language, country, referral_code,
         trial_started_at, trial_ends_at
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, email, display_name, preferred_language, country,
                 is_premium, subscription_plan, trial_started_at, trial_ends_at, created_at`,
      [
        email,
        password_hash,
        display_name || null,
        preferred_language || 'en',
        country || null,
        referral_code,
        trialStart,
        trialEnds,
      ]
    );

    const user = result.rows[0];
    notifyRegistration(user);
    const entitlement = computeEntitlement(user);
    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '30d' });

    res.status(201).json({ user: { ...user, entitlement }, token, entitlement });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ error: 'Registration failed' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    await pool.query('UPDATE users SET last_active_at = NOW() WHERE id = $1', [user.id]);
    const withTrial = await attachEntitlement(user, clientTrialHeader(req));
    const entitlement = computeEntitlement(withTrial);

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '30d' });

    res.json({
      user: {
        id: withTrial.id,
        email: withTrial.email,
        display_name: withTrial.display_name,
        preferred_language: withTrial.preferred_language,
        country: withTrial.country,
        is_premium: withTrial.is_premium,
        subscription_plan: withTrial.subscription_plan,
        trial_started_at: withTrial.trial_started_at,
        trial_ends_at: withTrial.trial_ends_at,
        entitlement,
      },
      token,
      entitlement,
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Login failed' });
  }
});

router.get('/me', authenticateToken, userRoutes.getProfileHandler);
router.put('/me', authenticateToken, userRoutes.updateProfileHandler);
router.patch('/me', authenticateToken, userRoutes.updateProfileHandler);

module.exports = router;
