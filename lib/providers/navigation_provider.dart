import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/emission_zone.dart';
import '../models/navigation_models.dart';
import '../services/geo_utils.dart';
import '../services/navigation_service.dart';
import 'location_provider.dart';
import 'zone_provider.dart';

class NavigationState {
  final List<PlaceHit> suggestions;
  final PlaceHit? destination;
  final List<LatLng> route;
  final List<NavStep> steps;
  final List<SpeedCamera> cameras;
  final List<SpeedLimitPoint> limits;
  final List<EmissionZone> zonesOnRoute;
  final bool searching;
  final bool routing;
  final bool navigating;
  final String? error;
  final double? routeDistanceMeters;
  final double? routeDurationSeconds;

  const NavigationState({
    this.suggestions = const [],
    this.destination,
    this.route = const [],
    this.steps = const [],
    this.cameras = const [],
    this.limits = const [],
    this.zonesOnRoute = const [],
    this.searching = false,
    this.routing = false,
    this.navigating = false,
    this.error,
    this.routeDistanceMeters,
    this.routeDurationSeconds,
  });

  NavigationState copyWith({
    List<PlaceHit>? suggestions,
    PlaceHit? destination,
    List<LatLng>? route,
    List<NavStep>? steps,
    List<SpeedCamera>? cameras,
    List<SpeedLimitPoint>? limits,
    List<EmissionZone>? zonesOnRoute,
    bool? searching,
    bool? routing,
    bool? navigating,
    String? error,
    double? routeDistanceMeters,
    double? routeDurationSeconds,
    bool clearDestination = false,
    bool clearError = false,
  }) {
    return NavigationState(
      suggestions: suggestions ?? this.suggestions,
      destination: clearDestination ? null : (destination ?? this.destination),
      route: route ?? this.route,
      steps: steps ?? this.steps,
      cameras: cameras ?? this.cameras,
      limits: limits ?? this.limits,
      zonesOnRoute: zonesOnRoute ?? this.zonesOnRoute,
      searching: searching ?? this.searching,
      routing: routing ?? this.routing,
      navigating: navigating ?? this.navigating,
      error: clearError ? null : (error ?? this.error),
      routeDistanceMeters: routeDistanceMeters ?? this.routeDistanceMeters,
      routeDurationSeconds: routeDurationSeconds ?? this.routeDurationSeconds,
    );
  }
}

class LiveNavInfo {
  final NavStep? currentStep;
  final double remainingMeters;
  final int? speedLimitKmh;
  final SpeedCamera? nextCamera;
  final double? nextCameraMeters;
  final EmissionZone? currentZone;

  const LiveNavInfo({
    this.currentStep,
    required this.remainingMeters,
    this.speedLimitKmh,
    this.nextCamera,
    this.nextCameraMeters,
    this.currentZone,
  });
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier(ref, NavigationService());
});

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier(this._ref, this._service) : super(const NavigationState());

  final Ref _ref;
  final NavigationService _service;
  Timer? _debounce;

  void search(String query, {String lang = 'it'}) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      state = state.copyWith(suggestions: const [], searching: false);
      return;
    }
    state = state.copyWith(searching: true, clearError: true);
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final hits = await _service.searchAddress(query.trim(), lang: lang);
        if (!mounted) return;
        state = state.copyWith(suggestions: hits, searching: false);
      } catch (_) {
        if (!mounted) return;
        state = state.copyWith(
          searching: false,
          suggestions: const [],
          error: 'Ricerca indirizzo non riuscita',
        );
      }
    });
  }

  Future<void> startNavigation(PlaceHit place) async {
    state = state.copyWith(
      destination: place,
      suggestions: const [],
      routing: true,
      navigating: true,
      clearError: true,
    );
    _ref.read(locationProvider.notifier).setFollow(true);
    await _ref.read(locationProvider.notifier).startTracking();

    final loc = _ref.read(locationProvider);
    final fromLat = loc.latitude;
    final fromLon = loc.longitude;

    var route = [LatLng(place.lat, place.lon)];
    var steps = const <NavStep>[];
    var distance = 0.0;
    var duration = 0.0;

    if (fromLat != null && fromLon != null) {
      try {
        final plan = await _service.route(
          fromLat: fromLat,
          fromLon: fromLon,
          toLat: place.lat,
          toLon: place.lon,
        );
        if (plan.points.isNotEmpty) {
          route = plan.points.map((p) => LatLng(p[1], p[0])).toList();
          steps = plan.steps;
          distance = plan.distanceMeters;
          duration = plan.durationSeconds;
        } else {
          route = [LatLng(fromLat, fromLon), LatLng(place.lat, place.lon)];
        }
      } catch (_) {
        route = [LatLng(fromLat, fromLon), LatLng(place.lat, place.lon)];
      }
    }

    final lats = route.map((p) => p.latitude);
    final lons = route.map((p) => p.longitude);
    var minLat = lats.reduce((a, b) => a < b ? a : b) - 0.02;
    var maxLat = lats.reduce((a, b) => a > b ? a : b) + 0.02;
    var minLon = lons.reduce((a, b) => a < b ? a : b) - 0.02;
    var maxLon = lons.reduce((a, b) => a > b ? a : b) + 0.02;

    var cameras = const <SpeedCamera>[];
    var limits = const <SpeedLimitPoint>[];
    try {
      final hazards = await _service.hazards(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
      );
      cameras = hazards.cameras;
      limits = hazards.limits;
    } catch (_) {}

    final zones = _ref.read(zonesProvider).valueOrNull ?? const <EmissionZone>[];
    final onRoute = <EmissionZone>[];
    final seen = <String>{};
    final step = route.length < 80 ? 1 : (route.length / 80).ceil();
    for (var i = 0; i < route.length; i += step) {
      final p = route[i];
      for (final zone in zones) {
        if (seen.contains(zone.id)) continue;
        if (isInsideZone(p.latitude, p.longitude, zone)) {
          seen.add(zone.id);
          onRoute.add(zone);
        }
      }
    }

    if (!mounted) return;
    state = state.copyWith(
      route: route,
      steps: steps,
      cameras: cameras,
      limits: limits,
      zonesOnRoute: onRoute,
      routing: false,
      navigating: true,
      routeDistanceMeters: distance,
      routeDurationSeconds: duration,
    );
  }

  void stopNavigation() {
    state = const NavigationState();
  }

  LiveNavInfo liveInfo(double lat, double lon) {
    final dest = state.destination;
    var remaining = dest == null
        ? 0.0
        : haversineMeters(lat, lon, dest.lat, dest.lon);
    if (state.route.length >= 2) {
      remaining = haversineMeters(
        lat,
        lon,
        state.route.last.latitude,
        state.route.last.longitude,
      );
    }

    NavStep? step;
    for (final s in state.steps) {
      if (s.type == 'depart' || s.lat == null || s.lon == null) continue;
      final d = haversineMeters(lat, lon, s.lat!, s.lon!);
      if (d < 250) {
        step = s;
        break;
      }
      step ??= s;
    }
    if (step == null && state.steps.isNotEmpty) {
      step = state.steps.firstWhere(
        (s) => s.type != 'depart',
        orElse: () => state.steps.first,
      );
    }

    int? limit;
    var limitDist = double.infinity;
    for (final p in state.limits) {
      final d = haversineMeters(lat, lon, p.lat, p.lon);
      if (d < limitDist && d < 180) {
        limitDist = d;
        limit = p.maxspeed;
      }
    }

    SpeedCamera? camera;
    double? cameraMeters;
    for (final c in state.cameras) {
      final d = haversineMeters(lat, lon, c.lat, c.lon);
      if (d > 1200) continue;
      if (cameraMeters == null || d < cameraMeters) {
        camera = c;
        cameraMeters = d;
      }
    }

    final zones = _ref.read(zonesProvider).valueOrNull ?? const <EmissionZone>[];
    EmissionZone? currentZone;
    for (final zone in zones) {
      if (isInsideZone(lat, lon, zone)) {
        currentZone = zone;
        break;
      }
    }

    return LiveNavInfo(
      currentStep: step,
      remainingMeters: remaining,
      speedLimitKmh: limit,
      nextCamera: camera,
      nextCameraMeters: cameraMeters,
      currentZone: currentZone,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
