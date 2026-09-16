const express = require('express');
const rateLimit = require('express-rate-limit');
const pool = require('../db/pool');
const { optionalAuth } = require('../middleware/auth');
const {
  REPORT_RATE_WINDOW_MS,
  REPORT_RATE_MAX,
  DUPLICATE_METERS,
  DUPLICATE_WINDOW_MS,
  isHazardType,
  expiresAtFrom,
  clampNote,
  clampComment,
  voterKey,
  haversineMeters,
  bboxDelta,
  shouldExpireFromVotes,
  nextExpiryOnConfirm,
  toPublicReport,
  toPublicComment,
} = require('../services/hazards');

const router = express.Router();

const reportLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
});

const voteLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 80,
  standardHeaders: true,
  legacyHeaders: false,
});

const sseClients = new Set();

function deviceFrom(req) {
  const body = req.body || {};
  const header = req.headers['x-device-id'];
  const raw = body.device_id || body.deviceId || header || '';
  const id = String(raw).trim().slice(0, 64);
  return id.length >= 8 ? id : null;
}

function originFrom(req) {
  const lat = Number(req.query.lat ?? req.body?.lat);
  const lon = Number(req.query.lon ?? req.body?.lon);
  if (!Number.isFinite(lat) || !Number.isFinite(lon)) return null;
  return { lat, lon };
}

function broadcastHazard(event, payload) {
  const data = `event: ${event}\ndata: ${JSON.stringify(payload)}\n\n`;
  for (const client of sseClients) {
    try {
      if (client.origin) {
        const d = haversineMeters(
          client.origin.lat,
          client.origin.lon,
          payload.lat,
          payload.lon
        );
        if (d > (client.radius || 8000)) continue;
      }
      client.res.write(data);
    } catch (_) {
      sseClients.delete(client);
    }
  }
}

async function loadActiveNearby(lat, lon, radius) {
  const delta = bboxDelta(radius);
  const result = await pool.query(
    `SELECT id, type, lat, lon, heading, note, created_at, expires_at,
            confirm_count, deny_count
     FROM hazard_reports
     WHERE expires_at > NOW()
       AND lat BETWEEN $1 AND $2
       AND lon BETWEEN $3 AND $4
     ORDER BY created_at DESC
     LIMIT 300`,
    [lat - delta, lat + delta, lon - delta, lon + delta]
  );
  return result.rows
    .map((row) => toPublicReport(row, { lat, lon }))
    .filter((row) => (row.distanceMeters ?? 0) <= radius)
    .sort((a, b) => (a.distanceMeters ?? 0) - (b.distanceMeters ?? 0))
    .slice(0, 120);
}

router.post('/report', optionalAuth, reportLimiter, async (req, res) => {
  try {
    const type = String(req.body?.type || '').trim();
    const lat = Number(req.body?.lat);
    const lon = Number(req.body?.lon);
    const headingRaw = req.body?.heading;
    const heading =
      headingRaw == null || headingRaw === '' ? null : Number(headingRaw);
    const note = clampNote(req.body?.note);
    const deviceId = deviceFrom(req);
    const userId = req.user?.id || null;

    if (!isHazardType(type)) {
      return res.status(400).json({ error: 'Unknown hazard type' });
    }
    if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }
    if (Math.abs(lat) > 90 || Math.abs(lon) > 180) {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }
    if (heading != null && !Number.isFinite(heading)) {
      return res.status(400).json({ error: 'Invalid heading' });
    }
    if (!userId && !deviceId) {
      return res.status(400).json({ error: 'Device id required for guest reports' });
    }

    const key = voterKey({ userId, deviceId });
    const since = new Date(Date.now() - REPORT_RATE_WINDOW_MS);
    const recent = await pool.query(
      `SELECT COUNT(*)::int AS n FROM hazard_reports
       WHERE created_at > $1
         AND (
           ($2::uuid IS NOT NULL AND user_id = $2)
           OR ($3::text IS NOT NULL AND device_id = $3)
         )`,
      [since, userId, deviceId]
    );
    if ((recent.rows[0]?.n || 0) >= REPORT_RATE_MAX) {
      return res.status(429).json({ error: 'Too many reports, try later' });
    }

    const nearbyDup = await pool.query(
      `SELECT id, type, lat, lon, confirm_count, deny_count, expires_at
       FROM hazard_reports
       WHERE type = $1
         AND expires_at > NOW()
         AND created_at > $2
         AND lat BETWEEN $3 AND $4
         AND lon BETWEEN $5 AND $6
       ORDER BY created_at DESC
       LIMIT 20`,
      [
        type,
        new Date(Date.now() - DUPLICATE_WINDOW_MS),
        lat - 0.002,
        lat + 0.002,
        lon - 0.002,
        lon + 0.002,
      ]
    );
    const duplicate = nearbyDup.rows.find(
      (row) => haversineMeters(lat, lon, row.lat, row.lon) <= DUPLICATE_METERS
    );
    if (duplicate) {
      if (key) {
        await pool.query(
          `INSERT INTO hazard_votes (report_id, voter_key, vote)
           VALUES ($1, $2, 'confirm')
           ON CONFLICT (report_id, voter_key) DO NOTHING`,
          [duplicate.id, key]
        );
      }
      const updated = await pool.query(
        `UPDATE hazard_reports
         SET confirm_count = confirm_count + 1,
             expires_at = $2
         WHERE id = $1
         RETURNING id, type, lat, lon, heading, note, created_at, expires_at,
                   confirm_count, deny_count`,
        [duplicate.id, nextExpiryOnConfirm(type, duplicate.expires_at)]
      );
      const report = toPublicReport(updated.rows[0], { lat, lon });
      broadcastHazard('hazard', report);
      return res.status(200).json({ report, merged: true });
    }

    const inserted = await pool.query(
      `INSERT INTO hazard_reports
         (user_id, device_id, type, lat, lon, heading, note, expires_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, type, lat, lon, heading, note, created_at, expires_at,
                 confirm_count, deny_count`,
      [
        userId,
        deviceId,
        type,
        lat,
        lon,
        Number.isFinite(heading) ? heading : null,
        note,
        expiresAtFrom(type),
      ]
    );
    const report = toPublicReport(inserted.rows[0], { lat, lon });
    broadcastHazard('hazard', report);
    res.status(201).json({ report, merged: false });
  } catch (err) {
    console.error('hazard report failed:', err.message);
    res.status(500).json({ error: 'Failed to save report' });
  }
});

router.get('/stream', optionalAuth, async (req, res) => {
  const origin = originFrom(req);
  let radius = Number(req.query.radius);
  if (!Number.isFinite(radius)) radius = 8000;
  radius = Math.min(20000, Math.max(500, radius));

  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders?.();
  res.write('event: ready\ndata: {}\n\n');

  const client = { res, origin, radius };
  sseClients.add(client);
  req.on('close', () => sseClients.delete(client));
});

router.get('/nearby', optionalAuth, async (req, res) => {
  try {
    const lat = Number(req.query.lat);
    const lon = Number(req.query.lon);
    let radius = Number(req.query.radius);
    if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
      return res.status(400).json({ error: 'Invalid coordinates', reports: [] });
    }
    if (!Number.isFinite(radius)) radius = 4000;
    radius = Math.min(20000, Math.max(300, radius));
    const reports = await loadActiveNearby(lat, lon, radius);
    res.json({ reports });
  } catch (err) {
    console.error('hazard nearby failed:', err.message);
    res.status(502).json({ error: 'Nearby lookup failed', reports: [] });
  }
});

router.post('/:id/vote', optionalAuth, voteLimiter, async (req, res) => {
  try {
    const id = String(req.params.id || '').trim();
    const vote = String(req.body?.vote || req.body?.action || '').trim();
    if (vote !== 'confirm' && vote !== 'deny') {
      return res.status(400).json({ error: 'vote must be confirm or deny' });
    }
    const deviceId = deviceFrom(req);
    const userId = req.user?.id || null;
    const key = voterKey({ userId, deviceId });
    if (!key) {
      return res.status(400).json({ error: 'Device id required to vote' });
    }

    const existing = await pool.query(
      `SELECT id, type, lat, lon, heading, note, created_at, expires_at,
              confirm_count, deny_count
       FROM hazard_reports WHERE id = $1`,
      [id]
    );
    if (!existing.rows.length) {
      return res.status(404).json({ error: 'Report not found' });
    }

    const prevVote = await pool.query(
      `SELECT vote FROM hazard_votes WHERE report_id = $1 AND voter_key = $2`,
      [id, key]
    );
    const previous = prevVote.rows[0]?.vote || null;
    if (previous === vote) {
      return res.json({
        report: toPublicReport(existing.rows[0]),
        vote,
        unchanged: true,
      });
    }

    await pool.query(
      `INSERT INTO hazard_votes (report_id, voter_key, vote)
       VALUES ($1, $2, $3)
       ON CONFLICT (report_id, voter_key)
       DO UPDATE SET vote = EXCLUDED.vote, created_at = NOW()`,
      [id, key, vote]
    );

    let confirmDelta = 0;
    let denyDelta = 0;
    if (previous === 'confirm') confirmDelta -= 1;
    if (previous === 'deny') denyDelta -= 1;
    if (vote === 'confirm') confirmDelta += 1;
    if (vote === 'deny') denyDelta += 1;

    const row = existing.rows[0];
    let expires = row.expires_at;
    if (vote === 'confirm') {
      expires = nextExpiryOnConfirm(row.type, row.expires_at);
    }
    const nextConfirm = Math.max(0, Number(row.confirm_count) + confirmDelta);
    const nextDeny = Math.max(0, Number(row.deny_count) + denyDelta);
    if (shouldExpireFromVotes(nextConfirm, nextDeny)) {
      expires = new Date();
    }

    const updated = await pool.query(
      `UPDATE hazard_reports
       SET confirm_count = $2,
           deny_count = $3,
           expires_at = $4
       WHERE id = $1
       RETURNING id, type, lat, lon, heading, note, created_at, expires_at,
                 confirm_count, deny_count`,
      [id, nextConfirm, nextDeny, expires]
    );
    const report = toPublicReport(updated.rows[0]);
    broadcastHazard('hazard', report);
    res.json({ report, vote });
  } catch (err) {
    console.error('hazard vote failed:', err.message);
    res.status(500).json({ error: 'Failed to vote' });
  }
});

router.get('/:id/comments', optionalAuth, async (req, res) => {
  try {
    const id = String(req.params.id || '').trim();
    const result = await pool.query(
      `SELECT id, body, created_at FROM hazard_comments
       WHERE report_id = $1
       ORDER BY created_at DESC
       LIMIT 40`,
      [id]
    );
    res.json({ comments: result.rows.map(toPublicComment) });
  } catch (err) {
    console.error('hazard comments failed:', err.message);
    res.status(500).json({ error: 'Failed to load comments', comments: [] });
  }
});

router.post('/:id/comments', optionalAuth, voteLimiter, async (req, res) => {
  try {
    const id = String(req.params.id || '').trim();
    const text = clampComment(req.body?.text || req.body?.body);
    if (text.length < 2) {
      return res.status(400).json({ error: 'Comment too short' });
    }
    const deviceId = deviceFrom(req);
    const userId = req.user?.id || null;
    if (!userId && !deviceId) {
      return res.status(400).json({ error: 'Device id required to comment' });
    }
    const exists = await pool.query(
      `SELECT id FROM hazard_reports WHERE id = $1 AND expires_at > NOW()`,
      [id]
    );
    if (!exists.rows.length) {
      return res.status(404).json({ error: 'Report not found' });
    }
    const inserted = await pool.query(
      `INSERT INTO hazard_comments (report_id, user_id, device_id, body)
       VALUES ($1, $2, $3, $4)
       RETURNING id, body, created_at`,
      [id, userId, deviceId, text]
    );
    res.status(201).json({ comment: toPublicComment(inserted.rows[0]) });
  } catch (err) {
    console.error('hazard comment failed:', err.message);
    res.status(500).json({ error: 'Failed to save comment' });
  }
});

module.exports = router;
