import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';
import '../data/database/app_database.dart';
import 'settings_provider.dart';

const _savedVehiclePrefsKey = 'saved_vehicle';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final vehicleProvider =
    AsyncNotifierProvider<VehicleNotifier, Vehicle?>(VehicleNotifier.new);

class VehicleNotifier extends AsyncNotifier<Vehicle?> {
  @override
  Future<Vehicle?> build() async {
    final prefs = ref.watch(sharedPrefsProvider);
    final stored = prefs.getString(_savedVehiclePrefsKey);
    if (stored != null && stored.isNotEmpty) {
      try {
        final decoded = jsonDecode(stored);
        if (decoded is Map<String, dynamic>) {
          return Vehicle.fromJson(decoded);
        }
        if (decoded is Map) {
          return Vehicle.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    if (kIsWeb) return null;

    try {
      return await ref
          .read(databaseProvider)
          .vehicleDao
          .getActiveVehicle()
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_savedVehiclePrefsKey, jsonEncode(vehicle.toJson()));
    state = AsyncData(vehicle);

    if (kIsWeb) return;

    try {
      final db = ref.read(databaseProvider);
      if (vehicle.id != null) {
        await db.vehicleDao
            .updateVehicle(vehicle)
            .timeout(const Duration(seconds: 4));
      } else {
        await db.vehicleDao
            .insertVehicle(vehicle)
            .timeout(const Duration(seconds: 4));
      }
    } catch (_) {
      // Vehicle is already persisted in SharedPreferences.
    }
  }
}
