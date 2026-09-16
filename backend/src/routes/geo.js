const express = require('express');
const router = express.Router();

const USER_AGENT =
  'MilieuAlert/1.0 (https://milieualert-production.up.railway.app)';

async function fetchJson(url, options = {}) {
  const res = await fetch(url, {
    ...options,
    headers: {
      'User-Agent': USER_AGENT,
      Accept: 'application/json',
      ...(options.headers || {}),
    },
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`${res.status} ${url} ${text.slice(0, 180)}`);
  }
  return res.json();
}

router.get('/search', async (req, res) => {
  try {
    const q = String(req.query.q || '').trim();
    if (q.length < 3) return res.json({ results: [] });
    const lang = String(req.query.lang || 'it');
    const url =
      'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=8&addressdetails=0&q=' +
      encodeURIComponent(q);
    const data = await fetchJson(url, {
      headers: { 'Accept-Language': lang },
    });
    const results = (Array.isArray(data) ? data : []).map((item) => ({
      label: item.display_name,
      lat: Number(item.lat),
      lon: Number(item.lon),
    }));
    res.json({ results });
  } catch (err) {
    console.error('geo search failed:', err.message);
    res.status(502).json({ error: 'Address search failed', results: [] });
  }
});

function serializeOsrmRoute(route) {
  const points = (route.geometry.coordinates || []).map((c) => ({
    lon: c[0],
    lat: c[1],
  }));
  const steps = [];
  for (const leg of route.legs || []) {
    for (const step of leg.steps || []) {
      const loc = (step.maneuver && step.maneuver.location) || [];
      steps.push({
        instruction: step.maneuver
          ? `${step.maneuver.type || ''} ${step.maneuver.modifier || ''}`.trim()
          : 'continue',
        type: (step.maneuver && step.maneuver.type) || 'continue',
        modifier: (step.maneuver && step.maneuver.modifier) || '',
        name: step.name || '',
        distanceMeters: step.distance || 0,
        durationSeconds: step.duration || 0,
        lat: loc[1],
        lon: loc[0],
      });
    }
  }
  const speeds = (route.legs || [])
    .flatMap((leg) => (leg.annotation && leg.annotation.speed) || []);
  return {
    points,
    steps,
    speeds,
    distanceMeters: route.distance,
    durationSeconds: route.duration,
  };
}

router.get('/route', async (req, res) => {
  try {
    const fromLon = Number(req.query.fromLon);
    const fromLat = Number(req.query.fromLat);
    const toLon = Number(req.query.toLon);
    const toLat = Number(req.query.toLat);
    if (![fromLon, fromLat, toLon, toLat].every(Number.isFinite)) {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }
    const url =
      `https://router.project-osrm.org/route/v1/driving/` +
      `${fromLon},${fromLat};${toLon},${toLat}` +
      `?overview=full&geometries=geojson&alternatives=true&steps=true&annotations=speed`;
    const data = await fetchJson(url);
    const routes = (data.routes || []).slice(0, 3).map(serializeOsrmRoute);
    const main = routes[0] || {
      points: [],
      steps: [],
      speeds: [],
      distanceMeters: 0,
      durationSeconds: 0,
    };
    res.json({
      ...main,
      alternatives: routes,
    });
  } catch (err) {
    console.error('geo route failed:', err.message);
    res.status(502).json({ error: 'Route failed', points: [], steps: [], alternatives: [] });
  }
});

function parsePathPoints(raw) {
  return String(raw || '')
    .split(';')
    .map((part) => {
      const [lat, lon] = String(part).split(',').map(Number);
      return { lat, lon };
    })
    .filter((p) => Number.isFinite(p.lat) && Number.isFinite(p.lon))
    .slice(0, 36);
}

router.get('/cameras', async (req, res) => {
  try {
    const pathPts = parsePathPoints(req.query.path);
    let query;
    if (pathPts.length >= 2) {
      const around = pathPts
        .map(
          (p) => `
  node["highway"="speed_camera"](around:180,${p.lat},${p.lon});
  node["enforcement"="maxspeed"](around:180,${p.lat},${p.lon});
  way["highway"]["maxspeed"](around:120,${p.lat},${p.lon});`
        )
        .join('\n');
      query = `[out:json][timeout:22];\n(\n${around}\n);\nout body center;`;
    } else {
      const minLat = Number(req.query.minLat);
      const minLon = Number(req.query.minLon);
      const maxLat = Number(req.query.maxLat);
      const maxLon = Number(req.query.maxLon);
      if (![minLat, minLon, maxLat, maxLon].every(Number.isFinite)) {
        return res.status(400).json({ error: 'Invalid bbox' });
      }
      query = `[out:json][timeout:22];
(
  node["highway"="speed_camera"](${minLat},${minLon},${maxLat},${maxLon});
  node["enforcement"="maxspeed"](${minLat},${minLon},${maxLat},${maxLon});
  way["maxspeed"](${minLat},${minLon},${maxLat},${maxLon});
);
out body center;`;
    }
    const data = await fetchJson('https://overpass-api.de/api/interpreter', {
      method: 'POST',
      headers: { 'Content-Type': 'text/plain' },
      body: query,
    });

    const cameras = [];
    const cameraIds = new Set();
    const limits = [];
    for (const el of data.elements || []) {
      const tags = el.tags || {};
      const lat = el.lat || (el.center && el.center.lat);
      const lon = el.lon || (el.center && el.center.lon);
      if (!Number.isFinite(lat) || !Number.isFinite(lon)) continue;
      const isCamera =
        tags.highway === 'speed_camera' || tags.enforcement === 'maxspeed';
      if (isCamera && el.type === 'node' && !cameraIds.has(el.id)) {
        cameraIds.add(el.id);
        cameras.push({
          id: String(el.id),
          lat,
          lon,
          maxspeed: tags.maxspeed || tags['maxspeed:forward'] || null,
        });
      }
      if (tags.maxspeed) {
        const parsed = parseInt(String(tags.maxspeed).replace(/[^\d]/g, ''), 10);
        if (parsed > 0 && parsed < 200) {
          limits.push({ lat, lon, maxspeed: parsed });
        }
      }
    }
    res.json({
      cameras: cameras.slice(0, 200),
      limits: limits.slice(0, 400),
    });
  } catch (err) {
    console.error('geo cameras failed:', err.message);
    res.status(502).json({ error: 'Camera lookup failed', cameras: [], limits: [] });
  }
});

module.exports = router;
