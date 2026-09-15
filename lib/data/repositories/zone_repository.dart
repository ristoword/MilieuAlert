import '../../models/emission_zone.dart';
import '../database/daos/zone_dao.dart';
import '../datasources/ndw_datasource.dart';
import '../datasources/belgium_datasource.dart';

class ZoneRepository {
  final ZoneDao _zoneDao;
  final NdwDatasource _ndwDatasource;
  final BelgiumDatasource _belgiumDatasource;

  ZoneRepository({
    required this._zoneDao,
    NdwDatasource? ndwDatasource,
    BelgiumDatasource? belgiumDatasource,
  })  : _ndwDatasource = ndwDatasource ?? NdwDatasource(),
        _belgiumDatasource = belgiumDatasource ?? BelgiumDatasource();

  Future<List<EmissionZone>> getAllZones() => _zoneDao.getAllZones();

  Future<EmissionZone?> getZoneById(String id) => _zoneDao.getZoneById(id);

  Future<List<EmissionZone>> getZonesByCountry(String country) =>
      _zoneDao.getZonesByCountry(country);

  Stream<List<EmissionZone>> watchAllZones() => _zoneDao.watchAllZones();

  Future<void> syncZones() async {
    final results = await Future.wait([
      _ndwDatasource.fetchZones(),
      _belgiumDatasource.fetchAllZones(),
    ]);

    final allZones = results.expand((list) => list).toList();

    if (allZones.isNotEmpty) {
      await _zoneDao.upsertZones(allZones);
    }
  }

  Future<void> clearAllZones() => _zoneDao.deleteAllZones();
}
