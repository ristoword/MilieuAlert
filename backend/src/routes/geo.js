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

function haversineMeters(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const toRad = (d) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function nominatimSearchUrl(q, { lat, lon, bounded = false, limit = 8 } = {}) {
  let url =
    'https://nominatim.openstreetmap.org/search?format=jsonv2&addressdetails=0&limit=' +
    limit +
    '&q=' +
    encodeURIComponent(q);
  if (Number.isFinite(lat) && Number.isFinite(lon)) {
    const d = 0.035;
    url += `&viewbox=${lon - d},${lat + d},${lon + d},${lat - d}`;
    if (bounded) url += '&bounded=1';
  }
  return url;
}

router.get('/search', async (req, res) => {
  try {
    const q = String(req.query.q || '').trim();
    if (q.length < 3) return res.json({ results: [] });
    const lang = String(req.query.lang || 'it');
    const lat = Number(req.query.lat);
    const lon = Number(req.query.lon);
    const url = nominatimSearchUrl(q, {
      lat: Number.isFinite(lat) ? lat : undefined,
      lon: Number.isFinite(lon) ? lon : undefined,
    });
    const data = await fetchJson(url, {
      headers: { 'Accept-Language': lang },
    });
    const originLat = Number.isFinite(lat) ? lat : null;
    const originLon = Number.isFinite(lon) ? lon : null;
    const results = (Array.isArray(data) ? data : []).map((item) => {
      const itemLat = Number(item.lat);
      const itemLon = Number(item.lon);
      return {
        label: item.display_name,
        lat: itemLat,
        lon: itemLon,
        distanceMeters:
          originLat != null && originLon != null
            ? Math.round(haversineMeters(originLat, originLon, itemLat, itemLon))
            : null,
      };
    });
    res.json({ results });
  } catch (err) {
    console.error('geo search failed:', err.message);
    res.status(502).json({ error: 'Address search failed', results: [] });
  }
});

const NEARBY_FILTERS = {
  restaurants: ['["amenity"="restaurant"]', '["amenity"="fast_food"]'],
  fuel: ['["amenity"="fuel"]'],
  tobacco: [
    '["shop"="tobacco"]',
    '["shop"="e-cigarette"]',
    '["vending"="cigarettes"]',
  ],
  parking: ['["amenity"="parking"]'],
  supermarket: ['["shop"="supermarket"]'],
  cafe: ['["amenity"="cafe"]'],
  pharmacy: ['["amenity"="pharmacy"]'],
};

const NEARBY_NOMINATIM = {
  restaurants: 'ristorante',
  fuel: 'benzinaio',
  tobacco: 'tabacchi',
  parking: 'parcheggio',
  supermarket: 'supermercato',
  cafe: 'caffè',
  pharmacy: 'farmacia',
};

const NEARBY_FALLBACK_LABEL = {
  restaurants: 'Ristorante',
  fuel: 'Pompa di benzina',
  tobacco: 'Tabacchi',
  parking: 'Parcheggio',
  supermarket: 'Supermercato',
  cafe: 'Caffè',
  pharmacy: 'Farmacia',
};

function poiLabel(tags, category) {
  const name =
    (tags && (tags.name || tags.brand || tags.operator)) ||
    NEARBY_FALLBACK_LABEL[category] ||
    'Luogo';
  return String(name);
}

async function overpassNearby(category, lat, lon, radius) {
  const filters = NEARBY_FILTERS[category];
  if (!filters) return [];
  const clauses = filters
    .map(
      (f) => `
  node${f}(around:${radius},${lat},${lon});
  way${f}(around:${radius},${lat},${lon});`
    )
    .join('\n');
  const query = `[out:json][timeout:20];\n(\n${clauses}\n);\nout body center 40;`;
  const data = await fetchJson('https://overpass-api.de/api/interpreter', {
    method: 'POST',
    headers: { 'Content-Type': 'text/plain' },
    body: query,
  });
  const seen = new Set();
  const results = [];
  for (const el of data.elements || []) {
    const tags = el.tags || {};
    const itemLat = el.lat || (el.center && el.center.lat);
    const itemLon = el.lon || (el.center && el.center.lon);
    if (!Number.isFinite(itemLat) || !Number.isFinite(itemLon)) continue;
    const key = `${itemLat.toFixed(5)},${itemLon.toFixed(5)}`;
    if (seen.has(key)) continue;
    seen.add(key);
    results.push({
      label: poiLabel(tags, category),
      lat: itemLat,
      lon: itemLon,
      category,
      distanceMeters: Math.round(haversineMeters(lat, lon, itemLat, itemLon)),
    });
  }
  results.sort((a, b) => a.distanceMeters - b.distanceMeters);
  return results.slice(0, 24);
}

async function nominatimNearby(category, lat, lon, lang) {
  const q = NEARBY_NOMINATIM[category];
  if (!q) return [];
  const url = nominatimSearchUrl(q, { lat, lon, bounded: true, limit: 12 });
  const data = await fetchJson(url, {
    headers: { 'Accept-Language': lang },
  });
  return (Array.isArray(data) ? data : []).map((item) => {
    const itemLat = Number(item.lat);
    const itemLon = Number(item.lon);
    return {
      label: item.display_name,
      lat: itemLat,
      lon: itemLon,
      category,
      distanceMeters: Math.round(haversineMeters(lat, lon, itemLat, itemLon)),
    };
  });
}

router.get('/nearby', async (req, res) => {
  try {
    const category = String(req.query.category || '').trim();
    const lat = Number(req.query.lat);
    const lon = Number(req.query.lon);
    const lang = String(req.query.lang || 'it');
    let radius = Number(req.query.radius);
    if (!NEARBY_FILTERS[category]) {
      return res.status(400).json({ error: 'Unknown category', results: [] });
    }
    if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
      return res.status(400).json({ error: 'Invalid coordinates', results: [] });
    }
    if (!Number.isFinite(radius)) radius = 1800;
    radius = Math.min(4000, Math.max(400, radius));

    let results = [];
    try {
      results = await overpassNearby(category, lat, lon, radius);
    } catch (err) {
      console.error('geo nearby overpass failed:', err.message);
    }
    if (!results.length) {
      try {
        results = await nominatimNearby(category, lat, lon, lang);
      } catch (err) {
        console.error('geo nearby nominatim failed:', err.message);
      }
    }
    res.json({ results });
  } catch (err) {
    console.error('geo nearby failed:', err.message);
    res.status(502).json({ error: 'Nearby search failed', results: [] });
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
