import '../models/emission_zone.dart';
import '../models/vehicle.dart';
import 'geo_utils.dart';
import 'vehicle_checker.dart';

/// Drive-inside-zone stretch that counts as "long" for the warning copy.
const double kLongLezDriveMeters = 120;

class DropOffSuggestion {
  final double lat;
  final double lon;
  final double walkMeters;
  final double insideDriveMeters;
  final EmissionZone zone;
  final bool longInsideStretch;

  const DropOffSuggestion({
    required this.lat,
    required this.lon,
    required this.walkMeters,
    required this.insideDriveMeters,
    required this.zone,
    required this.longInsideStretch,
  });
}

/// Zones that contain B and that this vehicle may not enter.
List<EmissionZone> denyingZonesAt({
  required double lat,
  required double lon,
  required List<EmissionZone> zones,
  required Vehicle? vehicle,
}) {
  if (vehicle == null) return const [];
  final out = <EmissionZone>[];
  for (final zone in zones) {
    if (!zone.isCurrentlyActive) continue;
    if (!isInsideZone(lat, lon, zone)) continue;
    if (VehicleChecker.isVehicleAllowed(vehicle, zone)) continue;
    out.add(zone);
  }
  return out;
}

double insideDriveMetersFor(
  List<List<double>> pathLatLon,
  List<EmissionZone> zones,
) {
  var total = 0.0;
  for (final zone in zones) {
    total += metersInsideZone(pathLatLon, zone);
  }
  return total;
}

/// Nearest point on the zone outline, nudged fully outside, minimizing walk to B.
DropOffSuggestion? suggestDropOff({
  required double destLat,
  required double destLon,
  required List<EmissionZone> denyingZones,
  double insideDriveMeters = 0,
  double originLat = 0,
  double originLon = 0,
  bool originKnown = false,
}) {
  if (denyingZones.isEmpty) return null;

  DropOffSuggestion? best;
  for (final zone in denyingZones) {
    final onEdge = closestPointOnZoneBoundary(destLat, destLon, zone);
    if (onEdge == null) continue;
    for (final extra in const [18.0, 35.0, 55.0, 80.0, 120.0, 180.0]) {
      final nudged = extendBeyondBoundary(
        fromLat: destLat,
        fromLon: destLon,
        viaLat: onEdge.lat,
        viaLon: onEdge.lon,
        extraMeters: extra,
      );
      if (denyingZones.any((z) => isInsideZone(nudged.lat, nudged.lon, z))) {
        continue;
      }
      final walk = haversineMeters(nudged.lat, nudged.lon, destLat, destLon);
      var score = walk;
      if (originKnown) {
        // Prefer a curb that does not send the car around the far side of the LEZ.
        score += 0.15 *
            haversineMeters(originLat, originLon, nudged.lat, nudged.lon);
      }
      if (best == null || score < _score(best, originKnown, originLat, originLon)) {
        best = DropOffSuggestion(
          lat: nudged.lat,
          lon: nudged.lon,
          walkMeters: walk,
          insideDriveMeters: insideDriveMeters,
          zone: zone,
          longInsideStretch: insideDriveMeters >= kLongLezDriveMeters,
        );
      }
      break;
    }
  }
  return best;
}

double _score(
  DropOffSuggestion s,
  bool originKnown,
  double originLat,
  double originLon,
) {
  var score = s.walkMeters;
  if (originKnown) {
    score += 0.15 * haversineMeters(originLat, originLon, s.lat, s.lon);
  }
  return score;
}

bool originOutsideDenyingZones({
  required double lat,
  required double lon,
  required List<EmissionZone> denyingZones,
}) {
  return denyingZones.every((z) => !isInsideZone(lat, lon, z));
}
