import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/emission_zone.dart';
import '../models/zone_status.dart';
import '../services/geo_utils.dart';
import 'settings_provider.dart';
import 'vehicle_provider.dart';
import 'zone_provider.dart';

class LocationState {
  final double? latitude;
  final double? longitude;
  final double? speed;
  final double? heading;
  final ZoneProximity? nearestZone;
  final bool tracking;
  final bool follow;
  final String? error;

  const LocationState({
    this.latitude,
    this.longitude,
    this.speed,
    this.heading,
    this.nearestZone,
    this.tracking = false,
    this.follow = true,
    this.error,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    double? speed,
    double? heading,
    ZoneProximity? nearestZone,
    bool? tracking,
    bool? follow,
    String? error,
    bool clearError = false,
    bool clearZone = false,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      nearestZone: clearZone ? nearestZone : (nearestZone ?? this.nearestZone),
      tracking: tracking ?? this.tracking,
      follow: follow ?? this.follow,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref);
});

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier(this._ref) : super(const LocationState());

  final Ref _ref;
  StreamSubscription<Position>? _sub;

  Future<void> startTracking() async {
    if (state.tracking) return;
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        state = state.copyWith(error: 'Location services are disabled');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(error: 'Location permission denied');
        return;
      }

      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _applyPosition(current);

      _sub?.cancel();
      _sub = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: kIsWeb ? 15 : 8,
        ),
      ).listen(_applyPosition, onError: (e) {
        state = state.copyWith(error: e.toString());
      });

      state = state.copyWith(tracking: true, follow: true, clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setFollow(bool enabled) {
    state = state.copyWith(follow: enabled);
    if (enabled && !state.tracking) {
      startTracking();
    }
  }

  void toggleFollow() {
    setFollow(!state.follow);
  }

  void _applyPosition(Position pos) {
    final zones = _ref.read(zonesProvider).valueOrNull ?? const <EmissionZone>[];
    final vehicle = _ref.read(vehicleProvider).valueOrNull;
    final alertDistance = _ref.read(alertDistanceProvider);
    final proximity = nearestProximity(
      lat: pos.latitude,
      lon: pos.longitude,
      zones: zones,
      alertDistanceMeters: alertDistance,
      vehicle: vehicle,
    );

    state = state.copyWith(
      latitude: pos.latitude,
      longitude: pos.longitude,
      speed: pos.speed,
      heading: pos.heading,
      nearestZone: proximity,
      clearZone: proximity == null,
      tracking: true,
      clearError: true,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
