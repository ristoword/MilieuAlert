import 'dart:math';

import '../models/emission_zone.dart';
import '../models/vehicle.dart';
import '../models/zone_status.dart';

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
    final allowed = vehicle == null || zone.minimumEuroLevel == null
        ? true
        : vehicle.euroClass.level >= zone.minimumEuroLevel!;

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
