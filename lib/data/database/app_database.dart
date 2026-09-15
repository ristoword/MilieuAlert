import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos/zone_dao.dart';
import 'daos/vehicle_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [EmissionZones, Vehicles], daos: [ZoneDao, VehicleDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'milieu_alert.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
