import 'package:drift/drift.dart';
import 'connection/native.dart'
    if (dart.library.js_interop) 'connection/web.dart';
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
  AppDatabase() : super(openConnection());

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

}
