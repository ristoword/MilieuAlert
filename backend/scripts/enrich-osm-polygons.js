const fs = require('fs');
const { loadBundled, BUNDLE_PATH, summarize, parseOverpass, fetchOverpass, attachBetterPolygons, mergeZones, fetchLiveNational } = require('../src/services/zones');

function queryForBbox(s, w, n, e) {
  return `[out:json][timeout:90];
(
  relation["boundary"="low_emission_zone"](${s},${w},${n},${e});
  way["boundary"="low_emission_zone"](${s},${w},${n},${e});
  relation["boundary"="environmental_zone"](${s},${w},${n},${e});
  way["boundary"="environmental_zone"](${s},${w},${n},${e});
);
out geom;`;
}

function ztlQuery(s, w, n, e) {
  return `[out:json][timeout:90];
(
  relation["boundary"="restricted_traffic_area"](${s},${w},${n},${e});
  way["boundary"="restricted_traffic_area"](${s},${w},${n},${e});
);
out geom;`;
}

const BOXES = [
  ['west', 35, -11, 60, 5],
  ['central', 44, 4, 56, 16],
  ['east', 44, 15, 55, 30],
  ['south', 35, 5, 46, 20],
  ['north', 54, 4, 71, 32],
  ['it-north', 43.5, 6.5, 47.2, 13.8],
  ['it-center', 40.5, 8, 44.2, 16],
  ['it-south', 36.5, 12, 41.2, 18.6],
];

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function main() {
  const bundled = loadBundled();
  const osm = [];
  for (const [name, s, w, n, e] of BOXES) {
    const isItaly = name.startsWith('it-');
    const q = isItaly ? ztlQuery(s, w, n, e) : queryForBbox(s, w, n, e);
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        await sleep(2500 * attempt);
        const data = await fetchOverpass(q, 100000);
        const parsed = parseOverpass(data);
        console.log(name, 'elements', data.elements?.length || 0, 'zones', parsed.length);
        osm.push(...parsed);
        break;
      } catch (err) {
        console.error(name, 'attempt', attempt, err.message);
        await sleep(8000);
      }
    }
  }
  let national = [];
  try { national = await fetchLiveNational(); }
  catch (err) { console.error('national', err.message); }

  attachBetterPolygons(bundled, [...osm, ...national]);
  const merged = mergeZones([bundled, national, osm]);
  const coverage = summarize(merged);
  const raw = JSON.parse(fs.readFileSync(BUNDLE_PATH, 'utf8'));
  raw.generatedAt = new Date().toISOString();
  raw.coverage = coverage;
  raw.zones = merged;
  fs.writeFileSync(BUNDLE_PATH, JSON.stringify(raw));
  console.log(JSON.stringify({ bytes: fs.statSync(BUNDLE_PATH).size, osm: osm.length, national: national.length, ...coverage }, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
