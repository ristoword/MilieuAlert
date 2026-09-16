const HAZARD_TYPES = {
  camera_fixed: {
    ttlMs: 24 * 3600 * 1000,
    extendMs: 6 * 3600 * 1000,
    maxTtlMs: 7 * 24 * 3600 * 1000,
    camera: true,
  },
  camera_mobile: {
    ttlMs: 2 * 3600 * 1000,
    extendMs: 30 * 60 * 1000,
    maxTtlMs: 8 * 3600 * 1000,
    camera: true,
  },
  accident: {
    ttlMs: 1 * 3600 * 1000,
    extendMs: 20 * 60 * 1000,
    maxTtlMs: 3 * 3600 * 1000,
    camera: false,
  },
  jam: {
    ttlMs: 45 * 60 * 1000,
    extendMs: 15 * 60 * 1000,
    maxTtlMs: 2 * 3600 * 1000,
    camera: false,
  },
  police: {
    ttlMs: 1 * 3600 * 1000,
    extendMs: 20 * 60 * 1000,
    maxTtlMs: 3 * 3600 * 1000,
    camera: false,
  },
  road_closed: {
    ttlMs: 3 * 3600 * 1000,
    extendMs: 60 * 60 * 1000,
    maxTtlMs: 12 * 3600 * 1000,
    camera: false,
  },
  lez_extra: {
    ttlMs: 12 * 3600 * 1000,
    extendMs: 4 * 3600 * 1000,
    maxTtlMs: 48 * 3600 * 1000,
    camera: false,
  },
};

const CAMERA_TYPES = Object.keys(HAZARD_TYPES).filter(
  (t) => HAZARD_TYPES[t].camera
);

const ANON_AUTHOR = 'un conducente';
const NOTE_MAX = 280;
const COMMENT_MAX = 140;
const REPORT_RATE_WINDOW_MS = 15 * 60 * 1000;
const REPORT_RATE_MAX = 8;
const DUPLICATE_METERS = 80;
const DUPLICATE_WINDOW_MS = 20 * 60 * 1000;
const DENY_HIDE_THRESHOLD = 3;
const DENY_CLEAR_MARGIN = 1;
const SUPPRESS_WINDOW_MS = 7 * 24 * 3600 * 1000;

/** Active, not vote-suppressed. Used in GET nearby / camera merge. */
const VISIBLE_HAZARD_SQL = `
  expires_at > NOW()
  AND deny_count < ${DENY_HIDE_THRESHOLD}
  AND (deny_count < 2 OR deny_count <= confirm_count)
`;

function isHazardType(type) {
  return Object.prototype.hasOwnProperty.call(HAZARD_TYPES, type);
}

function isCameraType(type) {
  return CAMERA_TYPES.includes(type);
}

function ttlMsFor(type) {
  return (HAZARD_TYPES[type] || HAZARD_TYPES.accident).ttlMs;
}

function expiresAtFrom(type, now = new Date()) {
  return new Date(now.getTime() + ttlMsFor(type));
}

function clampNote(raw) {
  if (raw == null) return null;
  const text = String(raw).replace(/\s+/g, ' ').trim();
  if (!text) return null;
  return text.slice(0, NOTE_MAX);
}

function clampComment(raw) {
  const text = String(raw || '').replace(/\s+/g, ' ').trim();
  return text.slice(0, COMMENT_MAX);
}

function voterKey({ userId, deviceId }) {
  if (userId) return `u:${userId}`;
  const id = String(deviceId || '').trim();
  if (id.length >= 8) return `d:${id.slice(0, 64)}`;
  return null;
}

function haversineMeters(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const toRad = (d) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function bboxDelta(radiusMeters) {
  const r = Math.min(25000, Math.max(200, Number(radiusMeters) || 4000));
  return r / 111000;
}

function shouldExpireFromVotes(confirmCount, denyCount) {
  const denies = Number(denyCount) || 0;
  const confirms = Number(confirmCount) || 0;
  if (denies >= DENY_HIDE_THRESHOLD) return true;
  return denies >= 2 && denies >= confirms + DENY_CLEAR_MARGIN;
}

function nextExpiryOnConfirm(type, currentExpiresAt, now = new Date()) {
  const spec = HAZARD_TYPES[type] || HAZARD_TYPES.accident;
  const current = new Date(currentExpiresAt).getTime();
  const extended = Math.max(current, now.getTime()) + spec.extendMs;
  const cap = now.getTime() + spec.maxTtlMs;
  return new Date(Math.min(extended, cap));
}

function toPublicReport(row, origin) {
  const lat = Number(row.lat);
  const lon = Number(row.lon);
  let distanceMeters = null;
  if (
    origin &&
    Number.isFinite(origin.lat) &&
    Number.isFinite(origin.lon) &&
    Number.isFinite(lat) &&
    Number.isFinite(lon)
  ) {
    distanceMeters = Math.round(
      haversineMeters(origin.lat, origin.lon, lat, lon)
    );
  }
  return {
    id: String(row.id),
    type: row.type,
    lat,
    lon,
    heading: row.heading == null ? null : Number(row.heading),
    note: row.note || null,
    createdAt: row.created_at,
    expiresAt: row.expires_at,
    confirmCount: Number(row.confirm_count) || 0,
    denyCount: Number(row.deny_count) || 0,
    source: 'community',
    author: ANON_AUTHOR,
    distanceMeters,
  };
}

function toPublicComment(row) {
  return {
    id: String(row.id),
    text: row.body,
    createdAt: row.created_at,
    author: ANON_AUTHOR,
  };
}

function toCommunityCamera(row) {
  return {
    id: `c-${row.id}`,
    lat: Number(row.lat),
    lon: Number(row.lon),
    maxspeed: null,
    source: 'community',
    type: row.type,
    confirmCount: Number(row.confirm_count) || 0,
    reportId: String(row.id),
  };
}

function mergeCameras(osmCameras, communityRows, limit = 200) {
  const out = [];
  const seen = new Set();
  for (const cam of osmCameras || []) {
    const id = String(cam.id);
    if (seen.has(id)) continue;
    seen.add(id);
    out.push({
      id,
      lat: cam.lat,
      lon: cam.lon,
      maxspeed: cam.maxspeed || null,
      source: cam.source || 'osm',
    });
    if (out.length >= limit) return out;
  }
  for (const row of communityRows || []) {
    const cam = toCommunityCamera(row);
    if (seen.has(cam.id)) continue;
    seen.add(cam.id);
    out.push(cam);
    if (out.length >= limit) break;
  }
  return out;
}

module.exports = {
  HAZARD_TYPES,
  CAMERA_TYPES,
  ANON_AUTHOR,
  NOTE_MAX,
  COMMENT_MAX,
  REPORT_RATE_WINDOW_MS,
  REPORT_RATE_MAX,
  DUPLICATE_METERS,
  DUPLICATE_WINDOW_MS,
  DENY_HIDE_THRESHOLD,
  SUPPRESS_WINDOW_MS,
  VISIBLE_HAZARD_SQL,
  isHazardType,
  isCameraType,
  ttlMsFor,
  expiresAtFrom,
  clampNote,
  clampComment,
  voterKey,
  haversineMeters,
  bboxDelta,
  shouldExpireFromVotes,
  nextExpiryOnConfirm,
  toPublicReport,
  toPublicComment,
  toCommunityCamera,
  mergeCameras,
};
