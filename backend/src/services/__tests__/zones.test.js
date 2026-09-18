const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  parseTyreMap,
  parseOverpass,
  mergeZones,
  circlePolygon,
  fromGeoJsonFeatures,
  summarize,
  makeZone,
} = require('../zones');

describe('European zone ingest', () => {
  it('parses TyreMap CSV and attaches polygons or fallback circles', () => {
    const csv = [
      'zone_slug,city,country,iso2,lat,lng,zone_type,zone_name,petrol_min_euro,diesel_min_euro,status,sticker,sticker_cost,sticker_url,fine,operating_hours,last_updated',
      'paris-zfe,Paris,France,FR,48.8566,2.3522,Crit\'Air ZFE,Paris ZFE,4,5,active,Crit\'Air,,,,24/7,2026-01',
      'old-zone,Nowhere,France,FR,48.8,2.3,LEZ,Gone,4,5,cancelled,,,,,',
    ].join('\n');
    const geo = {
      type: 'FeatureCollection',
      features: [{
        type: 'Feature',
        properties: { slug: 'paris-zfe', name: 'Paris ZFE' },
        geometry: {
          type: 'Polygon',
          coordinates: [[
            [2.2, 48.8], [2.5, 48.8], [2.5, 48.95], [2.2, 48.95], [2.2, 48.8],
          ]],
        },
      }],
    };
    const zones = parseTyreMap(csv, geo);
    assert.equal(zones.length, 1);
    assert.equal(zones[0].country, 'FR');
    assert.equal(zones[0].city, 'Paris');
    assert.equal(zones[0].geometrySource, 'tyremap');
    assert.ok(zones[0].polygonCoordinates[0].length >= 4);
    assert.equal(zones[0].minimumEuroLevel, 5);
  });

  it('builds a circle polygon when a catalog row has no geometry', () => {
    const csv = [
      'zone_slug,city,country,iso2,lat,lng,zone_type,zone_name,petrol_min_euro,diesel_min_euro,status,sticker,sticker_cost,sticker_url,fine,operating_hours,last_updated',
      'milano-area-b,Milan,Italy,IT,45.4642,9.19,ZTL,Area B,,,active,,,,,',
    ].join('\n');
    const zones = parseTyreMap(csv, { features: [] });
    assert.equal(zones.length, 1);
    assert.equal(zones[0].geometrySource, 'approx');
    assert.ok(zones[0].polygonCoordinates[0].length >= 16);
  });

  it('parses OSM overpass ways into polygons', () => {
    const zones = parseOverpass({
      elements: [{
        type: 'way',
        id: 99,
        tags: { boundary: 'low_emission_zone', name: 'Umweltzone Berlin', 'addr:city': 'Berlin', 'ISO3166-1': 'DE' },
        geometry: [
          { lat: 52.5, lon: 13.3 },
          { lat: 52.5, lon: 13.5 },
          { lat: 52.6, lon: 13.5 },
          { lat: 52.6, lon: 13.3 },
          { lat: 52.5, lon: 13.3 },
        ],
      }],
    });
    assert.equal(zones.length, 1);
    assert.equal(zones[0].country, 'DE');
    assert.equal(zones[0].city, 'Berlin');
    assert.equal(zones[0].geometrySource, 'osm');
  });

  it('prefers official geometry when merging nearby duplicates', () => {
    const approx = makeZone({
      id: 'tyre_berlin',
      country: 'DE',
      city: 'Berlin',
      name: 'Umweltzone Berlin',
      polygonCoordinates: circlePolygon(52.52, 13.405, 4000),
      geometrySource: 'approx',
    });
    const official = makeZone({
      id: 'osm_way_1',
      country: 'DE',
      city: 'Berlin',
      name: 'Umweltzone Berlin',
      polygonCoordinates: [[
        [13.3, 52.45], [13.5, 52.45], [13.5, 52.58], [13.3, 52.58], [13.3, 52.45],
      ]],
      geometrySource: 'osm',
    });
    const merged = mergeZones([[approx], [official]]);
    assert.equal(merged.length, 1);
    assert.equal(merged[0].geometrySource, 'osm');
  });

  it('reads GeoJSON national feeds', () => {
    const zones = fromGeoJsonFeatures([{
      type: 'Feature',
      properties: { id: 'ams', areaName: 'Amsterdam', name: 'Milieuzone Amsterdam', minimumEuroClassification: 'Euro 4' },
      geometry: {
        type: 'Polygon',
        coordinates: [[[4.85, 52.35], [4.95, 52.35], [4.95, 52.40], [4.85, 52.40], [4.85, 52.35]]],
      },
    }], {
      country: 'NL',
      city: 'Netherlands',
      name: 'Milieuzone',
      idPrefix: 'ndw_',
      source: 'ndw',
      geometrySource: 'ndw',
    });
    assert.equal(zones[0].city, 'Amsterdam');
    assert.equal(zones[0].minimumEuroLevel, 4);
    const summary = summarize(zones);
    assert.equal(summary.countryCount, 1);
    assert.equal(summary.byCountry.NL, 1);
  });
});
