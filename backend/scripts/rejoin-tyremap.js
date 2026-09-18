const fs = require('fs');
const path = require('path');
const {
  BUNDLE_PATH,
  parseTyreMap,
  loadBundled,
  mergeZones,
  attachBetterPolygons,
  summarize,
  fetchLiveNational,
} = require('../src/services/zones');

async function main() {
  const csv = fs.readFileSync(path.join(__dirname, '../data/tmp/lez-zones.csv'), 'utf8');
  const geo = JSON.parse(fs.readFileSync(path.join(__dirname, '../data/tmp/lez-boundaries.geojson'), 'utf8'));
  const tyre = parseTyreMap(csv, geo);
  const bundled = loadBundled().filter((z) => !/^ndw_\d+$/.test(z.id));
  attachBetterPolygons(tyre, bundled);
  const national = await fetchLiveNational();
  attachBetterPolygons(tyre, national);
  const merged = mergeZones([tyre, national, bundled]);
  const coverage = summarize(merged);
  const raw = JSON.parse(fs.readFileSync(BUNDLE_PATH, 'utf8'));
  raw.generatedAt = new Date().toISOString();
  raw.coverage = coverage;
  raw.zones = merged;
  fs.writeFileSync(BUNDLE_PATH, JSON.stringify(raw));
  const barcelona = merged.filter((z) => /barcel/i.test(`${z.city} ${z.name}`));
  console.log(JSON.stringify({
    bytes: fs.statSync(BUNDLE_PATH).size,
    tyre: tyre.length,
    barcelona: barcelona.map((z) => z.country + ' ' + z.city + ' ' + z.name + ' ' + z.geometrySource),
    ...coverage,
  }, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
