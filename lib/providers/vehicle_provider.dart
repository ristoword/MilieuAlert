import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';
import '../data/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final vehicleProvider =
    AsyncNotifierProvider<VehicleNotifier, Vehicle?>(VehicleNotifier.new);

class VehicleNotifier extends AsyncNotifier<Vehicle?> {
  @override
  Future<Vehicle?> build() async {
    final db = ref.watch(databaseProvider);
    return db.vehicleDao.getActiveVehicle();
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    final db = ref.read(databaseProvider);
    if (vehicle.id != null) {
      await db.vehicleDao.updateVehicle(vehicle);
    } else {
      await db.vehicleDao.insertVehicle(vehicle);
    }
    ref.invalidateSelf();
  }
}
