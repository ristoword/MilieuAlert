import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../models/emission_zone.dart';

part 'zone_dao.g.dart';

@DriftAccessor(tables: [EmissionZones])
class ZoneDao extends DatabaseAccessor<AppDatabase> with _$ZoneDaoMixin {
  ZoneDao(super.db);

  Future<List<EmissionZone>> getAllZones() async {
    final rows = await select(emissionZones).get();
    return rows.map(_rowToModel).toList();
  }

  Future<EmissionZone?> getZoneById(String id) async {
    final row = await (select(emissionZones)
          ..where((z) => z.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _rowToModel(row) : null;
  }

  Future<List<EmissionZone>> getZonesByCountry(String country) async {
    final rows = await (select(emissionZones)
          ..where((z) => z.country.equals(country)))
        .get();
    return rows.map(_rowToModel).toList();
  }

  Future<void> upsertZone(EmissionZone zone) async {
    await into(emissionZones).insertOnConflictUpdate(
      EmissionZonesCompanion(
        id: Value(zone.id),
        country: Value(zone.country),
        city: Value(zone.city),
        name: Value(zone.name),
        zoneType: Value(zone.zoneType),
        polygonJson: Value(jsonEncode(zone.polygonCoordinates)),
        activeFrom: Value(zone.activeFrom),
        activeTo: Value(zone.activeTo),
        activeDays: Value(zone.activeDays),
        minimumEuroLevel: Value(zone.minimumEuroLevel),
        allowedFuelTypes: Value(zone.allowedFuelTypes?.join(',')),
        allowedVehicleTypes: Value(zone.allowedVehicleTypes?.join(',')),
        restrictions: Value(zone.restrictions),
        officialSource: Value(zone.officialSource),
        lastVerifiedAt: Value(zone.lastVerifiedAt),
      ),
    );
  }

  Future<void> upsertZones(List<EmissionZone> zones) async {
    await batch((b) {
      for (final zone in zones) {
        b.insert(
          emissionZones,
          EmissionZonesCompanion(
            id: Value(zone.id),
            country: Value(zone.country),
            city: Value(zone.city),
            name: Value(zone.name),
            zoneType: Value(zone.zoneType),
            polygonJson: Value(jsonEncode(zone.polygonCoordinates)),
            activeFrom: Value(zone.activeFrom),
            activeTo: Value(zone.activeTo),
            activeDays: Value(zone.activeDays),
            minimumEuroLevel: Value(zone.minimumEuroLevel),
            allowedFuelTypes: Value(zone.allowedFuelTypes?.join(',')),
            allowedVehicleTypes: Value(zone.allowedVehicleTypes?.join(',')),
            restrictions: Value(zone.restrictions),
            officialSource: Value(zone.officialSource),
            lastVerifiedAt: Value(zone.lastVerifiedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> deleteAllZones() async {
    await delete(emissionZones).go();
  }

  Stream<List<EmissionZone>> watchAllZones() {
    return select(emissionZones).watch().map(
          (rows) => rows.map(_rowToModel).toList(),
        );
  }

  EmissionZone _rowToModel(EmissionZoneRow row) {
    return EmissionZone(
      id: row.id,
      country: row.country,
      city: row.city,
      name: row.name,
      zoneType: row.zoneType,
      polygonCoordinates: _parsePolygonJson(row.polygonJson),
      activeFrom: row.activeFrom,
      activeTo: row.activeTo,
      activeDays: row.activeDays,
      minimumEuroLevel: row.minimumEuroLevel,
      allowedFuelTypes: row.allowedFuelTypes?.split(','),
      allowedVehicleTypes: row.allowedVehicleTypes?.split(','),
      restrictions: row.restrictions,
      officialSource: row.officialSource,
      lastVerifiedAt: row.lastVerifiedAt,
    );
  }

  List<List<List<double>>> _parsePolygonJson(String json) {
    final decoded = jsonDecode(json) as List;
    return decoded
        .map((ring) => (ring as List)
            .map((point) =>
                (point as List).map((c) => (c as num).toDouble()).toList())
            .toList())
        .toList();
  }
}
