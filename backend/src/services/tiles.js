const USER_AGENT =
  'MilieuAlert/1.0 (https://milieualert-production.up.railway.app; tiles-proxy)';

const TILE_CACHE_TTL_MS = 15 * 60 * 1000;
const TILE_CACHE_MAX = 800;
const tileCache = new Map();
const inflight = new Map();

function parseTileCoord(value) {
  const n = Number(value);
  if (!Number.isInteger(n)) return null;
  return n;
}

function isValidTile(z, x, y) {
  if (!Number.isInteger(z) || z < 0 || z > 19) return false;
  const max = 2 ** z;
  return (
    Number.isInteger(x) &&
    Number.isInteger(y) &&
    x >= 0 &&
    y >= 0 &&
    x < max &&
    y < max
  );
}

/**
 * Upstream raster tile URLs. Never returns keyless Carto (watermarked
 * "API KEY REQUIRED"). Paid keys win when present; otherwise OSM via
 * this server's User-Agent (browser OSM is 403).
 */
function resolveTileUrls(z, x, y, theme, env = process.env) {
  const dark = theme === 'dark';
  const urls = [];
  const carto = String(env.CARTO_API_KEY || '').trim();
  const maptiler = String(env.MAPTILER_KEY || '').trim();
  const stadia = String(env.STADIA_KEY || '').trim();

  if (carto) {
    const style = dark ? 'dark_all' : 'rastertiles/voyager';
    urls.push(
      `https://basemaps.cartocdn.com/${style}/${z}/${x}/${y}.png?apikey=${encodeURIComponent(carto)}`
    );
  }
  if (maptiler) {
    const style = dark ? 'streets-v2-dark' : 'streets-v2';
    urls.push(
      `https://api.maptiler.com/maps/${style}/${z}/${x}/${y}.png?key=${encodeURIComponent(maptiler)}`
    );
  }
  if (stadia) {
    const style = dark ? 'alidade_smooth_dark' : 'alidade_smooth';
    urls.push(
      `https://tiles.stadiamaps.com/tiles/${style}/${z}/${x}/${y}.png?api_key=${encodeURIComponent(stadia)}`
    );
  }
  urls.push(`https://tile.openstreetmap.org/${z}/${x}/${y}.png`);
  urls.push(`https://tile.openstreetmap.de/${z}/${x}/${y}.png`);
  urls.push(`https://a.tile.openstreetmap.fr/osmfr/${z}/${x}/${y}.png`);
  return urls;
}

function cacheGet(key) {
  const hit = tileCache.get(key);
  if (!hit) return null;
  if (Date.now() > hit.expires) {
    tileCache.delete(key);
    return null;
  }
  tileCache.delete(key);
  tileCache.set(key, hit);
  return hit;
}

function cacheSet(key, value) {
  if (tileCache.size >= TILE_CACHE_MAX) {
    const first = tileCache.keys().next().value;
    tileCache.delete(first);
  }
  tileCache.set(key, {
    ...value,
    expires: Date.now() + TILE_CACHE_TTL_MS,
  });
}

async function fetchPng(url) {
  const res = await fetch(url, {
    headers: {
      'User-Agent': USER_AGENT,
      Accept: 'image/png,image/*;q=0.8,*/*;q=0.5',
      Referer: 'https://milieualert-production.up.railway.app/',
    },
    signal: AbortSignal.timeout(8000),
  });
  if (!res.ok) {
    throw new Error(`${res.status} ${url}`);
  }
  const contentType = (res.headers.get('content-type') || 'image/png')
    .split(';')[0]
    .trim();
  if (!contentType.includes('image') && !contentType.includes('octet-stream')) {
    throw new Error(`not an image (${contentType}) ${url}`);
  }
  const buf = Buffer.from(await res.arrayBuffer());
  if (buf.length < 80) {
    throw new Error(`empty tile ${url}`);
  }
  return { buf, contentType: contentType.includes('image') ? contentType : 'image/png' };
}

async function loadTileBuffer(z, x, y, theme, env = process.env) {
  const key = `${theme}:${z}/${x}/${y}`;
  const cached = cacheGet(key);
  if (cached) return cached;

  if (inflight.has(key)) return inflight.get(key);

  const pending = (async () => {
    const urls = resolveTileUrls(z, x, y, theme, env);
    let lastErr;
    for (const url of urls) {
      try {
        const tile = await fetchPng(url);
        cacheSet(key, tile);
        return cacheGet(key) || tile;
      } catch (err) {
        lastErr = err;
      }
    }
    throw lastErr || new Error('no tile upstream');
  })().finally(() => inflight.delete(key));

  inflight.set(key, pending);
  return pending;
}

module.exports = {
  parseTileCoord,
  isValidTile,
  resolveTileUrls,
  loadTileBuffer,
  USER_AGENT,
};
