import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emission_zone.dart';
import 'vehicle_provider.dart';

final zonesProvider =
    AsyncNotifierProvider<ZonesNotifier, List<EmissionZone>>(
        ZonesNotifier.new);

class ZonesNotifier extends AsyncNotifier<List<EmissionZone>> {
  @override
  Future<List<EmissionZone>> build() async {
    try {
      final db = ref.watch(databaseProvider);
      return await db.zoneDao
          .getAllZones()
          .timeout(const Duration(seconds: 5), onTimeout: () => []);
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
