const { decodePolyline } = require('./polyline');

const MOTIS_PLAN = 'https://api.transitous.org/api/v6/plan';
const WALK_MODES = new Set(['WALK', 'BIKE', 'FLEX', 'RENTAL']);

function isWalkMode(mode) {
  return WALK_MODES.has(String(mode || '').toUpperCase());
}

function modeToStepType(mode) {
  switch (String(mode || '').toUpperCase()) {
    case 'WALK':
      return 'walk';
    case 'TRAM':
      return 'tram';
    case 'BUS':
    case 'COACH':
      return 'bus';
    case 'SUBWAY':
    case 'METRO':
      return 'subway';
    case 'FERRY':
      return 'ferry';
    case 'RAIL':
    case 'HIGHSPEED_RAIL':
    case 'LONG_DISTANCE':
    case 'NIGHT_RAIL':
    case 'REGIONAL_RAIL':
    case 'REGIONAL_FAST_RAIL':
    case 'SUBURBAN':
      return 'rail';
    default:
      return isWalkMode(mode) ? 'walk' : 'transit';
  }
}

function mapWalkDirection(dir) {
  switch (String(dir || '').toUpperCase()) {
    case 'DEPART':
      return { type: 'depart', modifier: '' };
    case 'HARD_LEFT':
      return { type: 'turn', modifier: 'sharp left' };
    case 'LEFT':
      return { type: 'turn', modifier: 'left' };
    case 'SLIGHTLY_LEFT':
      return { type: 'turn', modifier: 'slight left' };
    case 'CONTINUE':
      return { type: 'continue', modifier: '' };
    case 'SLIGHTLY_RIGHT':
      return { type: 'turn', modifier: 'slight right' };
    case 'RIGHT':
      return { type: 'turn', modifier: 'right' };
    case 'HARD_RIGHT':
      return { type: 'turn', modifier: 'sharp right' };
    case 'UTURN_LEFT':
    case 'UTURN_RIGHT':
      return { type: 'turn', modifier: 'uturn' };
    case 'CIRCLE_CLOCKWISE':
    case 'CIRCLE_COUNTERCLOCKWISE':
      return { type: 'roundabout', modifier: '' };
    default:
      return { type: 'continue', modifier: '' };
  }
}

function lastCoord(geom) {
  if (!geom || !geom.points) return null;
  const pts = decodePolyline(geom.points, geom.precision || 6);
  return pts.length ? pts[pts.length - 1] : null;
}

function serializeMotisLeg(leg) {
  const from = leg.from || {};
  const to = leg.to || {};
  const geom = leg.legGeometry || {};
  const precision = Number.isFinite(geom.precision) ? geom.precision : 6;
  let points = geom.points ? decodePolyline(geom.points, precision) : [];
  if (
    !points.length &&
    Number.isFinite(from.lat) &&
    Number.isFinite(from.lon) &&
    Number.isFinite(to.lat) &&
    Number.isFinite(to.lon)
  ) {
    points = [
      { lat: from.lat, lon: from.lon },
      { lat: to.lat, lon: to.lon },
    ];
  }
  const walk = isWalkMode(leg.mode);
  const line = walk
    ? null
    : String(leg.displayName || leg.routeShortName || leg.routeLongName || '').trim() ||
      null;
  const headsign = walk ? null : String(leg.headsign || '').trim() || null;
  return {
    kind: walk ? 'walk' : 'transit',
    mode: String(leg.mode || 'WALK'),
    line,
    headsign,
    fromStop: String(from.name || '').trim(),
    toStop: String(to.name || '').trim(),
    fromLat: Number.isFinite(from.lat) ? from.lat : null,
    fromLon: Number.isFinite(from.lon) ? from.lon : null,
    toLat: Number.isFinite(to.lat) ? to.lat : null,
    toLon: Number.isFinite(to.lon) ? to.lon : null,
    distanceMeters: Number(leg.distance) || 0,
    durationSeconds: Number(leg.duration) || 0,
    startTime: leg.startTime || null,
    endTime: leg.endTime || null,
    points,
    _rawSteps: Array.isArray(leg.steps) ? leg.steps : [],
  };
}

function walkStepsFromMotis(leg) {
  const steps = [];
  const raw = leg._rawSteps || [];
  if (raw.length) {
    for (const step of raw) {
      const mapped = mapWalkDirection(step.relativeDirection);
      const end = lastCoord(step.polyline) || {
        lat: leg.toLat,
        lon: leg.toLon,
      };
      steps.push({
        type: mapped.type,
        modifier: mapped.modifier,
        name: String(step.streetName || '').trim(),
        distanceMeters: Number(step.distance) || 0,
        lat: end && Number.isFinite(end.lat) ? end.lat : leg.toLat,
        lon: end && Number.isFinite(end.lon) ? end.lon : leg.toLon,
        lanes: [],
      });
    }
  }
  const stopName = leg.toStop;
  steps.push({
    type: 'walk',
    modifier: '',
    name: stopName,
    fromStop: leg.fromStop,
    alightStop: stopName,
    distanceMeters: leg.distanceMeters,
    lat: leg.toLat,
    lon: leg.toLon,
    lanes: [],
  });
  return steps;
}

function transitStepFromLeg(leg) {
  return {
    type: modeToStepType(leg.mode),
    modifier: leg.headsign || '',
    name: leg.line || '',
    fromStop: leg.fromStop,
    alightStop: leg.toStop,
    distanceMeters: leg.distanceMeters,
    lat: leg.toLat,
    lon: leg.toLon,
    lanes: [],
  };
}

function legsToNavSteps(legs) {
  const steps = [];
  for (const leg of legs) {
    if (leg.kind === 'walk') {
      steps.push(...walkStepsFromMotis(leg));
    } else {
      steps.push(transitStepFromLeg(leg));
    }
  }
  const last = legs[legs.length - 1];
  if (last) {
    steps.push({
      type: 'arrive',
      modifier: '',
      name: last.toStop || '',
      distanceMeters: 0,
      lat: last.toLat,
      lon: last.toLon,
      lanes: [],
    });
  }
  return steps;
}

function appendPoints(target, incoming) {
  for (const p of incoming) {
    if (!Number.isFinite(p.lat) || !Number.isFinite(p.lon)) continue;
    const prev = target[target.length - 1];
    if (
      prev &&
      Math.abs(prev.lat - p.lat) < 1e-7 &&
      Math.abs(prev.lon - p.lon) < 1e-7
    ) {
      continue;
    }
    target.push({ lat: p.lat, lon: p.lon });
  }
}

function publicLeg(leg) {
  const { _rawSteps, ...rest } = leg;
  return rest;
}

function serializeMotisItinerary(it) {
  const rawLegs = Array.isArray(it && it.legs) ? it.legs : [];
  const legs = rawLegs.map(serializeMotisLeg);
  const points = [];
  let distanceMeters = 0;
  for (const leg of legs) {
    appendPoints(points, leg.points);
    distanceMeters += leg.distanceMeters;
  }
  const durationSeconds = Number(it.duration) || 0;
  return {
    mode: 'transit',
    points,
    steps: legsToNavSteps(legs),
    speeds: [],
    distanceMeters,
    durationSeconds,
    itinerary: {
      startTime: it.startTime || null,
      endTime: it.endTime || null,
      transfers: Number.isFinite(it.transfers) ? it.transfers : 0,
      legs: legs.map(publicLeg),
    },
  };
}

function hasTransitLeg(it) {
  const legs = (it && it.legs) || [];
  return legs.some((leg) => !isWalkMode(leg.mode));
}

async function fetchMotisPlan(fromLat, fromLon, toLat, toLon, { userAgent } = {}) {
  const params = new URLSearchParams({
    fromPlace: `${fromLat},${fromLon}`,
    toPlace: `${toLat},${toLon}`,
    detailedLegs: 'true',
    numItineraries: '3',
    timetableView: 'true',
  });
  params.append('transitModes', 'TRANSIT');
  params.append('directModes', 'WALK');
  const url = `${MOTIS_PLAN}?${params.toString()}`;
  const res = await fetch(url, {
    headers: {
      'User-Agent': userAgent || 'MilieuAlert/1.0',
      Accept: 'application/json',
    },
    signal: AbortSignal.timeout(20000),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`motis ${res.status} ${text.slice(0, 180)}`);
  }
  return res.json();
}

async function planTransitRoute(coords, options = {}) {
  const data = await fetchMotisPlan(
    coords.fromLat,
    coords.fromLon,
    coords.toLat,
    coords.toLon,
    options
  );
  const itineraries = Array.isArray(data.itineraries) ? data.itineraries : [];
  const withTransit = itineraries.filter(hasTransitLeg);
  return withTransit.slice(0, 3).map(serializeMotisItinerary);
}

module.exports = {
  MOTIS_PLAN,
  isWalkMode,
  modeToStepType,
  serializeMotisLeg,
  serializeMotisItinerary,
  hasTransitLeg,
  planTransitRoute,
  fetchMotisPlan,
};
