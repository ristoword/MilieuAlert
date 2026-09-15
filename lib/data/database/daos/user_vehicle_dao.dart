import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'user_vehicle_dao.g.dart';

@DriftAccessor(tables: [UserVehicles])
class UserVehicleDao extends DatabaseAccessor<AppDatabase>
    with _$UserVehicleDaoMixin {
  UserVehicleDao(super.db);

  Future<List<UserVehicleRow>> getVehiclesForUser(int userId) =>
      (select(userVehicles)..where((v) => v.userId.equals(userId))).get();

  Future<UserVehicleRow?> getDefaultVehicle(int userId) async {
    return (select(userVehicles)
          ..where(
              (v) => v.userId.equals(userId) & v.isDefault.equals(true)))
        .getSingleOrNull();
  }

  Future<int> insertVehicle(UserVehiclesCompanion vehicle) =>
      into(userVehicles).insert(vehicle);

  Future<bool> updateVehicle(UserVehiclesCompanion vehicle) =>
      update(userVehicles).replace(vehicle);

  Future<int> deleteVehicle(int id) =>
      (delete(userVehicles)..where((v) => v.id.equals(id))).go();

  Stream<List<UserVehicleRow>> watchVehiclesForUser(int userId) =>
      (select(userVehicles)..where((v) => v.userId.equals(userId))).watch();
}
