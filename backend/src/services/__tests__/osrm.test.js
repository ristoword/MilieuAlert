'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { routeUrls, fetchRoute } = require('../osrm');

const pts = { fromLat: 52.1, fromLon: 4.4, toLat: 52.2, toLon: 4.5 };

test('a piedi usa il server pedonale, in auto ha una riserva', () => {
  assert.match(routeUrls('foot', pts)[0], /routed-foot/);
  const car = routeUrls('car', pts);
  assert.equal(car.length, 2);
  assert.match(car[0], /4\.4,52\.1;4\.5,52\.2/);
  assert.match(car[1], /routed-car.*annotations=speed/);
});

test('un server lento viene superato dalla riserva', async () => {
  const data = await fetchRoute(
    ['https://slow.example/r', 'https://fast.example/r'],
    {
      hedgeDelayMs: 20,
      timeoutMs: 1000,
      fetchImpl: (url, { signal }) =>
        url.includes('slow')
          ? new Promise((_, reject) =>
              signal.addEventListener('abort', () => reject(new Error('aborted'))))
          : Promise.resolve({ ok: true, json: async () => ({ routes: [1] }) }),
    }
  );
  assert.deepEqual(data.routes, [1]);
});

test('anche un corpo che non arriva mai scade', async () => {
  await assert.rejects(
    fetchRoute(['https://a.example/r'], {
      timeoutMs: 30,
      fetchImpl: async () => ({ ok: true, json: () => new Promise(() => {}) }),
    }),
    /timeout/
  );
});
