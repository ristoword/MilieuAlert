const express = require('express');
const router = express.Router();
const {
  loadZones,
  getCoverage,
  SOURCES,
} = require('../services/zones');

router.get('/sync', async (req, res) => {
  const zones = await loadZones();
  const coverage = getCoverage();
  res.json({
    sources: SOURCES,
    last_updated: new Date().toISOString(),
    coverage,
    count: zones.length,
  });
});

router.get('/coverage', async (req, res) => {
  const zones = await loadZones();
  res.json({
    ...getCoverage(),
    count: zones.length,
    sampleCities: [...new Set(zones.map((z) => `${z.country}:${z.city}`))].sort().slice(0, 80),
  });
});

router.get('/data', async (req, res) => {
  try {
    const zones = await loadZones();
    res.json({
      zones,
      count: zones.length,
      coverage: getCoverage(),
      fetchedAt: new Date().toISOString(),
    });
  } catch (err) {
    console.error('Zone data error:', err);
    res.status(500).json({ error: 'Failed to load zone data', zones: [] });
  }
});

module.exports = router;
