const fs = require('fs');
const path = require('path');

const NDW_URL =
  'https://data.ndw.nu/api/rest/static-road-data/emission-zones/v1/map';
const ANTWERPEN_URL =
  'https://geodata.antwerpen.be/arcgissql/rest/services/P_Portal/portal_publiek4/MapServer/283/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&f=geojson';
const BRUSSELS_URL =
  'https://gis.brussels.be/geoserver/bm_network/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=bm_network:lez_zone&outputFormat=application/json&srsName=EPSG:4326';
const GENT_URL =
  'https://data.stad.gent/api/explore/v2.1/catalog/datasets/lage-emissiezone-gent/exports/geojson';
const FR_ZFE_URL =
  'https://www.data.gouv.fr/api/1/datasets/r/673a16bf-49ec-4645-9da2-cf975d0aa0ea';
const TYREMAP_CSV_URL = 'https://tyremap.com/data/lez-zones.csv';
const TYREMAP_GEO_URL = 'https://tyremap.com/data/lez-boundaries.geojson';
const TYREMAP_CSV_MIRROR =
  'https://raw.githubusercontent.com/f4tihwin57/europe-emission-zones/main/lez-zones.csv';
const TYREMAP_GEO_MIRROR =
  'https://raw.githubusercontent.com/f4tihwin57/europe-emission-zones/main/lez-boundaries.geojson';

const BUNDLE_PATH = path.join(__dirname, '../../data/europe-zones.json');
const CACHE_MS = 6 * 60 * 60 * 1000;
const EUROPE_ISO = new Set([
  'AL', 'AD', 'AT', 'BA', 'BE', 'BG', 'BY', 'CH', 'CY', 'CZ', 'DE', 'DK', 'EE',
  'ES', 'FI', 'FR', 'GB', 'GR', 'HR', 'HU', 'IE', 'IS', 'IT', 'LI', 'LT', 'LU',
  'LV', 'MC', 'MD', 'ME', 'MK', 'MT', 'NL', 'NO', 'PL', 'PT', 'RO', 'RS', 'SE',
  'SI', 'SK', 'SM', 'TR', 'UA', 'UK', 'VA', 'XK',
]);

const COUNTRY_BOXES = [
  ['LU', 49.4, 5.7, 50.2, 6.6],
  ['BE', 49.45, 2.5, 51.55, 6.45],
  ['NL', 50.7, 3.3, 53.7, 7.3],
  ['DK', 54.5, 8.0, 57.8, 12.8],
  ['CH', 45.8, 5.9, 47.85, 10.55],
  ['AT', 46.35, 9.45, 49.05, 17.2],
  ['CZ', 48.5, 12.05, 51.1, 18.9],
  ['SK', 47.7, 16.8, 49.65, 22.6],
  ['HU', 45.7, 16.05, 48.65, 22.95],
  ['SI', 45.4, 13.35, 46.9, 16.65],
  ['HR', 42.35, 13.45, 46.6, 19.5],
  ['PT', 36.9, -9.6, 42.2, -6.15],
  ['IE', 51.35, -10.7, 55.45, -5.35],
  ['GB', 49.85, -8.25, 60.9, 1.85],
  ['UK', 49.85, -8.25, 60.9, 1.85],
  ['NO', 57.9, 4.4, 71.3, 31.3],
  ['SE', 55.2, 10.9, 69.1, 24.3],
  ['PL', 49.0, 14.1, 54.9, 24.2],
  ['IT', 36.6, 6.6, 47.15, 18.6],
  ['DE', 47.25, 5.85, 55.1, 15.05],
  ['FR', 42.3, -5.2, 51.15, 8.25],
  ['ES', 35.95, -9.4, 43.85, 4.35],
  ['GR', 34.75, 19.3, 41.8, 28.3],
  ['RO', 43.6, 20.2, 48.3, 29.8],
  ['BG', 41.2, 22.3, 44.25, 28.7],
  ['RS', 42.2, 18.8, 46.2, 23.05],
  ['FI', 59.7, 20.5, 70.1, 31.6],
  ['EE', 57.5, 21.7, 59.8, 28.3],
  ['LV', 55.6, 20.9, 58.1, 28.3],
  ['LT', 53.85, 20.9, 56.45, 26.9],
];

const OVERPASS_ENDPOINTS = [
  'https://overpass.osm.ch/api/interpreter',
  'https://overpass-api.de/api/interpreter',
  'https://lz4.overpass-api.de/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
];

const SOURCES = [
  { id: 'ndw', country: 'NL', name: 'NDW emission zones', url: NDW_URL, license: 'CC0' },
  { id: 'antwerpen', country: 'BE', name: 'Antwerpen LEZ', url: ANTWERPEN_URL, license: 'open' },
  { id: 'brussels', country: 'BE', name: 'Brussels LEZ', url: BRUSSELS_URL, license: 'open' },
  { id: 'gent', country: 'BE', name: 'Gent LEZ', url: GENT_URL, license: 'open' },
  { id: 'bnzfe', country: 'FR', name: 'Base nationale ZFE (aires.geojson)', url: FR_ZFE_URL, license: 'Licence Ouverte' },
  { id: 'tyremap', country: 'EU+', name: 'TyreMap Europe emission zones', url: TYREMAP_CSV_URL, license: 'CC BY 4.0' },
  { id: 'osm', country: 'EU+', name: 'OpenStreetMap low_emission_zone / ZTL', url: 'https://overpass-api.de/api/interpreter', license: 'ODbL' },
];

let cache = { zones: [], fetchedAt: 0, coverage: null };

function isoFromPoint(lat, lon) {
  for (const [iso, s, w, n, e] of COUNTRY_BOXES) {
    if (lat >= s && lat <= n && lon >= w && lon <= e) return iso === 'UK' ? 'GB' : iso;
  }
  return null;
}

function normalizeIso(value) {
  if (!value) return '';
  const iso = String(value).trim().toUpperCase();
  if (iso === 'UK' || iso === 'GB-UKM') return 'GB';
  if (iso.length > 2 && iso.includes('-')) return iso.slice(0, 2);
  return iso.slice(0, 2);
}

function euroLevel(value) {
  if (value == null || value === '') return null;
  const match = String(value).match(/\d+/);
  return match ? Number(match[0]) : null;
}

function samePt(a, b) {
  return Math.abs(a[0] - b[0]) < 1e-8 && Math.abs(a[1] - b[1]) < 1e-8;
}

function simplifyRing(points, eps = 0.00025) {
  if (!points || points.length <= 16) return points;
  const sq = eps * eps;
  function dist2(p, a, b) {
    const x = p[0], y = p[1], x1 = a[0], y1 = a[1], x2 = b[0], y2 = b[1];
    const dx = x2 - x1, dy = y2 - y1;
    if (dx === 0 && dy === 0) return (x - x1) ** 2 + (y - y1) ** 2;
    let t = ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy);
    t = Math.max(0, Math.min(1, t));
    const px = x1 + t * dx, py = y1 + t * dy;
    return (x - px) ** 2 + (y - py) ** 2;
  }
  function rdp(pts) {
    if (pts.length <= 2) return pts;
    let maxD = 0, idx = 0;
    const first = pts[0], last = pts[pts.length - 1];
    for (let i = 1; i < pts.length - 1; i++) {
      const d = dist2(pts[i], first, last);
      if (d > maxD) { maxD = d; idx = i; }
    }
    if (maxD > sq) {
      const left = rdp(pts.slice(0, idx + 1));
      const right = rdp(pts.slice(idx));
      return left.slice(0, -1).concat(right);
    }
    return [first, last];
  }
  let out = rdp(points);
  if (out.length > 180) {
    const step = Math.ceil(out.length / 160);
    const sampled = [];
    for (let i = 0; i < out.length - 1; i += step) sampled.push(out[i]);
    sampled.push(out[out.length - 1]);
    out = sampled;
  }
  if (out.length >= 3 && !samePt(out[0], out[out.length - 1])) out.push(out[0]);
  return out;
}

function ringsFromGeometry(geometry) {
  if (!geometry) return [];
  const rings = [];
  const pushPoly = (poly) => {
    if (!Array.isArray(poly) || !poly.length) return;
    const outer = simplifyRing(poly[0]);
    if (outer && outer.length >= 4) rings.push(outer);
  };
  if (geometry.type === 'Polygon') pushPoly(geometry.coordinates);
  else if (geometry.type === 'MultiPolygon') {
    for (const poly of geometry.coordinates || []) pushPoly(poly);
  }
  return rings;
}

function centroidOf(rings) {
  const ring = rings && rings[0];
  if (!ring || !ring.length) return null;
  let x = 0, y = 0, n = 0;
  for (const pt of ring) {
    if (!pt || pt.length < 2) continue;
    x += pt[0];
    y += pt[1];
    n += 1;
  }
  if (!n) return null;
  return { lon: x / n, lat: y / n };
}

function circlePolygon(lat, lon, radiusMeters, steps = 32) {
  const rings = [];
  const ring = [];
  const latR = radiusMeters / 110540;
  const lonR = radiusMeters / (111320 * Math.max(Math.cos((lat * Math.PI) / 180), 0.2));
  for (let i = 0; i <= steps; i++) {
    const a = (2 * Math.PI * i) / steps;
    ring.push([lon + lonR * Math.cos(a), lat + latR * Math.sin(a)]);
  }
  rings.push(ring);
  return rings;
}

function radiusForZone(row) {
  const type = `${row.zone_type || row.zoneType || ''} ${row.zone_name || row.name || ''}`.toLowerCase();
  if (type.includes('ulez') || type.includes('greater london')) return 19000;
  if (type.includes('grand paris') || type.includes('métropole du grand paris')) return 22000;
  if (type.includes('ztl')) return 1400;
  if (type.includes('zero') || type.includes('nul-emissie')) return 3500;
  if (type.includes('umwelt')) return 5000;
  if (type.includes('zfe') || type.includes("crit'air") || type.includes('critair')) return 9000;
  if (type.includes('zbe')) return 7000;
  if (type.includes('caz') || type.includes('clean air')) return 7000;
  if (type.includes('ig-l') || type.includes('ig l')) return 25000;
  if (type.includes('milieu')) return 4500;
  return 4000;
}

function pointInRing(lat, lon, ring) {
  let inside = false;
  for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    const xi = ring[i][0], yi = ring[i][1], xj = ring[j][0], yj = ring[j][1];
    const intersect = ((yi > lat) !== (yj > lat)) &&
      (lon < ((xj - xi) * (lat - yi)) / ((yj - yi) || 1e-12) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

function pointInRings(lat, lon, rings) {
  return (rings || []).some((ring) => ring.length >= 4 && pointInRing(lat, lon, ring));
}

function parseCsv(text) {
  const lines = String(text || '').split(/\r?\n/).filter((l) => l.length);
  if (!lines.length) return [];
  const parseLine = (line) => {
    const out = [];
    let cur = '', q = false;
    for (let i = 0; i < line.length; i++) {
      const ch = line[i];
      if (ch === '"') {
        if (q && line[i + 1] === '"') { cur += '"'; i += 1; }
        else q = !q;
        continue;
      }
      if (ch === ',' && !q) { out.push(cur); cur = ''; continue; }
      cur += ch;
    }
    out.push(cur);
    return out;
  };
  const header = parseLine(lines[0]);
  return lines.slice(1).map((line) => {
    const cols = parseLine(line);
    const row = {};
    header.forEach((key, i) => { row[key] = cols[i] ?? ''; });
    return row;
  });
}

function makeZone(partial) {
  const rings = (partial.polygonCoordinates || []).filter((r) => r && r.length >= 4);
  if (!rings.length) return null;
  const country = normalizeIso(partial.country);
  if (country && !EUROPE_ISO.has(country)) return null;
  const c = centroidOf(rings);
  return {
    id: String(partial.id),
    country: country || isoFromPoint(c?.lat || 0, c?.lon || 0) || '',
    city: String(partial.city || partial.name || 'Unknown').slice(0, 120),
    name: String(partial.name || partial.city || 'Emission zone').slice(0, 180),
    zoneType: String(partial.zoneType || 'ENVIRONMENTAL_ZONE'),
    polygonCoordinates: rings,
    minimumEuroLevel: partial.minimumEuroLevel ?? null,
    restrictions: partial.restrictions || null,
    officialSource: partial.officialSource || null,
    activeFrom: partial.activeFrom || null,
    activeTo: partial.activeTo || null,
    activeDays: partial.activeDays || null,
    geometrySource: partial.geometrySource || null,
  };
}

function ndwCity(props) {
  return props.county?.name ||
    props.county?.localName ||
    props.identification ||
    props.areaName ||
    props.city ||
    'Netherlands';
}

function fromGeoJsonFeatures(features, defaults) {
  const zones = [];
  for (const feature of features || []) {
    const props = feature.properties || {};
    const rings = ringsFromGeometry(feature.geometry);
    if (!rings.length) continue;
    const id = defaults.idPrefix + (
      props.environmentalZoneId ||
      props.id ||
      props.OBJECTID ||
      props.gid ||
      props.zfe_id ||
      props.slug ||
      props.name ||
      zones.length
    );
    const zone = makeZone({
      id,
      country: defaults.country,
      city: defaults.cityFrom?.(props) || props.areaName || props.NAAM || props.city || props.nom || defaults.city,
      name: defaults.nameFrom?.(props) || props.name || props.areaName || props.NAAM || props.nom || defaults.name,
      zoneType: props.zoneType || props.environmentalZoneType || defaults.zoneType || 'ENVIRONMENTAL_ZONE',
      polygonCoordinates: rings,
      minimumEuroLevel: euroLevel(props.minimumEuroClassification || props.minEuro || props.EURO || props.vp_critair),
      restrictions: props.restrictions || props.OMSCHRIJVING || props.operating_hours || null,
      officialSource: defaults.source,
      activeFrom: props.startTime || props.startDate || props.validFrom || props.date_debut || null,
      activeTo: props.endTime || props.endDate || props.validTo || props.date_fin || null,
      geometrySource: defaults.geometrySource,
    });
    if (zone) zones.push(zone);
  }
  return zones;
}

function parseTyreMap(csvText, geojson) {
  const rows = parseCsv(csvText);
  const bySlug = new Map();
  for (const feature of geojson?.features || []) {
    const slug = feature.properties?.slug || feature.properties?.id;
    const rings = ringsFromGeometry(feature.geometry);
    if (slug && rings.length) bySlug.set(String(slug), rings);
  }
  const zones = [];
  for (const row of rows) {
    const status = String(row.status || '').toLowerCase();
    if (status === 'cancelled' || status === 'never_enacted') continue;
    const lat = Number(row.lat), lon = Number(row.lng);
    let rings = bySlug.get(row.zone_slug);
    let geometrySource = rings ? 'tyremap' : 'approx';
    if (!rings && Number.isFinite(lat) && Number.isFinite(lon)) {
      rings = circlePolygon(lat, lon, radiusForZone(row));
    }
    const petrol = euroLevel(row.petrol_min_euro);
    const diesel = euroLevel(row.diesel_min_euro);
    const minEuro = [petrol, diesel].filter((n) => n != null).sort((a, b) => b - a)[0] ?? null;
    const zone = makeZone({
      id: `tyre_${row.zone_slug || zones.length}`,
      country: row.iso2 || row.country,
      city: row.city,
      name: row.zone_name || row.city,
      zoneType: row.zone_type || 'ENVIRONMENTAL_ZONE',
      polygonCoordinates: rings,
      minimumEuroLevel: minEuro,
      restrictions: [row.operating_hours, row.sticker, row.fine && `fine ${row.fine}`].filter(Boolean).join(' · ') || null,
      officialSource: `TyreMap CC BY 4.0 — ${row.zone_slug}`,
      geometrySource,
    });
    if (zone) zones.push(zone);
  }
  return zones;
}

function lonLatFromOverpassGeom(geom) {
  return (geom || []).map((p) => [p.lon, p.lat]);
}

function stitchRings(lines) {
  const unused = lines.filter((l) => l && l.length >= 2).map((l) => l.slice());
  const rings = [];
  while (unused.length) {
    let ring = unused.pop();
    let changed = true;
    while (changed) {
      changed = false;
      for (let i = unused.length - 1; i >= 0; i--) {
        const line = unused[i];
        const rs = ring[0], re = ring[ring.length - 1];
        const ls = line[0], le = line[line.length - 1];
        if (samePt(re, ls)) { ring = ring.concat(line.slice(1)); unused.splice(i, 1); changed = true; }
        else if (samePt(re, le)) { ring = ring.concat(line.slice(0, -1).reverse()); unused.splice(i, 1); changed = true; }
        else if (samePt(rs, le)) { ring = line.slice(0, -1).concat(ring); unused.splice(i, 1); changed = true; }
        else if (samePt(rs, ls)) { ring = line.slice().reverse().slice(0, -1).concat(ring); unused.splice(i, 1); changed = true; }
      }
    }
    if (ring.length >= 4) {
      if (!samePt(ring[0], ring[ring.length - 1])) ring.push(ring[0]);
      rings.push(simplifyRing(ring));
    }
  }
  return rings;
}

function parseOverpass(data) {
  const zones = [];
  for (const el of data?.elements || []) {
    const tags = el.tags || {};
    let rings = [];
    if (el.type === 'way' && el.geometry) {
      const ring = lonLatFromOverpassGeom(el.geometry);
      if (ring.length >= 4) {
        if (!samePt(ring[0], ring[ring.length - 1])) ring.push(ring[0]);
        rings = [simplifyRing(ring)];
      }
    } else if (el.type === 'relation') {
      const outers = [];
      for (const m of el.members || []) {
        if (m.type !== 'way' || !m.geometry) continue;
        if ((m.role || 'outer') === 'inner') continue;
        outers.push(lonLatFromOverpassGeom(m.geometry));
      }
      rings = stitchRings(outers);
    }
    if (!rings.length) continue;
    const c = centroidOf(rings);
    const iso = normalizeIso(tags['ISO3166-1'] || tags['addr:country'] || tags['is_in:country_code']) ||
      (c ? isoFromPoint(c.lat, c.lon) : '');
    const name = tags.name || tags['name:en'] || tags.official_name || 'Emission zone';
    const city = tags['addr:city'] || tags['is_in:city'] || tags['is_in'] || name.replace(
      /\b(Umweltzone|milieuzone|LEZ|ULEZ|ZFE|ZBE|ZTL|CAZ|Low Emission Zone)\b/ig,
      ''
    ).trim() || name;
    const zone = makeZone({
      id: `osm_${el.type}_${el.id}`,
      country: iso,
      city,
      name,
      zoneType: tags.boundary === 'restricted_traffic_area' ? 'ZTL' : (tags.boundary || 'ENVIRONMENTAL_ZONE'),
      polygonCoordinates: rings,
      officialSource: '© OpenStreetMap contributors (ODbL)',
      geometrySource: 'osm',
    });
    if (zone) zones.push(zone);
  }
  return zones;
}

function isGenericLabel(value) {
  const v = String(value || '').trim().toLowerCase();
  return !v ||
    v === 'emission zone' ||
    v === 'milieuzone' ||
    v === 'netherlands' ||
    v === 'france' ||
    v === 'unknown';
}

function pickLabel(primary, secondary) {
  if (!isGenericLabel(primary)) return primary;
  if (!isGenericLabel(secondary)) return secondary;
  return primary || secondary;
}

function mergeZones(lists) {
  const out = [];
  const byId = new Map();
  const index = [];

  const quality = (z) => {
    const src = z.geometrySource || '';
    const pts = (z.polygonCoordinates || []).reduce((n, r) => n + r.length, 0);
    let score = pts;
    if (src === 'ndw' || src === 'bnzfe' || src === 'be') score += 50000;
    if (src === 'osm') score += 20000;
    if (src === 'tyremap') score += 10000;
    if (src === 'approx') score -= 40000;
    return score;
  };

  const add = (zone) => {
    if (!zone || byId.has(zone.id)) {
      if (zone && byId.has(zone.id)) {
        const prev = byId.get(zone.id);
        if (quality(zone) >= quality(prev)) {
          const idx = out.indexOf(prev);
          if (idx >= 0) out[idx] = zone;
          byId.set(zone.id, zone);
        }
      }
      return;
    }
    const c = centroidOf(zone.polygonCoordinates);
    if (c) {
      for (const other of index) {
        if (other.country !== zone.country) continue;
        const dlat = other.lat - c.lat;
        const dlon = (other.lon - c.lon) * Math.cos((c.lat * Math.PI) / 180);
        const km = Math.sqrt(dlat * dlat + dlon * dlon) * 111.32;
        if (km > 3.2) continue;
        const cityClose = other.zone.city.toLowerCase() === zone.city.toLowerCase() &&
          !isGenericLabel(other.zone.city);
        if (cityClose) {
          const winner = quality(zone) > quality(other.zone) ? zone : other.zone;
          const loser = winner === zone ? other.zone : zone;
          const merged = {
            ...winner,
            city: pickLabel(winner.city, loser.city),
            name: pickLabel(winner.name, loser.name),
            minimumEuroLevel: winner.minimumEuroLevel ?? loser.minimumEuroLevel,
            restrictions: winner.restrictions || loser.restrictions,
          };
          const idx = out.indexOf(other.zone);
          if (idx >= 0) out[idx] = merged;
          byId.delete(other.zone.id);
          byId.set(merged.id, merged);
          other.zone = merged;
          const mc = centroidOf(merged.polygonCoordinates);
          if (mc) { other.lat = mc.lat; other.lon = mc.lon; }
          return;
        }
      }
    }
    out.push(zone);
    byId.set(zone.id, zone);
    if (c) index.push({ zone, lat: c.lat, lon: c.lon, country: zone.country });
  };

  for (const list of lists) {
    for (const zone of list || []) add(zone);
  }
  return out;
}

function attachBetterPolygons(catalog, donors) {
  for (const zone of catalog) {
    if (zone.geometrySource && zone.geometrySource !== 'approx') continue;
    const c = centroidOf(zone.polygonCoordinates);
    if (!c) continue;
    let best = null, bestPts = 0;
    for (const donor of donors) {
      if (donor.country && zone.country && donor.country !== zone.country) continue;
      if (!pointInRings(c.lat, c.lon, donor.polygonCoordinates)) continue;
      const pts = donor.polygonCoordinates.reduce((n, r) => n + r.length, 0);
      if (pts > bestPts) { best = donor; bestPts = pts; }
    }
    if (best) {
      zone.polygonCoordinates = best.polygonCoordinates;
      zone.geometrySource = best.geometrySource || 'osm';
    }
  }
  return catalog;
}

async function fetchJson(url, timeoutMs = 28000) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), timeoutMs);
  try {
    const res = await fetch(url, {
      headers: { Accept: 'application/geo+json, application/json, text/csv, */*' },
      signal: ctrl.signal,
    });
    if (!res.ok) throw new Error(`${url} -> ${res.status}`);
    const ct = res.headers.get('content-type') || '';
    if (ct.includes('json')) return res.json();
    const text = await res.text();
    try { return JSON.parse(text); } catch { return text; }
  } finally {
    clearTimeout(timer);
  }
}

async function fetchText(url, timeoutMs = 28000) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), timeoutMs);
  try {
    const res = await fetch(url, { signal: ctrl.signal, headers: { Accept: 'text/csv, */*' } });
    if (!res.ok) throw new Error(`${url} -> ${res.status}`);
    return res.text();
  } finally {
    clearTimeout(timer);
  }
}

async function fetchOverpass(query, timeoutMs = 55000) {
  let lastErr;
  for (const url of OVERPASS_ENDPOINTS) {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), timeoutMs);
    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        body: `data=${encodeURIComponent(query)}`,
        signal: ctrl.signal,
      });
      if (res.status === 429) {
        lastErr = new Error(`${url} -> 429`);
        await new Promise((r) => setTimeout(r, 12000));
        continue;
      }
      if (!res.ok) throw new Error(`${url} -> ${res.status}`);
      return await res.json();
    } catch (err) {
      lastErr = err;
    } finally {
      clearTimeout(timer);
    }
  }
  throw lastErr || new Error('Overpass failed');
}

const OSM_LEZ_QUERY = `[out:json][timeout:150];
(
  relation["boundary"="low_emission_zone"](34.5,-25,71.5,42);
  way["boundary"="low_emission_zone"](34.5,-25,71.5,42);
  relation["boundary"="environmental_zone"](34.5,-25,71.5,42);
  way["boundary"="environmental_zone"](34.5,-25,71.5,42);
);
out geom;`;

const OSM_IT_ZTL_QUERY = `[out:json][timeout:150];
area["ISO3166-1"="IT"][admin_level=2]->.it;
(
  relation["boundary"="restricted_traffic_area"](area.it);
  way["boundary"="restricted_traffic_area"](area.it);
  relation["restriction"="ztl"](area.it);
  way["restriction"="ztl"](area.it);
);
out geom;`;

function loadBundled() {
  try {
    const raw = JSON.parse(fs.readFileSync(BUNDLE_PATH, 'utf8'));
    return Array.isArray(raw.zones) ? raw.zones : [];
  } catch {
    return [];
  }
}

function summarize(zones) {
  const byCountry = {};
  const cities = new Set();
  let approx = 0;
  for (const z of zones) {
    byCountry[z.country] = (byCountry[z.country] || 0) + 1;
    cities.add(`${z.country}|${z.city}`);
    if (z.geometrySource === 'approx') approx += 1;
  }
  return {
    zones: zones.length,
    countries: Object.keys(byCountry).filter(Boolean).sort(),
    countryCount: Object.keys(byCountry).filter(Boolean).length,
    cityCount: cities.size,
    byCountry,
    approximatePolygons: approx,
  };
}

async function fetchLiveNational() {
  const lists = [];
  const tasks = [
    fetchJson(NDW_URL).then((data) => {
      lists.push(fromGeoJsonFeatures(data.features, {
        country: 'NL',
        city: 'Netherlands',
        name: 'Milieuzone',
        idPrefix: 'ndw_',
        source: NDW_URL,
        geometrySource: 'ndw',
        cityFrom: ndwCity,
        nameFrom: (p) => p.identification || p.name || p.areaName || 'Milieuzone',
      }));
    }).catch((err) => console.error('NDW fetch failed:', err.message)),
    fetchJson(ANTWERPEN_URL).then((data) => {
      lists.push(fromGeoJsonFeatures(data.features, {
        country: 'BE', city: 'Antwerpen', name: 'Antwerpen LEZ',
        idPrefix: 'antwerpen_', source: 'https://www.slimnaarantwerpen.be/en/low-emission-zone',
        geometrySource: 'be',
      }));
    }).catch((err) => console.error('Antwerpen fetch failed:', err.message)),
    fetchJson(BRUSSELS_URL).then((data) => {
      lists.push(fromGeoJsonFeatures(data.features, {
        country: 'BE', city: 'Brussels', name: 'Brussels LEZ',
        idPrefix: 'brussels_', source: 'https://lez.brussels/',
        geometrySource: 'be',
        nameFrom: (p) => p.name_en || p.name_fr || p.name || 'Brussels LEZ',
      }));
    }).catch((err) => console.error('Brussels fetch failed:', err.message)),
    fetchJson(GENT_URL).then((data) => {
      lists.push(fromGeoJsonFeatures(data.features, {
        country: 'BE', city: 'Gent', name: 'Gent LEZ',
        idPrefix: 'gent_', source: 'https://stad.gent/lez',
        geometrySource: 'be',
      }));
    }).catch((err) => console.error('Gent fetch failed:', err.message)),
    fetchJson(FR_ZFE_URL, 45000).then((data) => {
      lists.push(fromGeoJsonFeatures(data.features, {
        country: 'FR', city: 'France', name: 'ZFE',
        idPrefix: 'frzfe_', source: FR_ZFE_URL,
        geometrySource: 'bnzfe',
        cityFrom: (p) => p.nom || p.zfe_id || p.id || 'France',
        nameFrom: (p) => p.nom || p.zfe_id || 'ZFE',
      }));
    }).catch((err) => console.error('BNZFE fetch failed:', err.message)),
  ];
  await Promise.all(tasks);
  return lists.flat();
}

async function fetchTyreMapLive() {
  const csv = await fetchText(TYREMAP_CSV_URL).catch(() => fetchText(TYREMAP_CSV_MIRROR));
  const geo = await fetchJson(TYREMAP_GEO_URL, 45000).catch(() => fetchJson(TYREMAP_GEO_MIRROR, 45000));
  return parseTyreMap(csv, geo);
}

async function buildFullDataset({ includeOsm = true } = {}) {
  const bundled = loadBundled();
  const national = await fetchLiveNational();
  let tyre = [];
  try { tyre = await fetchTyreMapLive(); }
  catch (err) { console.error('TyreMap fetch failed:', err.message); }

  let osm = [];
  if (includeOsm) {
    try {
      const lez = await fetchOverpass(OSM_LEZ_QUERY);
      osm = osm.concat(parseOverpass(lez));
    } catch (err) {
      console.error('OSM LEZ fetch failed:', err.message);
    }
    try {
      const ztl = await fetchOverpass(OSM_IT_ZTL_QUERY);
      osm = osm.concat(parseOverpass(ztl));
    } catch (err) {
      console.error('OSM ZTL fetch failed:', err.message);
    }
  }

  const catalog = tyre.length ? tyre : bundled.filter((z) => String(z.id).startsWith('tyre_'));
  attachBetterPolygons(catalog, [...national, ...osm]);
  const merged = mergeZones([catalog, national, osm, bundled]);
  return merged;
}

async function loadZones() {
  if (Date.now() - cache.fetchedAt < CACHE_MS && cache.zones.length) {
    return cache.zones;
  }
  const bundled = loadBundled();
  if (bundled.length) {
    cache = { zones: bundled, fetchedAt: Date.now(), coverage: summarize(bundled) };
  }
  try {
    const live = await Promise.race([
      (async () => {
        const national = await fetchLiveNational();
        let tyre = [];
        try { tyre = await fetchTyreMapLive(); } catch (err) {
          console.error('TyreMap live failed:', err.message);
        }
        if (tyre.length) attachBetterPolygons(tyre, national);
        return mergeZones([tyre, national, bundled]);
      })(),
      new Promise((_, reject) => setTimeout(() => reject(new Error('live-timeout')), 22000)),
    ]);
    if (live.length) {
      cache = { zones: live, fetchedAt: Date.now(), coverage: summarize(live) };
    }
  } catch (err) {
    console.error('Live zone refresh skipped:', err.message);
    if (!cache.zones.length) {
      cache = { zones: bundled, fetchedAt: Date.now(), coverage: summarize(bundled) };
    }
  }
  return cache.zones;
}

function getCoverage() {
  return cache.coverage || summarize(cache.zones);
}

module.exports = {
  SOURCES,
  BUNDLE_PATH,
  parseCsv,
  parseTyreMap,
  parseOverpass,
  fromGeoJsonFeatures,
  ringsFromGeometry,
  circlePolygon,
  mergeZones,
  attachBetterPolygons,
  makeZone,
  summarize,
  loadBundled,
  loadZones,
  buildFullDataset,
  fetchOverpass,
  fetchLiveNational,
  fetchTyreMapLive,
  OSM_LEZ_QUERY,
  OSM_IT_ZTL_QUERY,
  getCoverage,
  NDW_URL,
  ANTWERPEN_URL,
  BRUSSELS_URL,
  GENT_URL,
  FR_ZFE_URL,
  TYREMAP_CSV_URL,
  TYREMAP_GEO_URL,
};
