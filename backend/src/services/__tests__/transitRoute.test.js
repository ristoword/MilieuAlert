const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { decodePolyline } = require('../polyline');
const { normalizeTravelMode } = require('../travelMode');
const {
  serializeMotisItinerary,
  hasTransitLeg,
  isWalkMode,
} = require('../transitRoute');

describe('travel mode', () => {
  it('defaults to car', () => {
    assert.equal(normalizeTravelMode(), 'car');
    assert.equal(normalizeTravelMode('auto'), 'car');
    assert.equal(normalizeTravelMode('driving'), 'car');
  });

  it('accepts foot and transit aliases', () => {
    assert.equal(normalizeTravelMode('walk'), 'foot');
    assert.equal(normalizeTravelMode('piedi'), 'foot');
    assert.equal(normalizeTravelMode('mezzi'), 'transit');
    assert.equal(normalizeTravelMode('TRANSIT'), 'transit');
  });
});

describe('polyline', () => {
  it('decodes the Google precision-5 sample', () => {
    const pts = decodePolyline('_p~iF~ps|U', 5);
    assert.equal(pts.length, 1);
    assert.ok(Math.abs(pts[0].lat - 38.5) < 0.001);
    assert.ok(Math.abs(pts[0].lon + 120.2) < 0.001);
  });
});

describe('MOTIS itinerary serialization', () => {
  const fixture = {
    duration: 900,
    startTime: '2026-09-16T16:00:00Z',
    endTime: '2026-09-16T16:15:00Z',
    transfers: 1,
    legs: [
      {
        mode: 'WALK',
        duration: 180,
        distance: 220,
        from: { name: 'Partenza', lat: 52.37, lon: 4.89 },
        to: { name: 'Dam', lat: 52.373, lon: 4.893 },
        legGeometry: { points: '', precision: 6 },
        headsign: null,
      },
      {
        mode: 'TRAM',
        duration: 480,
        distance: 2100,
        displayName: '9',
        routeShortName: '9',
        headsign: 'Nachtwachtlaan',
        from: { name: 'Dam', lat: 52.373, lon: 4.893 },
        to: { name: 'Leidseplein', lat: 52.364, lon: 4.882 },
        legGeometry: {
          points: '',
          precision: 6,
        },
      },
      {
        mode: 'WALK',
        duration: 240,
        distance: 300,
        from: { name: 'Leidseplein', lat: 52.364, lon: 4.882 },
        to: { name: 'Museo', lat: 52.36, lon: 4.88 },
        legGeometry: { points: '', precision: 6 },
      },
    ],
  };

  it('keeps board / alight / transfer facts from MOTIS, never invents lines', () => {
    const plan = serializeMotisItinerary(fixture);
    assert.equal(plan.mode, 'transit');
    assert.equal(plan.itinerary.transfers, 1);
    assert.equal(plan.itinerary.legs.length, 3);
    const tram = plan.itinerary.legs[1];
    assert.equal(tram.kind, 'transit');
    assert.equal(tram.mode, 'TRAM');
    assert.equal(tram.line, '9');
    assert.equal(tram.headsign, 'Nachtwachtlaan');
    assert.equal(tram.fromStop, 'Dam');
    assert.equal(tram.toStop, 'Leidseplein');
    assert.equal(plan.speeds.length, 0);
    const tramStep = plan.steps.find((s) => s.type === 'tram');
    assert.ok(tramStep);
    assert.equal(tramStep.name, '9');
    assert.equal(tramStep.modifier, 'Nachtwachtlaan');
    assert.equal(tramStep.alightStop, 'Leidseplein');
    const walk = plan.steps.find((s) => s.type === 'walk');
    assert.ok(walk);
    assert.equal(walk.name, 'Dam');
  });

  it('rejects walk-only itineraries as not transit', () => {
    assert.equal(hasTransitLeg({ legs: [{ mode: 'WALK' }] }), false);
    assert.equal(hasTransitLeg(fixture), true);
    assert.equal(isWalkMode('TRAM'), false);
  });
});
