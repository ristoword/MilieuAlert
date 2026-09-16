function sameCoord(a, b) {
  return (
    Array.isArray(a) &&
    Array.isArray(b) &&
    a.length >= 2 &&
    b.length >= 2 &&
    Math.abs(a[0] - b[0]) < 1e-5 &&
    Math.abs(a[1] - b[1]) < 1e-5
  );
}

function mapLane(lane) {
  const indications = Array.isArray(lane && lane.indications)
    ? lane.indications.map((v) => String(v || '').trim()).filter(Boolean)
    : [];
  return {
    indications,
    valid: !!(lane && lane.valid),
  };
}

/**
 * Real OSRM turn lanes for a step. Never invents lanes when the
 * intersection has none.
 */
function serializeLanes(step) {
  const intersections = (step && step.intersections) || [];
  if (!intersections.length) return [];
  const maneuverLoc = (step.maneuver && step.maneuver.location) || [];
  let fallback = null;
  for (const it of intersections) {
    if (!Array.isArray(it.lanes) || it.lanes.length === 0) continue;
    const mapped = it.lanes.map(mapLane);
    if (sameCoord(it.location, maneuverLoc)) return mapped;
    if (!fallback) fallback = mapped;
  }
  return fallback || [];
}

function serializeOsrmRoute(route, options = {}) {
  const includeLanes = options.includeLanes !== false;
  const includeSpeeds = options.includeSpeeds !== false;
  const mode = options.mode || 'car';
  const points = ((route && route.geometry && route.geometry.coordinates) || []).map(
    (c) => ({ lon: c[0], lat: c[1] })
  );
  const steps = [];
  for (const leg of (route && route.legs) || []) {
    for (const step of leg.steps || []) {
      const loc = (step.maneuver && step.maneuver.location) || [];
      steps.push({
        instruction: step.maneuver
          ? `${step.maneuver.type || ''} ${step.maneuver.modifier || ''}`.trim()
          : 'continue',
        type: (step.maneuver && step.maneuver.type) || 'continue',
        modifier: (step.maneuver && step.maneuver.modifier) || '',
        name: step.name || '',
        distanceMeters: step.distance || 0,
        durationSeconds: step.duration || 0,
        lat: loc[1],
        lon: loc[0],
        lanes: includeLanes ? serializeLanes(step) : [],
      });
    }
  }
  const speeds = includeSpeeds
    ? (route.legs || []).flatMap(
        (leg) => (leg.annotation && leg.annotation.speed) || []
      )
    : [];
  return {
    mode,
    points,
    steps,
    speeds,
    distanceMeters: route.distance || 0,
    durationSeconds: route.duration || 0,
  };
}

module.exports = { serializeLanes, serializeOsrmRoute, mapLane };
