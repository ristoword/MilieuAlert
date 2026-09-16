const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db/pool');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'fallback-secret-change-me';

const PROFILE_COLUMNS = `id, email, display_name, phone, preferred_language, country,
              is_premium, subscription_plan, subscription_expires_at,
              marketing_consent, data_processing_consent, created_at,
              last_active_at, referral_code`;

async function loadVehicles(userId) {
  const vehicles = await pool.query(
    'SELECT * FROM user_vehicles WHERE user_id = $1 ORDER BY is_default DESC',
    [userId]
  );
  return vehicles.rows;
}

async function upsertVehicle(userId, vehicle) {
  if (!vehicle || typeof vehicle !== 'object') return;
  const type = vehicle.type || vehicle.vehicle_type;
  const fuel = vehicle.fuelType || vehicle.fuel_type;
  const euro = vehicle.euroClass || vehicle.euro_class;
  if (!type || !fuel || !euro) return;

  const plate = vehicle.licensePlate || vehicle.license_plate || null;
  const country = vehicle.country || vehicle.vehicle_country || null;

  const existing = await pool.query(
    'SELECT id FROM user_vehicles WHERE user_id = $1 AND is_default = TRUE LIMIT 1',
    [userId]
  );

  if (existing.rows.length > 0) {
    await pool.query(
      `UPDATE user_vehicles SET
         vehicle_type = $1,
         fuel_type = $2,
         euro_class = $3,
         license_plate = $4,
         vehicle_country = $5
       WHERE id = $6`,
      [type, fuel, euro, plate, country, existing.rows[0].id]
    );
    return;
  }

  await pool.query(
    `INSERT INTO user_vehicles
       (user_id, vehicle_type, fuel_type, euro_class, license_plate, vehicle_country, is_default)
     VALUES ($1, $2, $3, $4, $5, $6, TRUE)`,
    [userId, type, fuel, euro, plate, country]
  );
}

async function getProfileHandler(req, res) {
  try {
    const result = await pool.query(
      `SELECT ${PROFILE_COLUMNS} FROM users WHERE id = $1`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const vehicles = await loadVehicles(req.user.id);
    res.json({ ...result.rows[0], vehicles });
  } catch (err) {
    console.error('Profile error:', err);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
}

async function updateProfileHandler(req, res) {
  try {
    const userId = req.user.id;
    const {
      display_name,
      phone,
      preferred_language,
      country,
      marketing_consent,
      email,
      password,
      vehicle,
    } = req.body || {};

    const current = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
    if (current.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    let nextEmail = current.rows[0].email;
    if (typeof email === 'string' && email.trim()) {
      const normalized = email.trim().toLowerCase();
      if (normalized !== String(current.rows[0].email).toLowerCase()) {
        const clash = await pool.query(
          'SELECT id FROM users WHERE LOWER(email) = $1 AND id <> $2',
          [normalized, userId]
        );
        if (clash.rows.length > 0) {
          return res.status(409).json({ error: 'Email already registered' });
        }
        nextEmail = normalized;
      }
    }

    let passwordHash = current.rows[0].password_hash;
    let passwordChanged = false;
    if (typeof password === 'string' && password.length > 0) {
      if (password.length < 8) {
        return res.status(400).json({ error: 'Password must be at least 8 characters' });
      }
      passwordHash = await bcrypt.hash(password, 12);
      passwordChanged = true;
    }

    const language = preferred_language
      ? String(preferred_language).toLowerCase()
      : null;

    const result = await pool.query(
      `UPDATE users SET
        display_name = COALESCE($1, display_name),
        phone = COALESCE($2, phone),
        preferred_language = COALESCE($3, preferred_language),
        country = COALESCE($4, country),
        marketing_consent = COALESCE($5, marketing_consent),
        email = $6,
        password_hash = $7,
        last_active_at = NOW()
       WHERE id = $8
       RETURNING ${PROFILE_COLUMNS}`,
      [
        display_name ?? null,
        phone ?? null,
        language,
        country ?? null,
        marketing_consent ?? null,
        nextEmail,
        passwordHash,
        userId,
      ]
    );

    if (vehicle) {
      await upsertVehicle(userId, vehicle);
    }

    const user = result.rows[0];
    const vehicles = await loadVehicles(userId);
    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '30d' });

    res.json({
      ...user,
      user,
      vehicles,
      token,
      password_updated: passwordChanged,
    });
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
}

router.get('/profile', authenticateToken, getProfileHandler);
router.put('/profile', authenticateToken, updateProfileHandler);
router.patch('/profile', authenticateToken, updateProfileHandler);

router.getProfileHandler = getProfileHandler;
router.updateProfileHandler = updateProfileHandler;

module.exports = router;
