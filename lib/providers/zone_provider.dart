import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../models/emission_zone.dart';
import 'vehicle_provider.dart';

final zonesProvider =
    AsyncNotifierProvider<ZonesNotifier, List<EmissionZone>>(
        ZonesNotifier.new);

class ZonesNotifier extends AsyncNotifier<List<EmissionZone>> {
  @override
  Future<List<EmissionZone>> build() async {
    if (!kIsWeb) {
      try {
        final db = ref.watch(databaseProvider);
        final local = await db.zoneDao
            .getAllZones()
            .timeout(const Duration(seconds: 5), onTimeout: () => []);
        if (local.isNotEmpty) return local;
      } catch (_) {}
    }
    return _fetchFromApi();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchFromApi());
  }

  Future<List<EmissionZone>> _fetchFromApi() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 18),
        receiveTimeout: const Duration(seconds: 22),
      ));
      final response = await dio.get('/api/zones/data');
      final list = (response.data['zones'] as List?) ?? const [];
      return list
          .map((e) => EmissionZone.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
