import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emission_zone.dart';
import 'vehicle_provider.dart';

final zonesProvider =
    AsyncNotifierProvider<ZonesNotifier, List<EmissionZone>>(
        ZonesNotifier.new);

class ZonesNotifier extends AsyncNotifier<List<EmissionZone>> {
  @override
  Future<List<EmissionZone>> build() async {
    final db = ref.watch(databaseProvider);
    return db.zoneDao.getAllZones();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
