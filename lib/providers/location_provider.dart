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

/// High-frequency GPS sample. Interpolation ticks set [snapped] to false.
class LiveGpsFix {
  final double lat;
  final double lon;
  final double? heading;
  final double? accuracy;
  final double? speedMps;
  final bool snapped;
  final DateTime at;

  const LiveGpsFix({
    required this.lat,
    required this.lon,
    this.heading,
    this.accuracy,
    this.speedMps,
    this.snapped = true,
    required this.at,
  });
}

class LocationState {
  final double? latitude;
  final double? longitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final ZoneProximity? nearestZone;
  final bool tracking;
  final bool follow;
  final String? error;

  const LocationState({
    this.latitude,
    this.longitude,
    this.speed,
    this.heading,
    this.accuracy,
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
    double? accuracy,
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
      accuracy: accuracy ?? this.accuracy,
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
  Timer? _webKeepAlive;
  Timer? _restartTimer;
  Timer? _interp;
  DateTime? _lastFixAt;
  Future<void>? _startInFlight;
  LiveGpsFix? _lastRaw;
  final ValueNotifier<LiveGpsFix?> liveFix = ValueNotifier(null);

  LocationSettings get _streamSettings {
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        maximumAge: Duration.zero,
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 1),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppleSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          activityType: ActivityType.automotiveNavigation,
          distanceFilter: 0,
          pauseLocationUpdatesAutomatically: false,
        );
      default:
        return const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        );
    }
  }

  LocationSettings get _oneShotSettings {
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        maximumAge: Duration.zero,
        timeLimit: const Duration(seconds: 12),
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      timeLimit: Duration(seconds: 12),
    );
  }

  /// Keep GPS watch alive while the map is open (walking or A→B).
  /// Does not change [LocationState.follow] so a user pan stays paused.
  Future<void> startTracking({bool restart = false}) {
    final inFlight = _startInFlight;
    if (inFlight != null) return inFlight;
    final future = _startTracking(restart: restart);
    _startInFlight = future;
    return future.whenComplete(() {
      if (identical(_startInFlight, future)) _startInFlight = null;
    });
  }

  Future<void> _startTracking({required bool restart}) async {
    if (!restart && state.tracking && _sub != null) return;
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
        locationSettings: _oneShotSettings,
      );
      _applyPosition(current);

      _listenToStream();
      _startWebKeepAlive();
      _startInterp();

      state = state.copyWith(tracking: true, clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      _scheduleRestart();
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

  void _listenToStream() {
    _restartTimer?.cancel();
    _restartTimer = null;
    _sub?.cancel();
    _sub = Geolocator.getPositionStream(locationSettings: _streamSettings).listen(
      _applyPosition,
      onError: (Object e) {
        state = state.copyWith(error: e.toString());
        _scheduleRestart();
      },
      onDone: _scheduleRestart,
    );
  }

  void _scheduleRestart() {
    if (!mounted) return;
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      startTracking(restart: true);
    });
  }

  /// Browsers may pause `watchPosition` on a hidden tab. Restart if the last
  /// fix is stale (>3s) so meters and the puck keep moving.
  void _startWebKeepAlive() {
    _webKeepAlive?.cancel();
    _webKeepAlive = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !state.tracking) return;
      final last = _lastFixAt;
      final stale = last == null ||
          DateTime.now().difference(last) > const Duration(seconds: 3);
      if (!stale) return;
      startTracking(restart: true);
    });
  }

  void _startInterp() {
    _interp?.cancel();
    _interp = Timer.periodic(const Duration(milliseconds: 280), (_) {
      _emitInterpolated();
    });
  }

  void _emitInterpolated() {
    if (!mounted) return;
    final last = _lastRaw;
    if (last == null) return;
    final now = DateTime.now();
    final dt = now.difference(last.at).inMilliseconds / 1000.0;
    if (dt < 0.18) return;
    if (dt > 3.5) return;
    final heading = last.heading;
    final speed = last.speedMps ?? 0;
    if (heading == null || heading < 0 || speed < 0.5) return;
    final moved = speed * dt;
    if (moved < 0.4) return;
    final dest = destinationPoint(last.lat, last.lon, heading, moved);
    liveFix.value = LiveGpsFix(
      lat: dest.lat,
      lon: dest.lon,
      heading: heading,
      accuracy: last.accuracy,
      speedMps: speed,
      snapped: false,
      at: now,
    );
  }

  void _applyPosition(Position pos) {
    final now = DateTime.now();
    _lastFixAt = now;
    final prev = _lastRaw;
    final speed = resolveTravelSpeedMps(
      reported: pos.speed,
      previousLat: prev?.lat,
      previousLon: prev?.lon,
      previousAt: prev?.at,
      lat: pos.latitude,
      lon: pos.longitude,
      at: now,
      previousSpeed: prev?.speedMps ?? state.speed,
    );
    final heading = resolveHeadingDeg(
      reported: pos.heading,
      previousLat: prev?.lat,
      previousLon: prev?.lon,
      lat: pos.latitude,
      lon: pos.longitude,
      previousHeading: prev?.heading ?? state.heading,
    );
    final fix = LiveGpsFix(
      lat: pos.latitude,
      lon: pos.longitude,
      heading: heading,
      accuracy: pos.accuracy,
      speedMps: speed,
      snapped: true,
      at: now,
    );
    _lastRaw = fix;
    liveFix.value = fix;

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
      speed: speed,
      heading: heading,
      accuracy: pos.accuracy,
      nearestZone: proximity,
      clearZone: proximity == null,
      tracking: true,
      clearError: true,
    );
  }

  @override
  void dispose() {
    _restartTimer?.cancel();
    _webKeepAlive?.cancel();
    _interp?.cancel();
    _sub?.cancel();
    liveFix.dispose();
    super.dispose();
  }
}
