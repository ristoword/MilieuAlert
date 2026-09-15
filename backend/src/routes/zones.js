const express = require('express');
const router = express.Router();

const NDW_URL =
  'https://data.ndw.nu/api/rest/static-road-data/emission-zones/v1/map';
const ANTWERPEN_URL =
  'https://geodata.antwerpen.be/arcgissql/rest/services/P_Portal/portal_publiek4/MapServer/283/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&f=geojson';
const BRUSSELS_URL =
  'https://gis.brussels.be/geoserver/bm_network/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=bm_network:lez_zone&outputFormat=application/json&srsName=EPSG:4326';

let cache = { zones: [], fetchedAt: 0 };
const CACHE_MS = 6 * 60 * 60 * 1000;

async function fetchJson(url) {
  const res = await fetch(url, {
    headers: { Accept: 'application/geo+json, application/json' },
  });
  if (!res.ok) throw new Error(`${url} -> ${res.status}`);
  return res.json();
}

function polygonFromGeometry(geometry) {
  if (!geometry || !geometry.coordinates) return [];
  if (geometry.type === 'Polygon') return geometry.coordinates;
  if (geometry.type === 'MultiPolygon') {
    return geometry.coordinates[0] || [];
  }
  return [];
}

function euroLevel(value) {
  if (value == null) return null;
  const match = String(value).match(/\d+/);
  return match ? Number(match[0]) : null;
}

function fromFeature(feature, defaults) {
  const props = feature.properties || {};
  const polygonCoordinates = polygonFromGeometry(feature.geometry);
  if (!polygonCoordinates.length) return null;
  return {
    id: defaults.idPrefix + (props.id || props.OBJECTID || props.name || Math.random().toString(36).slice(2)),
    country: defaults.country,
    city: props.areaName || props.NAAM || props.city || defaults.city,
    name: props.name || props.areaName || props.NAAM || defaults.name,
    zoneType: props.zoneType || props.environmentalZoneType || 'ENVIRONMENTAL_ZONE',
    polygonCoordinates,
    minimumEuroLevel: euroLevel(
      props.minimumEuroClassification || props.minEuro || props.EURO
    ),
    restrictions: props.restrictions || props.OMSCHRIJVING || null,
    officialSource: defaults.source,
  };
}

async function loadZones() {
  if (Date.now() - cache.fetchedAt < CACHE_MS && cache.zones.length) {
    return cache.zones;
  }

  const zones = [];
  const tasks = [
    fetchJson(NDW_URL)
      .then((data) => {
        for (const feature of data.features || []) {
          const zone = fromFeature(feature, {
            country: 'NL',
            city: 'Netherlands',
            name: 'Milieuzone',
            idPrefix: 'ndw_',
            source: NDW_URL,
          });
          if (zone) zones.push(zone);
        }
      })
      .catch((err) => console.error('NDW fetch failed:', err.message)),
    fetchJson(ANTWERPEN_URL)
      .then((data) => {
        for (const feature of data.features || []) {
          const zone = fromFeature(feature, {
            country: 'BE',
            city: 'Antwerpen',
            name: 'Antwerpen LEZ',
            idPrefix: 'antwerpen_',
            source: 'https://www.slimnaarantwerpen.be/en/low-emission-zone',
          });
          if (zone) zones.push(zone);
        }
      })
      .catch((err) => console.error('Antwerpen fetch failed:', err.message)),
    fetchJson(BRUSSELS_URL)
      .then((data) => {
        for (const feature of data.features || []) {
          const zone = fromFeature(feature, {
            country: 'BE',
            city: 'Brussels',
            name: 'Brussels LEZ',
            idPrefix: 'brussels_',
            source: BRUSSELS_URL,
          });
          if (zone) zones.push(zone);
        }
      })
      .catch((err) => console.error('Brussels fetch failed:', err.message)),
  ];

  await Promise.all(tasks);
  cache = { zones, fetchedAt: Date.now() };
  return zones;
}

router.get('/sync', async (req, res) => {
  res.json({
    sources: [
      { country: 'NL', name: 'NDW Emission Zones', url: NDW_URL, format: 'GeoJSON' },
      { country: 'BE', city: 'Antwerpen', name: 'Antwerpen LEZ', url: ANTWERPEN_URL, format: 'GeoJSON' },
      { country: 'BE', city: 'Brussels', name: 'Brussels LEZ', url: BRUSSELS_URL, format: 'GeoJSON' },
    ],
    last_updated: new Date().toISOString(),
  });
});

router.get('/data', async (req, res) => {
  try {
    const zones = await loadZones();
    res.json({
      zones,
      count: zones.length,
      fetchedAt: new Date(cache.fetchedAt).toISOString(),
    });
  } catch (err) {
    console.error('Zone data error:', err);
    res.status(500).json({ error: 'Failed to load zone data', zones: [] });
  }
});

module.exports = router;
