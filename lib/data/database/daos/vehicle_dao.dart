import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../models/vehicle.dart';

part 'vehicle_dao.g.dart';

@DriftAccessor(tables: [Vehicles])
class VehicleDao extends DatabaseAccessor<AppDatabase> with _$VehicleDaoMixin {
  VehicleDao(super.db);

  Future<Vehicle?> getActiveVehicle() async {
    final row = await (select(vehicles)
          ..where((v) => v.isActive.equals(true)))
        .getSingleOrNull();
    return row != null ? _rowToModel(row) : null;
  }

  Future<int> insertVehicle(Vehicle vehicle) async {
    return into(vehicles).insert(
      VehiclesCompanion(
        type: Value(vehicle.type.name),
        fuelType: Value(vehicle.fuelType.name),
        euroClass: Value(vehicle.euroClass.name),
        licensePlate: Value(vehicle.licensePlate),
        country: Value(vehicle.country),
      ),
    );
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await (update(vehicles)..where((v) => v.id.equals(vehicle.id!)))
        .write(VehiclesCompanion(
      type: Value(vehicle.type.name),
      fuelType: Value(vehicle.fuelType.name),
      euroClass: Value(vehicle.euroClass.name),
      licensePlate: Value(vehicle.licensePlate),
      country: Value(vehicle.country),
    ));
  }

  Vehicle _rowToModel(VehicleRow row) {
    return Vehicle(
      id: row.id,
      type: VehicleType.values.byName(row.type),
      fuelType: FuelType.values.byName(row.fuelType),
      euroClass: EuroClass.values.byName(row.euroClass),
      licensePlate: row.licensePlate,
      country: row.country,
    );
  }
}
