import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/models/vehicle.dart';
import 'package:milieu_alert/models/emission_zone.dart';
import 'package:milieu_alert/services/vehicle_checker.dart';

void main() {
  group('VehicleChecker', () {
    final zone = EmissionZone(
      id: 'test_zone',
      country: 'NL',
      city: 'Amsterdam',
      name: 'Amsterdam LEZ',
      zoneType: 'ENVIRONMENTAL_ZONE',
      polygonCoordinates: [],
      minimumEuroLevel: 4,
    );

    test('electric vehicle is always allowed', () {
      const vehicle = Vehicle(
        type: VehicleType.car,
        fuelType: FuelType.electric,
        euroClass: EuroClass.euro1,
      );
      expect(VehicleChecker.isVehicleAllowed(vehicle, zone), isTrue);
    });

    test('euro 3 diesel is not allowed in euro 4 zone', () {
      const vehicle = Vehicle(
        type: VehicleType.car,
        fuelType: FuelType.diesel,
        euroClass: EuroClass.euro3,
      );
      expect(VehicleChecker.isVehicleAllowed(vehicle, zone), isFalse);
    });

    test('euro 6 diesel is allowed in euro 4 zone', () {
      const vehicle = Vehicle(
        type: VehicleType.car,
        fuelType: FuelType.diesel,
        euroClass: EuroClass.euro6,
      );
      expect(VehicleChecker.isVehicleAllowed(vehicle, zone), isTrue);
    });
  });
}
