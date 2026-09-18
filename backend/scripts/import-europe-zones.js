/**
 * Builds backend/data/europe-zones.json from open LEZ sources.
 * Run: node scripts/import-europe-zones.js
 */
const fs = require('fs');
const path = require('path');
const {
  BUNDLE_PATH,
  buildFullDataset,
  summarize,
  SOURCES,
} = require('../src/services/zones');

async function main() {
  console.log('Importing European LEZ / Umweltzone / ZFE / ZTL / ULEZ / milieuzone data...');
  const zones = await buildFullDataset({ includeOsm: true });
  const coverage = summarize(zones);
  const payload = {
    generatedAt: new Date().toISOString(),
    attribution: [
      'TyreMap Europe emission zones (CC BY 4.0) — https://tyremap.com',
      'OpenStreetMap contributors (ODbL) — boundary=low_emission_zone and Italian ZTL',
      'NDW Netherlands emission zones (CC0)',
      'Antwerpen / Brussels / Gent official LEZ GeoJSON',
      'Base nationale consolidée des ZFE, transport.data.gouv.fr (Licence Ouverte)',
    ],
    sources: SOURCES,
    coverage,
    zones,
  };
  fs.mkdirSync(path.dirname(BUNDLE_PATH), { recursive: true });
  fs.writeFileSync(BUNDLE_PATH, JSON.stringify(payload));
  const bytes = fs.statSync(BUNDLE_PATH).size;
  console.log(JSON.stringify({
    file: BUNDLE_PATH,
    bytes,
    ...coverage,
  }, null, 2));
  const required = ['NL', 'BE', 'DE', 'FR', 'IT', 'ES', 'GB', 'AT', 'SE', 'DK', 'PL', 'CZ', 'PT', 'CH', 'NO'];
  const missing = required.filter((iso) => !coverage.byCountry[iso]);
  if (missing.length) {
    console.warn('Missing required countries in snapshot:', missing.join(', '));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
