import '../models/vehicle.dart';
import '../models/emission_zone.dart';

class VehicleChecker {
  static bool isVehicleAllowed(Vehicle vehicle, EmissionZone zone) {
    if (vehicle.fuelType == FuelType.electric) return true;

    if (zone.minimumEuroLevel != null &&
        vehicle.euroClass.level < zone.minimumEuroLevel!) {
      return false;
    }

    final fuels = zone.allowedFuelTypes;
    if (fuels != null && fuels.isNotEmpty) {
      final allowed = fuels.map((e) => e.toLowerCase().trim()).toSet();
      final name = vehicle.fuelType.name.toLowerCase();
      final label = vehicle.fuelType.label.toLowerCase();
      if (!allowed.contains(name) && !allowed.contains(label)) {
        return false;
      }
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
