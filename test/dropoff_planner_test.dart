import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/models/emission_zone.dart';
import 'package:milieu_alert/models/vehicle.dart';
import 'package:milieu_alert/services/dropoff_planner.dart';
import 'package:milieu_alert/services/geo_utils.dart';
import 'package:milieu_alert/services/vehicle_checker.dart';

EmissionZone _squareZone({
  required String id,
  double west = 4.895,
  double east = 4.905,
  double south = 52.365,
  double north = 52.375,
  int minEuro = 6,
}) {
  return EmissionZone(
    id: id,
    country: 'NL',
    city: 'Amsterdam',
    name: 'Amsterdam milieuzone',
    zoneType: 'ENVIRONMENTAL_ZONE',
    minimumEuroLevel: minEuro,
    polygonCoordinates: [
      [
        [west, south],
        [east, south],
        [east, north],
        [west, north],
        [west, south],
      ],
    ],
  );
}

void main() {
  const destLat = 52.37;
  const destLon = 4.90;

  test('closest boundary point sits on the outline, not the centroid', () {
    final zone = _squareZone(id: 'lez');
    expect(isInsideZone(destLat, destLon, zone), isTrue);
    final hit = closestPointOnZoneBoundary(destLat, destLon, zone);
    expect(hit, isNotNull);
    expect(hit!.metersToTarget, greaterThan(250));
    expect(hit.metersToTarget, lessThan(700));
  });

  test('drop-off is outside the LEZ and walk is the last meters', () {
    final zone = _squareZone(id: 'lez');
    const vehicle = Vehicle(
      type: VehicleType.car,
      fuelType: FuelType.diesel,
      euroClass: EuroClass.euro3,
    );
    final denying = denyingZonesAt(
      lat: destLat,
      lon: destLon,
      zones: [zone],
      vehicle: vehicle,
    );
    expect(denying, isNotEmpty);

    final drop = suggestDropOff(
      destLat: destLat,
      destLon: destLon,
      denyingZones: denying,
      insideDriveMeters: 400,
      originLat: 52.37,
      originLon: 4.88,
      originKnown: true,
    );
    expect(drop, isNotNull);
    expect(isInsideZone(drop!.lat, drop.lon, zone), isFalse);
    expect(drop.walkMeters, greaterThan(300));
    expect(drop.walkMeters, lessThan(800));
    expect(drop.longInsideStretch, isTrue);
  });

  test('authorized euro 6 diesel does not get a denying zone', () {
    final zone = _squareZone(id: 'lez');
    const vehicle = Vehicle(
      type: VehicleType.car,
      fuelType: FuelType.diesel,
      euroClass: EuroClass.euro6,
    );
    expect(
      denyingZonesAt(
        lat: destLat,
        lon: destLon,
        zones: [zone],
        vehicle: vehicle,
      ),
      isEmpty,
    );
  });

  test('path meters inside the square count the restricted stretch', () {
    final zone = _squareZone(id: 'lez');
    final path = [
      [52.37, 4.88],
      [52.37, 4.90],
    ];
    final inside = metersInsideZone(path, zone);
    expect(inside, greaterThan(400));
  });

  test('diesel blocked when zone lists only petrol', () {
    final zone = EmissionZone(
      id: 'fuel',
      country: 'NL',
      city: 'Utrecht',
      name: 'Utrecht',
      zoneType: 'ENVIRONMENTAL_ZONE',
      polygonCoordinates: const [],
      allowedFuelTypes: const ['petrol', 'electric'],
    );
    const diesel = Vehicle(
      type: VehicleType.car,
      fuelType: FuelType.diesel,
      euroClass: EuroClass.euro6,
    );
    const petrol = Vehicle(
      type: VehicleType.car,
      fuelType: FuelType.petrol,
      euroClass: EuroClass.euro4,
    );
    expect(VehicleChecker.isVehicleAllowed(diesel, zone), isFalse);
    expect(VehicleChecker.isVehicleAllowed(petrol, zone), isTrue);
  });
}
