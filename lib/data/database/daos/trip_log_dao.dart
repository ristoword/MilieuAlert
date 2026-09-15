import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'trip_log_dao.g.dart';

@DriftAccessor(tables: [TripLogs])
class TripLogDao extends DatabaseAccessor<AppDatabase>
    with _$TripLogDaoMixin {
  TripLogDao(super.db);

  Future<List<TripLogRow>> getAllLogs() => select(tripLogs).get();

  Future<List<TripLogRow>> getLogsForUser(int userId) =>
      (select(tripLogs)..where((l) => l.userId.equals(userId))).get();

  Future<List<TripLogRow>> getLogsForZone(String zoneId) =>
      (select(tripLogs)..where((l) => l.zoneId.equals(zoneId))).get();

  Future<int> insertLog(TripLogsCompanion log) => into(tripLogs).insert(log);

  Future<void> deleteOldLogs(DateTime before) =>
      (delete(tripLogs)..where((l) => l.timestamp.isSmallerThanValue(before)))
          .go();

  Stream<List<TripLogRow>> watchLogsForUser(int userId) =>
      (select(tripLogs)..where((l) => l.userId.equals(userId))).watch();
}
