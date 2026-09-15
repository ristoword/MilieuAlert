import '../models/vehicle.dart';
import '../models/emission_zone.dart';

class VehicleChecker {
  static bool isVehicleAllowed(Vehicle vehicle, EmissionZone zone) {
    if (vehicle.fuelType == FuelType.electric) return true;

    if (zone.minimumEuroLevel != null &&
        vehicle.euroClass.level < zone.minimumEuroLevel!) {
      return false;
    }

    if (zone.allowedVehicleTypes != null &&
        zone.allowedVehicleTypes!.isNotEmpty &&
        !zone.allowedVehicleTypes!
            .contains(vehicle.type.name.toUpperCase())) {
      return false;
    }

    return true;
  }
}
