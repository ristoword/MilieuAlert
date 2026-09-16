import 'dart:math';

import '../models/emission_zone.dart';
import '../models/vehicle.dart';
import '../models/zone_status.dart';
import 'vehicle_checker.dart';

double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _toRad(double deg) => deg * pi / 180;

double bearingDegrees(double lat1, double lon1, double lat2, double lon2) {
  final dLon = _toRad(lon2 - lon1);
  final y = sin(dLon) * cos(_toRad(lat2));
  final x = cos(_toRad(lat1)) * sin(_toRad(lat2)) -
      sin(_toRad(lat1)) * cos(_toRad(lat2)) * cos(dLon);
  return (atan2(y, x) * 180 / pi + 360) % 360;
}

bool isAheadOfHeading({
  required double lat,
  required double lon,
  required double heading,
  required double targetLat,
  required double targetLon,
  double coneDegrees = 80,
}) {
  final bearing = bearingDegrees(lat, lon, targetLat, targetLon);
  var diff = (bearing - heading).abs() % 360;
  if (diff > 180) diff = 360 - diff;
  return diff <= coneDegrees;
}

/// True if [lat],[lon] is within [maxMeters] of any sampled path point.
bool isNearPath(
  double lat,
  double lon,
  List<List<double>> pathLatLon, {
  double maxMeters = 140,
}) {
  if (pathLatLon.isEmpty) return false;
  final step = pathLatLon.length < 120 ? 1 : (pathLatLon.length / 120).ceil();
  for (var i = 0; i < pathLatLon.length; i += step) {
    final p = pathLatLon[i];
    if (p.length < 2) continue;
    if (haversineMeters(lat, lon, p[0], p[1]) <= maxMeters) return true;
  }
  return haversineMeters(
        lat,
        lon,
        pathLatLon.last[0],
        pathLatLon.last[1],
      ) <=
      maxMeters;
}

/// GeoJSON rings are [lon, lat].
bool isInsideZone(double lat, double lon, EmissionZone zone) {
  if (zone.polygonCoordinates.isEmpty) return false;
  for (final ring in zone.polygonCoordinates) {
    if (ring.length < 3) continue;
    if (pointInRing(lat, lon, ring)) return true;
  }
  return false;
}

bool pointInRing(double lat, double lon, List<List<double>> ring) {
  var inside = false;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    if (ring[i].length < 2 || ring[j].length < 2) continue;
    final xi = ring[i][0]; // lon
    final yi = ring[i][1]; // lat
    final xj = ring[j][0];
    final yj = ring[j][1];
    final intersect = ((yi > lat) != (yj > lat)) &&
        (lon <
            (xj - xi) * (lat - yi) / ((yj - yi) == 0 ? 1e-12 : (yj - yi)) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

double minDistanceToZone(double lat, double lon, EmissionZone zone) {
  var min = double.infinity;
  for (final ring in zone.polygonCoordinates) {
    for (final pt in ring) {
      if (pt.length < 2) continue;
      final d = haversineMeters(lat, lon, pt[1], pt[0]);
      if (d < min) min = d;
    }
  }
  return min;
}

/// Seconds from the start of [pathLatLon] until the first point inside [zone].
double? secondsToZoneEntry({
  required List<List<double>> pathLatLon,
  required double totalDurationSeconds,
  required EmissionZone zone,
}) {
  if (pathLatLon.length < 2 || totalDurationSeconds <= 0) return null;
  var total = 0.0;
  final segs = <double>[];
  for (var i = 1; i < pathLatLon.length; i++) {
    final a = pathLatLon[i - 1];
    final b = pathLatLon[i];
    if (a.length < 2 || b.length < 2) {
      segs.add(0);
      continue;
    }
    final d = haversineMeters(a[0], a[1], b[0], b[1]);
    segs.add(d);
    total += d;
  }
  if (total <= 0) return null;
  var acc = 0.0;
  for (var i = 0; i < pathLatLon.length; i++) {
    final p = pathLatLon[i];
    if (p.length >= 2 && isInsideZone(p[0], p[1], zone)) {
      return totalDurationSeconds * (acc / total);
    }
    if (i < segs.length) acc += segs[i];
  }
  return null;
}

ZoneProximity? nearestProximity({
  required double lat,
  required double lon,
  required List<EmissionZone> zones,
  required int alertDistanceMeters,
  Vehicle? vehicle,
}) {
  ZoneProximity? inside;
  ZoneProximity? approaching;

  for (final zone in zones) {
    final allowed =
        vehicle == null || VehicleChecker.isVehicleAllowed(vehicle, zone);

    if (isInsideZone(lat, lon, zone)) {
      inside = ZoneProximity(
        zoneId: zone.id,
        zoneName: zone.name,
        zoneType: zone.zoneType,
        status: ZoneStatus.inside,
        distanceMeters: 0,
        isVehicleAllowed: allowed,
      );
      break;
    }

    final dist = minDistanceToZone(lat, lon, zone);
    if (dist.isFinite &&
        (approaching == null ||
            (approaching.distanceMeters ?? double.infinity) > dist)) {
      approaching = ZoneProximity(
        zoneId: zone.id,
        zoneName: zone.name,
        zoneType: zone.zoneType,
        status: dist <= alertDistanceMeters
            ? ZoneStatus.approaching
            : ZoneStatus.safe,
        distanceMeters: dist,
        isVehicleAllowed: allowed,
      );
    }
  }

  return inside ?? approaching;
}

double headingDeltaDeg(double a, double b) {
  var diff = (a - b).abs() % 360;
  if (diff > 180) diff = 360 - diff;
  return diff;
}

/// WGS84 destination from a start point, bearing and distance.
({double lat, double lon}) destinationPoint(
  double lat,
  double lon,
  double bearingDeg,
  double meters,
) {
  const r = 6371000.0;
  if (!meters.isFinite || meters.abs() < 0.01) {
    return (lat: lat, lon: lon);
  }
  final br = bearingDeg * pi / 180;
  final lat1 = lat * pi / 180;
  final lon1 = lon * pi / 180;
  final ang = meters / r;
  final lat2 = asin(sin(lat1) * cos(ang) + cos(lat1) * sin(ang) * cos(br));
  final lon2 = lon1 +
      atan2(sin(br) * sin(ang) * cos(lat1), cos(ang) - sin(lat1) * sin(lat2));
  return (lat: lat2 * 180 / pi, lon: ((lon2 * 180 / pi + 540) % 360) - 180);
}

bool _usableReportedSpeed(double? reported) =>
    reported != null && reported.isFinite && reported >= 0.45;

/// Web `watchPosition` often reports `speed` as 0/null. Use a real reading
/// when present, otherwise metres/time between two fixes.
double? resolveTravelSpeedMps({
  required double? reported,
  double? previousLat,
  double? previousLon,
  DateTime? previousAt,
  required double lat,
  required double lon,
  required DateTime at,
  double? previousSpeed,
}) {
  if (_usableReportedSpeed(reported)) return reported;
  if (previousLat != null && previousLon != null && previousAt != null) {
    final dt = at.difference(previousAt).inMilliseconds / 1000.0;
    if (dt >= 0.2 && dt <= 8) {
      final d = haversineMeters(previousLat, previousLon, lat, lon);
      final derived = d / dt;
      if (derived >= 0.4) return derived;
      if (d < 4) return 0;
    }
  }
  if (reported != null && reported.isFinite && reported >= 0 && reported < 0.45) {
    if (previousSpeed != null && previousSpeed > 1) return previousSpeed;
    return 0;
  }
  return previousSpeed;
}

double? resolveHeadingDeg({
  required double? reported,
  double? previousLat,
  double? previousLon,
  required double lat,
  required double lon,
  double? previousHeading,
}) {
  final ok = reported != null &&
      reported.isFinite &&
      reported >= 0 &&
      reported <= 360;
  if (previousLat != null && previousLon != null) {
    final d = haversineMeters(previousLat, previousLon, lat, lon);
    if (d >= 8) {
      final derived = bearingDegrees(previousLat, previousLon, lat, lon);
      if (!ok || (reported == 0 && headingDeltaDeg(derived, 0) > 25)) {
        return derived;
      }
    }
  }
  if (ok) return reported;
  return previousHeading;
}

class BoundaryPoint {
  final double lat;
  final double lon;
  final double metersToTarget;

  const BoundaryPoint({
    required this.lat,
    required this.lon,
    required this.metersToTarget,
  });
}

/// Closest point on the polygon outline (not vertices only).
BoundaryPoint? closestPointOnZoneBoundary(
  double lat,
  double lon,
  EmissionZone zone,
) {
  BoundaryPoint? best;
  for (final ring in zone.polygonCoordinates) {
    if (ring.length < 2) continue;
    for (var i = 0; i < ring.length; i++) {
      final a = ring[i];
      final b = ring[(i + 1) % ring.length];
      if (a.length < 2 || b.length < 2) continue;
      final hit = _closestOnSegment(
        lat,
        lon,
        a[1],
        a[0],
        b[1],
        b[0],
      );
      if (best == null || hit.metersToTarget < best.metersToTarget) {
        best = hit;
      }
    }
  }
  return best;
}

BoundaryPoint _closestOnSegment(
  double lat,
  double lon,
  double aLat,
  double aLon,
  double bLat,
  double bLon,
) {
  final metersPerDegLat = 111320.0;
  final metersPerDegLon =
      111320.0 * cos(lat * pi / 180).clamp(0.2, 1.0);
  final ax = (aLon - lon) * metersPerDegLon;
  final ay = (aLat - lat) * metersPerDegLat;
  final bx = (bLon - lon) * metersPerDegLon;
  final by = (bLat - lat) * metersPerDegLat;
  final abx = bx - ax;
  final aby = by - ay;
  final ab2 = abx * abx + aby * aby;
  var t = 0.0;
  if (ab2 > 1e-6) {
    t = ((-ax) * abx + (-ay) * aby) / ab2;
    if (t < 0) t = 0;
    if (t > 1) t = 1;
  }
  final qLat = aLat + t * (bLat - aLat);
  final qLon = aLon + t * (bLon - aLon);
  return BoundaryPoint(
    lat: qLat,
    lon: qLon,
    metersToTarget: haversineMeters(lat, lon, qLat, qLon),
  );
}

/// Drive meters of [pathLatLon] ([lat, lon] pairs) that sit inside [zone].
double metersInsideZone(
  List<List<double>> pathLatLon,
  EmissionZone zone,
) {
  if (pathLatLon.length < 2) return 0;
  var inside = 0.0;
  for (var i = 1; i < pathLatLon.length; i++) {
    final a = pathLatLon[i - 1];
    final b = pathLatLon[i];
    if (a.length < 2 || b.length < 2) continue;
    final midLat = (a[0] + b[0]) / 2;
    final midLon = (a[1] + b[1]) / 2;
    if (isInsideZone(a[0], a[1], zone) ||
        isInsideZone(b[0], b[1], zone) ||
        isInsideZone(midLat, midLon, zone)) {
      inside += haversineMeters(a[0], a[1], b[0], b[1]);
    }
  }
  return inside;
}

/// Point past [via] along the dest→via ray, [extraMeters] beyond the boundary.
({double lat, double lon}) extendBeyondBoundary({
  required double fromLat,
  required double fromLon,
  required double viaLat,
  required double viaLon,
  required double extraMeters,
}) {
  final span = haversineMeters(fromLat, fromLon, viaLat, viaLon);
  final bearing = bearingDegrees(fromLat, fromLon, viaLat, viaLon);
  return destinationPoint(
    fromLat,
    fromLon,
    bearing,
    span + extraMeters,
  );
}
