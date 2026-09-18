const fs = require('fs');
const {
  BUNDLE_PATH,
  loadBundled,
  fetchLiveNational,
  attachBetterPolygons,
  mergeZones,
  summarize,
} = require('../src/services/zones');

async function main() {
  const bundled = loadBundled().filter((z) => !/^ndw_\d+$/.test(z.id));
  const national = await fetchLiveNational();
  attachBetterPolygons(bundled, national);
  const merged = mergeZones([bundled, national]);
  const coverage = summarize(merged);
  const raw = JSON.parse(fs.readFileSync(BUNDLE_PATH, 'utf8'));
  raw.generatedAt = new Date().toISOString();
  raw.coverage = coverage;
  raw.zones = merged;
  fs.writeFileSync(BUNDLE_PATH, JSON.stringify(raw));
  const nl = merged.filter((z) => z.country === 'NL').map((z) => z.city);
  console.log(JSON.stringify({
    bytes: fs.statSync(BUNDLE_PATH).size,
    national: national.length,
    nlCities: [...new Set(nl)].sort(),
    ...coverage,
  }, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
