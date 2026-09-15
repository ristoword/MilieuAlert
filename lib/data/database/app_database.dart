import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos/zone_dao.dart';
import 'daos/vehicle_dao.dart';
import 'daos/user_dao.dart';
import 'daos/user_vehicle_dao.dart';
import 'daos/trip_log_dao.dart';
import 'daos/ai_conversation_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    EmissionZones,
    Vehicles,
    Users,
    UserVehicles,
    TripLogs,
    AiConversations,
  ],
  daos: [
    ZoneDao,
    VehicleDao,
    UserDao,
    UserVehicleDao,
    TripLogDao,
    AiConversationDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(users);
            await m.createTable(userVehicles);
            await m.createTable(tripLogs);
            await m.createTable(aiConversations);
          }
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'milieu_alert.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
