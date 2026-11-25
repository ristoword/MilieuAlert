'use strict';

/**
 * Overpass (OpenStreetMap) client for cameras, speed limits and traffic lights.
 * Public mirrors fail often, so requests are hedged across several of them and
 * successful answers are cached.
 */

const crypto = require('crypto');

const DEFAULT_ENDPOINTS = [
  'https://overpass.openstreetmap.fr/api/interpreter',
  'https://overpass-api.de/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
];
const USER_AGENT =
  'MilieuAlert/1.0 (https://milieualert-production.up.railway.app)';

const MAX_PATH_POINTS = 200;
const CHUNK_POINTS = 24;
const CHUNK_CONCURRENCY = 3;
const HEDGE_DELAY_MS = 4000;
const CACHE_TTL_MS = 30 * 60 * 1000;
const CACHE_MAX = 400;
const cache = new Map();

function endpoints(env = process.env) {
  const custom = String(env.OVERPASS_ENDPOINTS || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  return custom.length ? custom : DEFAULT_ENDPOINTS;
}

/** Overlapping slices so no stretch of road falls between two requests. */
function chunkPath(points, size = CHUNK_POINTS) {
  if (points.length <= size) return points.length ? [points] : [];
  const out = [];
  for (let i = 0; i < points.length - 1; i += size - 1) {
    out.push(points.slice(i, i + size));
  }
  return out;
}

/** `around` with a coordinate list follows the line between the samples. */
function pathQuery(points) {
  const line = points
    .map((p) => `${p.lat.toFixed(5)},${p.lon.toFixed(5)}`)
    .join(',');
  return `[out:json][timeout:15];
(
  node(around:60,${line})["highway"~"^(speed_camera|traffic_signals)$"];
  node(around:180,${line})["enforcement"="maxspeed"];
  way(around:40,${line})["highway"]["maxspeed"];
);
out body center;`;
}

async function requestOne(url, query, signal, fetchImpl) {
  const res = await fetchImpl(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'text/plain',
      Accept: 'application/json',
      'User-Agent': USER_AGENT,
    },
    body: query,
    signal,
  });
  const host = new URL(url).hostname;
  if (!res.ok) throw new Error(`overpass HTTP ${res.status} (${host})`);
  const data = await res.json();
  // Overpass reports query timeouts as 200 + "remark" with partial/no data.
  if (data.remark && /error|timed out/i.test(data.remark)) {
    throw new Error(`overpass ${data.remark} (${host})`);
  }
  return data;
}

/**
 * First good answer wins. The next mirror starts as soon as the previous one
 * fails, or after [hedgeDelayMs] if it is merely slow.
 */
function hedgedRequest(query, options = {}) {
  const {
    timeoutMs = 14000,
    hedgeDelayMs = HEDGE_DELAY_MS,
    fetchImpl = fetch,
    urls = endpoints(),
  } = options;
  return new Promise((resolve, reject) => {
    const ctrl = new AbortController();
    let next = 0;
    let pending = 0;
    let done = false;
    let lastErr = new Error('overpass timeout');
    let hedge = null;
    let deadline = null;
    const finish = (fn, value) => {
      if (done) return;
      done = true;
      clearTimeout(hedge);
      clearTimeout(deadline);
      ctrl.abort();
      fn(value);
    };
    deadline = setTimeout(() => finish(reject, lastErr), timeoutMs);
    const launch = () => {
      clearTimeout(hedge);
      if (done || next >= urls.length) return;
      const url = urls[next++];
      pending++;
      hedge = setTimeout(launch, hedgeDelayMs);
      requestOne(url, query, ctrl.signal, fetchImpl).then(
        (data) => finish(resolve, data),
        (err) => {
          pending--;
          if (done) return;
          lastErr = err;
          if (next < urls.length) launch();
          else if (pending === 0) finish(reject, err);
        }
      );
    };
    launch();
  });
}

async function queryOverpass(query, options = {}) {
  const key = crypto.createHash('sha1').update(query).digest('hex');
  const hit = cache.get(key);
  if (hit && hit.expires > Date.now()) return hit.data;
  const data = await hedgedRequest(query, options);
  if (cache.size >= CACHE_MAX) cache.delete(cache.keys().next().value);
  cache.set(key, { data, expires: Date.now() + CACHE_TTL_MS });
  return data;
}

/**
 * Elements along a route. Chunks that fail are skipped, so a long route still
 * returns what could be loaded. Stops starting new chunks after [budgetMs].
 */
async function elementsAlongPath(points, options = {}) {
  const { budgetMs = 26000, ...request } = options;
  const chunks = chunkPath(points);
  const startedAt = Date.now();
  const results = new Array(chunks.length);
  let cursor = 0;
  let failed = 0;
  let lastError = null;
  const worker = async () => {
    while (cursor < chunks.length) {
      const i = cursor++;
      const left = budgetMs - (Date.now() - startedAt);
      if (left < 1500) {
        failed++;
        continue;
      }
      try {
        const data = await queryOverpass(pathQuery(chunks[i]), {
          ...request,
          timeoutMs: Math.min(request.timeoutMs || 14000, left),
        });
        results[i] = data.elements || [];
      } catch (err) {
        failed++;
        lastError = err;
      }
    }
  };
  await Promise.all(
    Array.from({ length: Math.min(CHUNK_CONCURRENCY, chunks.length) }, worker)
  );
  return {
    elements: results.filter(Boolean).flat(),
    chunks: chunks.length,
    failed,
    lastError,
  };
}

function clearCache() {
  cache.clear();
}

module.exports = {
  MAX_PATH_POINTS,
  chunkPath,
  pathQuery,
  hedgedRequest,
  queryOverpass,
  elementsAlongPath,
  clearCache,
};
