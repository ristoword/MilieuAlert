'use strict';

/**
 * Road routing on public OSRM servers. A slow answer is raced against a second
 * server, so one overloaded host cannot hold the driver for a minute.
 */

const QUERY =
  '?overview=full&geometries=geojson&alternatives=true&steps=true';
const HEDGE_DELAY_MS = 4000;
const TIMEOUT_MS = 25000;

/** Servers for a mode, preferred first. */
function routeUrls(mode, { fromLat, fromLon, toLat, toLon }) {
  const path = `${fromLon},${fromLat};${toLon},${toLat}`;
  const extras = mode === 'car' ? '&annotations=speed' : '';
  const demo = (profile) =>
    `https://router.project-osrm.org/route/v1/${profile}/${path}${QUERY}${extras}`;
  const fossgis = (server, profile) =>
    `https://routing.openstreetmap.de/${server}/route/v1/${profile}/${path}${QUERY}${extras}`;
  // The demo server only knows roads for cars, even under its "foot" profile.
  return mode === 'foot'
    ? [fossgis('routed-foot', 'foot'), demo('foot')]
    : [demo('driving'), fossgis('routed-car', 'driving')];
}

function fetchRoute(urls, options = {}) {
  const {
    fetchImpl = fetch,
    hedgeDelayMs = HEDGE_DELAY_MS,
    timeoutMs = TIMEOUT_MS,
    userAgent = 'MilieuAlert/1.0',
  } = options;
  return new Promise((resolve, reject) => {
    const ctrl = new AbortController();
    let next = 0;
    let pending = 0;
    let done = false;
    let lastErr = new Error('routing timeout');
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
    const one = async (url) => {
      const res = await fetchImpl(url, {
        signal: ctrl.signal,
        headers: { 'User-Agent': userAgent, Accept: 'application/json' },
      });
      if (!res.ok) {
        throw new Error(`routing HTTP ${res.status} (${new URL(url).hostname})`);
      }
      // The body of a long route is large: it is covered by the deadline too.
      return res.json();
    };
    const launch = () => {
      clearTimeout(hedge);
      if (done || next >= urls.length) return;
      const url = urls[next++];
      pending++;
      hedge = setTimeout(launch, hedgeDelayMs);
      one(url).then(
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

module.exports = { routeUrls, fetchRoute };
