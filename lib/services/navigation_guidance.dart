import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../models/navigation_models.dart';
import 'geo_utils.dart';

const double kOffRouteMeters = 50;
const double kOffRouteHeadingMeters = 28;
const double kWrongHeadingDegrees = 50;
const double kMissedTurnMeters = 20;
const double kPassManeuverMeters = 32;
const double kHeadingAdvanceCone = 35;
const double kHeadingAdvanceWindow = 40;
const double kArriveAccuracyMeters = 50;
const double kArriveCrowMeters = 40;

/// Precomputed lengths used to snap GPS onto a route every fix.
class RouteMetrics {
  final List<LatLng> route;
  final List<double> cum;
  final List<double> stepAlong;
  final double totalMeters;

  const RouteMetrics({
    required this.route,
    required this.cum,
    required this.stepAlong,
    required this.totalMeters,
  });

  factory RouteMetrics.build(List<LatLng> route, List<NavStep> steps) {
    final cum = cumulativeDistances(route);
    final total = cum.isEmpty ? 0.0 : cum.last;
    return RouteMetrics(
      route: route,
      cum: cum,
      stepAlong: locateSteps(steps, route, cum),
      totalMeters: total,
    );
  }
}

class PolylineSnap {
  final int segmentIndex;
  final double t;
  final double lat;
  final double lon;
  final double alongMeters;
  final double remainingMeters;
  final double offsetMeters;

  const PolylineSnap({
    required this.segmentIndex,
    required this.t,
    required this.lat,
    required this.lon,
    required this.alongMeters,
    required this.remainingMeters,
    required this.offsetMeters,
  });
}

class GuidanceFix {
  final int stepIndex;
  final NavStep? currentStep;
  final double metersToManeuver;
  final double remainingMeters;
  final double alongMeters;
  final double offRouteMeters;
  final bool offRoute;
  final bool headingDiverged;
  final int segmentIndex;

  const GuidanceFix({
    required this.stepIndex,
    required this.currentStep,
    required this.metersToManeuver,
    required this.remainingMeters,
    required this.alongMeters,
    required this.offRouteMeters,
    required this.offRoute,
    this.headingDiverged = false,
    this.segmentIndex = 0,
  });
}

List<double> cumulativeDistances(List<LatLng> route) {
  if (route.isEmpty) return const [];
  final cum = List<double>.filled(route.length, 0);
  for (var i = 1; i < route.length; i++) {
    cum[i] = cum[i - 1] +
        haversineMeters(
          route[i - 1].latitude,
          route[i - 1].longitude,
          route[i].latitude,
          route[i].longitude,
        );
  }
  return cum;
}

/// Nearest point on [route]. Optionally restrict the search to an along-route window.
PolylineSnap? projectOntoPolyline(
  double lat,
  double lon,
  List<LatLng> route,
  List<double> cum, {
  double minAlong = 0,
  double? maxAlong,
}) {
  if (route.length < 2 || cum.length != route.length) return null;
  final total = cum.last;
  final cap = maxAlong ?? total;
  final metersPerDegLat = 111320.0;
  final metersPerDegLon =
      111320.0 * cos(lat * pi / 180).clamp(0.2, 1.0);

  double toX(double lng) => (lng - lon) * metersPerDegLon;
  double toY(double la) => (la - lat) * metersPerDegLat;

  var bestDist2 = double.infinity;
  var bestSeg = 0;
  var bestT = 0.0;
  var bestAlong = 0.0;
  var bestLat = route.first.latitude;
  var bestLon = route.first.longitude;

  for (var i = 0; i < route.length - 1; i++) {
    final segLen = cum[i + 1] - cum[i];
    final segEnd = cum[i + 1];
    if (segEnd < minAlong - 1) continue;
    if (cum[i] > cap + 1) continue;

    final ax = toX(route[i].longitude);
    final ay = toY(route[i].latitude);
    final bx = toX(route[i + 1].longitude);
    final by = toY(route[i + 1].latitude);
    final abx = bx - ax;
    final aby = by - ay;
    final ab2 = abx * abx + aby * aby;
    var t = 0.0;
    if (ab2 > 1e-6) {
      t = ((-ax) * abx + (-ay) * aby) / ab2;
      if (t < 0) t = 0;
      if (t > 1) t = 1;
    }
    final qx = ax + t * abx;
    final qy = ay + t * aby;
    final d2 = qx * qx + qy * qy;
    final along = cum[i] + t * segLen;
    if (along < minAlong - 2 || along > cap + 2) continue;
    if (d2 < bestDist2) {
      bestDist2 = d2;
      bestSeg = i;
      bestT = t;
      bestAlong = along;
      bestLat = route[i].latitude +
          t * (route[i + 1].latitude - route[i].latitude);
      bestLon = route[i].longitude +
          t * (route[i + 1].longitude - route[i].longitude);
    }
  }

  if (!bestDist2.isFinite) return null;
  return PolylineSnap(
    segmentIndex: bestSeg,
    t: bestT,
    lat: bestLat,
    lon: bestLon,
    alongMeters: bestAlong.clamp(0, total).toDouble(),
    remainingMeters: (total - bestAlong).clamp(0, total).toDouble(),
    offsetMeters: sqrt(bestDist2),
  );
}

List<double> locateSteps(
  List<NavStep> steps,
  List<LatLng> route,
  List<double> cum,
) {
  if (steps.isEmpty) return const [];
  final total = cum.isEmpty ? 0.0 : cum.last;
  var osrmAcc = 0.0;
  final osrmAlong = List<double>.filled(steps.length, 0);
  for (var i = 0; i < steps.length; i++) {
    osrmAlong[i] = osrmAcc;
    osrmAcc += steps[i].distanceMeters;
  }
  final scale = (osrmAcc > 1 && total > 1) ? total / osrmAcc : 1.0;
  final along = [for (final v in osrmAlong) v * scale];
  var minAlong = 0.0;
  for (var i = 0; i < steps.length; i++) {
    final expected = along[i];
    final step = steps[i];
    if (step.lat != null && step.lon != null && route.length >= 2) {
      final snap = projectOntoPolyline(
        step.lat!,
        step.lon!,
        route,
        cum,
        minAlong: max(0, max(minAlong, expected - 250)),
        maxAlong: min(total, expected + 250),
      );
      if (snap != null && snap.offsetMeters < 80) {
        along[i] = max(minAlong, snap.alongMeters);
      } else {
        along[i] = expected.clamp(minAlong, total).toDouble();
      }
    } else {
      along[i] = expected.clamp(minAlong, total).toDouble();
    }
    minAlong = along[i];
  }
  return along;
}

double bearingAlongRoute(
  List<LatLng> route,
  List<double> cum,
  double alongMeters, {
  double lookAheadMeters = 18,
}) {
  if (route.length < 2 || cum.length != route.length) return 0;
  final target = alongMeters + lookAheadMeters;
  final total = cum.last;
  final at = target.clamp(0, total).toDouble();
  for (var i = 0; i < route.length - 1; i++) {
    if (cum[i + 1] + 0.5 < at && i < route.length - 2) continue;
    return bearingDegrees(
      route[i].latitude,
      route[i].longitude,
      route[i + 1].latitude,
      route[i + 1].longitude,
    );
  }
  return bearingDegrees(
    route[route.length - 2].latitude,
    route[route.length - 2].longitude,
    route.last.latitude,
    route.last.longitude,
  );
}

double? _usableCourseHeading(double? heading) {
  if (heading == null || !heading.isFinite) return null;
  if (heading < 0 || heading > 360) return null;
  return heading;
}

/// Bearing that should sit at the top of the screen in course-up / heading-up.
/// Prefers the polyline tangent ahead of the puck; falls back to GPS heading
/// when off-route or when there is no line to follow.
double? courseUpBearing({
  required double lat,
  required double lon,
  double? gpsHeading,
  required List<LatLng> route,
  List<double>? cum,
  double offRouteMeters = kOffRouteMeters,
  double lookAheadMeters = 16,
}) {
  final fallback = _usableCourseHeading(gpsHeading);
  if (route.length < 2) return fallback;
  final distances = cum ?? cumulativeDistances(route);
  if (distances.length != route.length) return fallback;
  final snap = projectOntoPolyline(lat, lon, route, distances);
  if (snap == null || snap.offsetMeters > offRouteMeters) return fallback;
  final tangent = bearingAlongRoute(
    route,
    distances,
    snap.alongMeters,
    lookAheadMeters: lookAheadMeters,
  );
  // Don't glue heading-up to the old polyline while the user is turning away.
  if (fallback != null &&
      snap.offsetMeters >= 12 &&
      headingDelta(fallback, tangent) > kWrongHeadingDegrees) {
    return fallback;
  }
  return tangent;
}

double headingDelta(double a, double b) {
  var diff = (a - b).abs() % 360;
  if (diff > 180) diff = 360 - diff;
  return diff;
}

/// GPS speed in km/h. Null when the fix has no usable speed.
int? gpsSpeedKmh(double? speedMps) {
  if (speedMps == null || !speedMps.isFinite || speedMps < 0) return null;
  return (speedMps * 3.6).round().clamp(0, 320);
}

const _legalBuckets = [20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130];

/// Snap a typical-speed sample to a posted-limit bucket, or null.
int? snapLegalLimitKmh(double kmh) {
  if (!kmh.isFinite || kmh < 15 || kmh > 140) return null;
  int? best;
  var bestDiff = 8.0;
  for (final v in _legalBuckets) {
    final d = (kmh - v).abs();
    if (d < bestDiff) {
      bestDiff = d;
      best = v;
    }
  }
  return best;
}

/// Posted maxspeed for the road the puck is on: last OSM limit passed on
/// the polyline, else a nearby upcoming one, else a rounded OSRM sample.
int? currentSpeedLimitKmh({
  required double alongMeters,
  required List<LatLng> route,
  required List<double> cum,
  required List<SpeedLimitPoint> limits,
  List<double> annotationSpeeds = const [],
  int? segmentIndex,
}) {
  int? behind;
  var behindAlong = -1e9;
  int? ahead;
  var aheadDelta = 1e9;
  for (final p in limits) {
    final snap = projectOntoPolyline(p.lat, p.lon, route, cum);
    if (snap == null || snap.offsetMeters > 90) continue;
    final delta = snap.alongMeters - alongMeters;
    if (delta <= 50) {
      if (snap.alongMeters >= behindAlong) {
        behindAlong = snap.alongMeters;
        behind = p.maxspeed;
      }
    } else if (delta < 180 && delta < aheadDelta) {
      aheadDelta = delta;
      ahead = p.maxspeed;
    }
  }
  if (behind != null) return behind;
  if (ahead != null) return ahead;

  if (annotationSpeeds.isEmpty) return null;
  var idx = segmentIndex ?? 0;
  if (idx < 0) idx = 0;
  if (idx >= annotationSpeeds.length) idx = annotationSpeeds.length - 1;
  final mps = annotationSpeeds[idx];
  if (!mps.isFinite || mps <= 0) return null;
  return snapLegalLimitKmh(mps <= 80 ? mps * 3.6 : mps);
}

/// True when the puck is close enough, with a trustworthy fix, to say "arrived".
/// Noisy web GPS must not announce arrival; it must not delay off-route.
bool shouldAnnounceArrival({
  required bool offRoute,
  required double crowToTarget,
  double? accuracy,
}) {
  if (offRoute) return false;
  if (crowToTarget > 80) return false;
  final acc = accuracy ?? 0;
  if (acc >= kArriveAccuracyMeters && crowToTarget > kArriveCrowMeters) {
    return false;
  }
  return true;
}

bool _missedManeuver({
  required double along,
  required double offset,
  required double? course,
  required List<NavStep> steps,
  required RouteMetrics m,
}) {
  if (course == null) return false;
  for (var i = 0; i < steps.length; i++) {
    final step = steps[i];
    if (!step.isManeuver || step.type == 'arrive') continue;
    final at = i < m.stepAlong.length ? m.stepAlong[i] : m.totalMeters;
    if (along > at + 40) continue;
    if (along < at - 55) break;
    final incoming = bearingAlongRoute(m.route, m.cum, max(0, at - 18));
    final outgoing = bearingAlongRoute(m.route, m.cum, at);
    final keptIncoming = headingDelta(course, incoming) <= 28;
    final notOutgoing = headingDelta(course, outgoing) > kWrongHeadingDegrees;
    if (keptIncoming && notOutgoing && offset >= kMissedTurnMeters) {
      return true;
    }
  }
  return false;
}

bool _snapBehindPassedManeuver({
  required double along,
  required double progressAlong,
  required List<NavStep> steps,
  required RouteMetrics m,
}) {
  for (var i = 0; i < steps.length; i++) {
    final step = steps[i];
    if (!step.isManeuver || step.type == 'arrive') continue;
    if (i >= m.stepAlong.length) continue;
    final at = m.stepAlong[i];
    if (progressAlong >= at + 15 && along < at - 35) return true;
  }
  return false;
}

/// Remaining along-route meters to the next instruction, rebuilt every GPS fix.
GuidanceFix computeGuidance({
  required double lat,
  required double lon,
  double? heading,
  required List<LatLng> route,
  required List<NavStep> steps,
  RouteMetrics? metrics,
  double offRouteThreshold = kOffRouteMeters,
  double passManeuverMeters = kPassManeuverMeters,
  double? previousOffset,
  double? progressAlong,
}) {
  if (route.length < 2) {
    return const GuidanceFix(
      stepIndex: 0,
      currentStep: null,
      metersToManeuver: 0,
      remainingMeters: 0,
      alongMeters: 0,
      offRouteMeters: 0,
      offRoute: false,
    );
  }

  final m = metrics ?? RouteMetrics.build(route, steps);
  final snap = projectOntoPolyline(lat, lon, m.route, m.cum);
  final along = snap?.alongMeters ?? 0;
  final remaining = snap?.remainingMeters ?? m.totalMeters;
  final offset = snap?.offsetMeters ?? 0;

  var stepIndex = _lastManeuverIndex(steps);
  for (var i = 0; i < steps.length; i++) {
    if (!steps[i].isManeuver) continue;
    final at = i < m.stepAlong.length ? m.stepAlong[i] : m.totalMeters;
    if (_stillAhead(
      alongMeters: along,
      maneuverAt: at,
      heading: heading,
      outgoingBearing: bearingAlongRoute(m.route, m.cum, at),
      passMeters: passManeuverMeters,
    )) {
      stepIndex = i;
      break;
    }
  }

  NavStep? step;
  if (steps.isNotEmpty && stepIndex >= 0 && stepIndex < steps.length) {
    step = steps[stepIndex];
  }
  if (step == null || !step.isManeuver) {
    final fallback = _firstManeuver(steps);
    step = fallback.$1;
    stepIndex = fallback.$2;
  }

  final maneuverAt = (stepIndex >= 0 && stepIndex < m.stepAlong.length)
      ? m.stepAlong[stepIndex]
      : m.totalMeters;
  var metersToManeuver = (maneuverAt - along).clamp(0, m.totalMeters).toDouble();
  if (step?.type == 'arrive') {
    metersToManeuver = remaining;
  }

  final tangent = bearingAlongRoute(m.route, m.cum, along);
  final course = _usableCourseHeading(heading);
  final headingDiverged = course != null &&
      headingDelta(course, tangent) > kWrongHeadingDegrees;
  final offsetGrowing = previousOffset != null && offset > previousOffset + 2;
  final missedTurn = _missedManeuver(
    along: along,
    offset: offset,
    course: course,
    steps: steps,
    m: m,
  );
  final snapBehind = progressAlong != null &&
      _snapBehindPassedManeuver(
        along: along,
        progressAlong: progressAlong,
        steps: steps,
        m: m,
      );
  final offRoute = offset > offRouteThreshold ||
      (headingDiverged && offset >= kOffRouteHeadingMeters) ||
      (headingDiverged && offsetGrowing && offset >= 12) ||
      missedTurn ||
      snapBehind;

  return GuidanceFix(
    stepIndex: stepIndex < 0 ? 0 : stepIndex,
    currentStep: step,
    metersToManeuver: metersToManeuver,
    remainingMeters: remaining,
    alongMeters: along,
    offRouteMeters: offset,
    offRoute: offRoute,
    headingDiverged: headingDiverged,
    segmentIndex: snap?.segmentIndex ?? 0,
  );
}

bool _stillAhead({
  required double alongMeters,
  required double maneuverAt,
  required double? heading,
  required double outgoingBearing,
  required double passMeters,
}) {
  if (alongMeters < maneuverAt + passMeters) {
    if (heading != null &&
        alongMeters >= maneuverAt - 12 &&
        headingDelta(heading, outgoingBearing) <= kHeadingAdvanceCone &&
        alongMeters >= maneuverAt - kHeadingAdvanceWindow) {
      return alongMeters < maneuverAt;
    }
    return true;
  }
  return false;
}

int _lastManeuverIndex(List<NavStep> steps) {
  for (var i = steps.length - 1; i >= 0; i--) {
    if (steps[i].isManeuver) return i;
  }
  return steps.isEmpty ? 0 : steps.length - 1;
}

(NavStep?, int) _firstManeuver(List<NavStep> steps) {
  for (var i = 0; i < steps.length; i++) {
    if (steps[i].isManeuver) return (steps[i], i);
  }
  if (steps.isEmpty) return (null, 0);
  return (steps.first, 0);
}
