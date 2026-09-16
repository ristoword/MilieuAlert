const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  serializeLanes,
  serializeOsrmRoute,
} = require('../osrmRoute');

describe('OSRM lane serialization', () => {
  it('maps intersection.lanes indications + valid without inventing lanes', () => {
    const lanes = serializeLanes({
      maneuver: { location: [9.19, 45.46], type: 'continue' },
      intersections: [
        {
          location: [9.19, 45.46],
          lanes: [
            { indications: ['straight'], valid: true },
            { indications: ['straight'], valid: true },
            { indications: ['straight', 'slight right'], valid: false },
            { indications: ['slight right'], valid: false },
          ],
        },
      ],
    });
    assert.equal(lanes.length, 4);
    assert.deepEqual(lanes[0], { indications: ['straight'], valid: true });
    assert.equal(lanes[2].valid, false);
    assert.deepEqual(lanes[2].indications, ['straight', 'slight right']);
  });

  it('returns no lanes when OSRM omitted them', () => {
    const lanes = serializeLanes({
      maneuver: { location: [4.3, 52.0], type: 'turn', modifier: 'right' },
      intersections: [{ location: [4.3, 52.0], bearings: [0, 90] }],
    });
    assert.deepEqual(lanes, []);
  });

  it('attaches lanes onto serialized route steps', () => {
    const route = serializeOsrmRoute({
      distance: 100,
      duration: 20,
      geometry: { coordinates: [[4.32, 52.0], [4.32, 52.01]] },
      legs: [
        {
          steps: [
            {
              name: 'A4',
              distance: 80,
              duration: 10,
              maneuver: { type: 'continue', modifier: '', location: [4.32, 52.0] },
              intersections: [
                {
                  location: [4.32, 52.0],
                  lanes: [
                    { indications: ['left'], valid: true },
                    { indications: ['straight'], valid: false },
                  ],
                },
              ],
            },
          ],
        },
      ],
    });
    assert.equal(route.steps[0].lanes.length, 2);
    assert.equal(route.steps[0].lanes[0].valid, true);
  });
});
