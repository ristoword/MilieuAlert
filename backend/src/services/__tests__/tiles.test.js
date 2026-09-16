const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { isValidTile, parseTileCoord, resolveTileUrls } = require('../tiles');

describe('map tile proxy', () => {
  it('never uses Carto without an API key', () => {
    const urls = resolveTileUrls(12, 2100, 1345, 'light', {});
    assert.ok(urls.every((u) => !u.includes('cartocdn.com')));
    assert.ok(urls.every((u) => !u.includes('carto.com')));
    assert.ok(urls.some((u) => u.includes('tile.openstreetmap.org')));
  });

  it('uses Carto Voyager/dark only when CARTO_API_KEY is set', () => {
    const light = resolveTileUrls(8, 10, 10, 'light', { CARTO_API_KEY: 'abc' });
    const dark = resolveTileUrls(8, 10, 10, 'dark', { CARTO_API_KEY: 'abc' });
    assert.match(light[0], /basemaps\.cartocdn\.com\/rastertiles\/voyager\/8\/10\/10\.png\?apikey=abc/);
    assert.match(dark[0], /basemaps\.cartocdn\.com\/dark_all\/8\/10\/10\.png\?apikey=abc/);
    assert.ok(light.some((u) => u.includes('tile.openstreetmap.org')));
  });

  it('prefers MapTiler and Stadia keys when present', () => {
    const urls = resolveTileUrls(3, 1, 2, 'dark', {
      MAPTILER_KEY: 'mt',
      STADIA_KEY: 'st',
    });
    assert.match(urls[0], /api\.maptiler\.com\/maps\/streets-v2-dark\/3\/1\/2\.png\?key=mt/);
    assert.match(urls[1], /tiles\.stadiamaps\.com\/tiles\/alidade_smooth_dark\/3\/1\/2\.png\?api_key=st/);
  });

  it('rejects invalid tile coordinates', () => {
    assert.equal(parseTileCoord('12'), 12);
    assert.equal(parseTileCoord('12.1'), null);
    assert.equal(isValidTile(12, 0, 0), true);
    assert.equal(isValidTile(2, 4, 0), false);
    assert.equal(isValidTile(20, 0, 0), false);
    assert.equal(isValidTile(-1, 0, 0), false);
  });
});
