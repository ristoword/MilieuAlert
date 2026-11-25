'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const overpass = require('../overpass');

const ok = (elements, extra = {}) => ({
  ok: true,
  json: async () => ({ elements, ...extra }),
});
const pts = (n) =>
  Array.from({ length: n }, (_, i) => ({ lat: 52 + i / 1000, lon: 4.5 }));

test('chunkPath copre tutto il percorso con sovrapposizione', () => {
  const chunks = overpass.chunkPath(pts(100), 24);
  assert.deepEqual(chunks[1][0], chunks[0][23]);
  assert.deepEqual(chunks.at(-1).at(-1), pts(100)[99]);
});

test('un mirror in errore non fa perdere i semafori', async () => {
  const seen = [];
  const data = await overpass.hedgedRequest('q', {
    urls: ['https://a.example/api', 'https://b.example/api'],
    fetchImpl: async (url) => {
      seen.push(url);
      if (url.includes('a.example')) return { ok: false, status: 502 };
      return ok([{ id: 1 }]);
    },
  });
  assert.equal(data.elements.length, 1);
  assert.equal(seen.length, 2);
});

test('un mirror lento viene affiancato dal successivo', async () => {
  const data = await overpass.hedgedRequest('q', {
    urls: ['https://slow.example/api', 'https://fast.example/api'],
    hedgeDelayMs: 20,
    timeoutMs: 1000,
    fetchImpl: (url, { signal }) =>
      url.includes('slow')
        ? new Promise((_, reject) =>
            signal.addEventListener('abort', () => reject(new Error('aborted'))))
        : Promise.resolve(ok([{ id: 2 }])),
  });
  assert.equal(data.elements[0].id, 2);
});

test('un "remark" di timeout conta come errore', async () => {
  await assert.rejects(
    overpass.hedgedRequest('q', {
      urls: ['https://a.example/api'],
      fetchImpl: async () => ok([], { remark: 'runtime error: Query timed out' }),
    }),
    /timed out/
  );
});

test('elementsAlongPath restituisce i tratti riusciti', async () => {
  overpass.clearCache();
  let n = 0;
  const res = await overpass.elementsAlongPath(pts(60), {
    urls: ['https://a.example/api'],
    fetchImpl: async () => {
      n += 1;
      return n === 2 ? { ok: false, status: 429 } : ok([{ id: n }]);
    },
  });
  assert.equal(res.chunks, 3);
  assert.equal(res.failed, 1);
  assert.equal(res.elements.length, 2);
});
