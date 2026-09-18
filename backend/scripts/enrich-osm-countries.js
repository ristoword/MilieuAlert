const fs = require('fs');
const {
  BUNDLE_PATH,
  loadBundled,
  parseOverpass,
  fetchOverpass,
  attachBetterPolygons,
  mergeZones,
  fetchLiveNational,
  summarize,
} = require('../src/services/zones');

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function countryQuery(iso, extra = '') {
  return `[out:json][timeout:50];
area["ISO3166-1"="${iso}"][admin_level=2]->.a;
(
  relation["boundary"="low_emission_zone"](area.a);
  way["boundary"="low_emission_zone"](area.a);
  ${extra}
);
out geom qt;`;
}

const JOBS = [
  ['DE', ''],
  ['IT', 'relation["boundary"="restricted_traffic_area"](area.a); way["boundary"="restricted_traffic_area"](area.a);'],
  ['PL', ''],
  ['AT', ''],
  ['CZ', ''],
  ['SE', ''],
  ['DK', ''],
  ['NO', ''],
  ['CH', ''],
  ['GR', ''],
  ['PT', ''],
  ['NL', ''],
  ['BE', ''],
  ['FR', ''],
  ['ES', ''],
  ['GB', ''],
];

async function main() {
  const osm = [];
  for (const [iso, extra] of JOBS) {
    await sleep(8000);
    try {
      const data = await fetchOverpass(countryQuery(iso, extra), 50000);
      const parsed = parseOverpass(data);
      console.log(iso, 'elements', data.elements?.length || 0, 'zones', parsed.length);
      osm.push(...parsed);
    } catch (err) {
      console.error(iso, err.message);
    }
  }

  let national = [];
  try { national = await fetchLiveNational(); }
  catch (err) { console.error('national', err.message); }

  const bundled = loadBundled();
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
