// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_dao.dart';

// ignore_for_file: type=lint
mixin _$ZoneDaoMixin on DatabaseAccessor<AppDatabase> {
  $EmissionZonesTable get emissionZones => attachedDatabase.emissionZones;
  ZoneDaoManager get managers => ZoneDaoManager(this);
}

class ZoneDaoManager {
  final _$ZoneDaoMixin _db;
  ZoneDaoManager(this._db);
  $$EmissionZonesTableTableManager get emissionZones =>
      $$EmissionZonesTableTableManager(_db.attachedDatabase, _db.emissionZones);
}
