import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/emission_zone.dart';
import '../models/navigation_models.dart';
import '../models/zone_status.dart';
import '../services/geo_utils.dart';
import '../services/navigation_guidance.dart';
import '../services/navigation_service.dart';
import 'location_provider.dart';
import 'zone_provider.dart';

enum SearchField { origin, destination }

class NavigationState {
  final List<PlaceHit> suggestions;
  final PlaceHit? origin;
  final PlaceHit? destination;
  final bool originIsMyLocation;
  final SearchField activeField;
  final List<LatLng> route;
  final List<List<LatLng>> alternativeRoutes;
  final int selectedRoute;
  final List<NavStep> steps;
  final List<SpeedCamera> cameras;
  final List<SpeedLimitPoint> limits;
  final List<double> annotationSpeeds;
  final List<EmissionZone> zonesOnRoute;
  final bool searching;
  final bool routing;
  final bool navigating;
  final String? error;
  final double? routeDistanceMeters;
  final double? routeDurationSeconds;
  final List<RoutePlan> alternatives;
  final List<RouteChangeAlert> alerts;
  final DateTime? lastMonitoredAt;
  final List<PlaceHit> nearbyResults;
  final String? nearbyCategory;
  final bool nearbySearching;

  const NavigationState({
    this.suggestions = const [],
    this.origin,
    this.destination,
    this.originIsMyLocation = true,
    this.activeField = SearchField.destination,
    this.route = const [],
    this.alternativeRoutes = const [],
    this.selectedRoute = 0,
    this.steps = const [],
    this.cameras = const [],
    this.limits = const [],
    this.annotationSpeeds = const [],
    this.zonesOnRoute = const [],
    this.searching = false,
    this.routing = false,
    this.navigating = false,
    this.error,
    this.routeDistanceMeters,
    this.routeDurationSeconds,
    this.alternatives = const [],
    this.alerts = const [],
    this.lastMonitoredAt,
    this.nearbyResults = const [],
    this.nearbyCategory,
    this.nearbySearching = false,
  });

  bool get hasRoute => route.length >= 2;

  NavigationState copyWith({
    List<PlaceHit>? suggestions,
    PlaceHit? origin,
    PlaceHit? destination,
    bool? originIsMyLocation,
    SearchField? activeField,
    List<LatLng>? route,
    List<List<LatLng>>? alternativeRoutes,
    int? selectedRoute,
    List<NavStep>? steps,
    List<SpeedCamera>? cameras,
    List<SpeedLimitPoint>? limits,
    List<double>? annotationSpeeds,
    List<EmissionZone>? zonesOnRoute,
    bool? searching,
    bool? routing,
    bool? navigating,
    String? error,
    double? routeDistanceMeters,
    double? routeDurationSeconds,
    List<RoutePlan>? alternatives,
    List<RouteChangeAlert>? alerts,
    DateTime? lastMonitoredAt,
    List<PlaceHit>? nearbyResults,
    String? nearbyCategory,
    bool? nearbySearching,
    bool clearOrigin = false,
    bool clearDestination = false,
    bool clearError = false,
    bool clearAlerts = false,
    bool clearNearby = false,
    bool clearNearbyCategory = false,
  }) {
    return NavigationState(
      suggestions: suggestions ?? this.suggestions,
      origin: clearOrigin ? null : (origin ?? this.origin),
      destination: clearDestination ? null : (destination ?? this.destination),
      originIsMyLocation: originIsMyLocation ?? this.originIsMyLocation,
      activeField: activeField ?? this.activeField,
      route: route ?? this.route,
      alternativeRoutes: alternativeRoutes ?? this.alternativeRoutes,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      steps: steps ?? this.steps,
      cameras: cameras ?? this.cameras,
      limits: limits ?? this.limits,
      annotationSpeeds: annotationSpeeds ?? this.annotationSpeeds,
      zonesOnRoute: zonesOnRoute ?? this.zonesOnRoute,
      searching: searching ?? this.searching,
      routing: routing ?? this.routing,
      navigating: navigating ?? this.navigating,
      error: clearError ? null : (error ?? this.error),
      routeDistanceMeters: routeDistanceMeters ?? this.routeDistanceMeters,
      routeDurationSeconds: routeDurationSeconds ?? this.routeDurationSeconds,
      alternatives: alternatives ?? this.alternatives,
      alerts: clearAlerts ? const [] : (alerts ?? this.alerts),
      lastMonitoredAt: lastMonitoredAt ?? this.lastMonitoredAt,
      nearbyResults: clearNearby ? const [] : (nearbyResults ?? this.nearbyResults),
      nearbyCategory: clearNearby || clearNearbyCategory
          ? null
          : (nearbyCategory ?? this.nearbyCategory),
      nearbySearching: nearbySearching ?? this.nearbySearching,
    );
  }
}

class LiveNavInfo {
  final NavStep? currentStep;
  final int stepIndex;
  final double metersToManeuver;
  final double remainingMeters;
  final double remainingSeconds;
  final int? speedLimitKmh;
  final int? speedKmh;
  final SpeedCamera? nextCamera;
  final double? nextCameraMeters;
  final EmissionZone? currentZone;
  final double offRouteMeters;
  final bool offRoute;

  const LiveNavInfo({
    this.currentStep,
    this.stepIndex = 0,
    this.metersToManeuver = 0,
    required this.remainingMeters,
    this.remainingSeconds = 0,
    this.speedLimitKmh,
    this.speedKmh,
    this.nextCamera,
    this.nextCameraMeters,
    this.currentZone,
    this.offRouteMeters = 0,
    this.offRoute = false,
  });

  bool get speeding {
    final speed = speedKmh;
    final limit = speedLimitKmh;
    if (speed == null || limit == null) return false;
    return speed > limit + 2;
  }

  LiveNavInfo copyWith({
    NavStep? currentStep,
    int? stepIndex,
    double? metersToManeuver,
    double? remainingMeters,
    double? remainingSeconds,
    int? speedLimitKmh,
    int? speedKmh,
    SpeedCamera? nextCamera,
    double? nextCameraMeters,
    EmissionZone? currentZone,
    double? offRouteMeters,
    bool? offRoute,
  }) {
    return LiveNavInfo(
      currentStep: currentStep ?? this.currentStep,
      stepIndex: stepIndex ?? this.stepIndex,
      metersToManeuver: metersToManeuver ?? this.metersToManeuver,
      remainingMeters: remainingMeters ?? this.remainingMeters,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      speedLimitKmh: speedLimitKmh ?? this.speedLimitKmh,
      speedKmh: speedKmh ?? this.speedKmh,
      nextCamera: nextCamera ?? this.nextCamera,
      nextCameraMeters: nextCameraMeters ?? this.nextCameraMeters,
      currentZone: currentZone ?? this.currentZone,
      offRouteMeters: offRouteMeters ?? this.offRouteMeters,
      offRoute: offRoute ?? this.offRoute,
    );
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier(ref, NavigationService());
});

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier(this._ref, this._service) : super(const NavigationState()) {
    _ref.listen<LocationState>(locationProvider, (prev, next) {
      _onGps(next);
    });
  }

  final Ref _ref;
  final NavigationService _service;
  Timer? _debounce;
  Timer? _monitor;
  bool _checking = false;
  bool _monitoring = false;
  DateTime? _watchedAt;
  DateTime? _lastRerouteAt;
  double? _watchedDuration;
  double? _watchedDistance;
  Set<String> _watchedCameras = {};
  Set<String> _watchedZones = {};
  RouteMetrics? _metrics;
  List<LatLng> _metricsRoute = const [];
  List<NavStep> _metricsSteps = const [];

  void setActiveField(SearchField field) {
    if (state.activeField == field) return;
    state = state.copyWith(activeField: field, suggestions: const []);
  }

  void search(String query, {String lang = 'it', SearchField? field}) {
    final target = field ?? state.activeField;
    _debounce?.cancel();
    if (query.trim().length < 3) {
      state = state.copyWith(
        suggestions: const [],
        searching: false,
        activeField: target,
      );
      return;
    }
    state = state.copyWith(
      searching: true,
      activeField: target,
      clearError: true,
    );
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final loc = _ref.read(locationProvider);
        final hits = await _service.searchAddress(
          query.trim(),
          lang: lang,
          lat: loc.latitude,
          lon: loc.longitude,
        );
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

  void useMyLocationAsOrigin() {
    final loc = _ref.read(locationProvider);
    PlaceHit? origin;
    if (loc.latitude != null && loc.longitude != null) {
      origin = PlaceHit(
        label: 'La mia posizione',
        lat: loc.latitude!,
        lon: loc.longitude!,
      );
    }
    state = state.copyWith(
      origin: origin,
      originIsMyLocation: true,
      suggestions: const [],
      clearOrigin: origin == null,
      clearError: true,
    );
  }

  Future<void> selectPlace(PlaceHit place, {SearchField? field}) async {
    final target = field ?? state.activeField;
    if (target == SearchField.origin) {
      state = state.copyWith(
        origin: place,
        originIsMyLocation: false,
        suggestions: const [],
        activeField: SearchField.origin,
      );
    } else {
      state = state.copyWith(
        destination: place,
        suggestions: const [],
        activeField: SearchField.destination,
      );
    }
    await planRoute(startFollowing: false);
  }

  Future<void> goToPoi(PlaceHit place) async {
    useMyLocationAsOrigin();
    state = state.copyWith(
      destination: place,
      suggestions: const [],
      activeField: SearchField.destination,
    );
    await planRoute(startFollowing: false);
  }

  Future<void> searchNearby(String category, {double? lat, double? lon}) async {
    var useLat = lat;
    var useLon = lon;
    if (useLat == null || useLon == null) {
      final loc = _ref.read(locationProvider);
      useLat = loc.latitude;
      useLon = loc.longitude;
    }
    if (useLat == null || useLon == null) {
      state = state.copyWith(
        nearbySearching: false,
        nearbyCategory: category,
        nearbyResults: const [],
        error: 'Attiva il GPS per cercare in zona',
      );
      return;
    }
    state = state.copyWith(
      nearbySearching: true,
      nearbyCategory: category,
      nearbyResults: const [],
      suggestions: const [],
      clearError: true,
    );
    try {
      final hits = await _service.searchNearby(
        category: category,
        lat: useLat,
        lon: useLon,
      );
      final zones = _ref.read(zonesProvider).valueOrNull ?? const <EmissionZone>[];
      final tagged = hits
          .map((hit) {
            EmissionZone? zone;
            for (final z in zones) {
              if (isInsideZone(hit.lat, hit.lon, z)) {
                zone = z;
                break;
              }
            }
            return hit.copyWith(
              inLez: zone != null,
              zoneName: zone?.name,
            );
          })
          .toList();
      if (!mounted) return;
      state = state.copyWith(
        nearbyResults: tagged,
        nearbySearching: false,
        nearbyCategory: category,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        nearbySearching: false,
        nearbyCategory: category,
        nearbyResults: const [],
        error: 'Ricerca in zona non riuscita',
      );
    }
  }

  void clearNearby() {
    state = state.copyWith(clearNearby: true, nearbySearching: false);
  }

  void beginGuidance() {
    if (!state.hasRoute) return;
    state = state.copyWith(navigating: true, clearNearby: true, suggestions: const []);
    _ref.read(locationProvider.notifier).setFollow(true);
    _lastRerouteAt = null;
  }

  Future<void> startNavigation(PlaceHit place) {
    return selectPlace(place, field: SearchField.destination);
  }

  void swapEnds() {
    final loc = _ref.read(locationProvider);
    var origin = state.origin;
    if (state.originIsMyLocation &&
        loc.latitude != null &&
        loc.longitude != null) {
      origin = PlaceHit(
        label: 'La mia posizione',
        lat: loc.latitude!,
        lon: loc.longitude!,
      );
    }
    final dest = state.destination;
    state = state.copyWith(
      origin: dest,
      destination: origin,
      originIsMyLocation: false,
      suggestions: const [],
      clearOrigin: dest == null,
      clearDestination: origin == null,
    );
    if (state.origin != null && state.destination != null) {
      planRoute(startFollowing: false);
    }
  }

  ({double lat, double lon})? _originCoords() {
    if (!state.originIsMyLocation && state.origin != null) {
      return (lat: state.origin!.lat, lon: state.origin!.lon);
    }
    final loc = _ref.read(locationProvider);
    if (loc.latitude != null && loc.longitude != null) {
      return (lat: loc.latitude!, lon: loc.longitude!);
    }
    if (state.origin != null) {
      return (lat: state.origin!.lat, lon: state.origin!.lon);
    }
    return null;
  }

  Future<void> planRoute({bool startFollowing = false}) async {
    final dest = state.destination;
    if (dest == null) {
      state = state.copyWith(error: 'Inserisci un indirizzo di destinazione');
      return;
    }
    if (state.originIsMyLocation) {
      await _ref.read(locationProvider.notifier).startTracking();
    }
    final from = _originCoords();
    if (from == null) {
      state = state.copyWith(
        error: 'Attiva il GPS o inserisci un indirizzo di partenza',
        routing: false,
      );
      return;
    }

    final keepFollow = startFollowing || state.navigating;
    state = state.copyWith(
      routing: true,
      navigating: startFollowing || state.navigating,
      suggestions: const [],
      clearError: true,
      clearNearby: startFollowing,
    );
    if (keepFollow) {
      _ref.read(locationProvider.notifier).setFollow(true);
    } else {
      _ref.read(locationProvider.notifier).setFollow(false);
    }

    List<RoutePlan> plans = const [];
    try {
      final bundle = await _service.route(
        fromLat: from.lat,
        fromLon: from.lon,
        toLat: dest.lat,
        toLon: dest.lon,
      );
      plans = bundle.alternatives.where((p) => p.points.isNotEmpty).toList();
    } catch (_) {
      plans = const [];
    }

    if (plans.isEmpty) {
      plans = [
        RoutePlan(
          points: [
            [from.lon, from.lat],
            [dest.lon, dest.lat],
          ],
          steps: const [],
          speeds: const [],
          distanceMeters: haversineMeters(from.lat, from.lon, dest.lat, dest.lon),
          durationSeconds: 0,
        ),
      ];
    }

    final altPolylines = plans
        .map((p) => p.points.map((c) => LatLng(c[1], c[0])).toList())
        .toList();

    if (!mounted) return;
    state = state.copyWith(
      alternatives: plans,
      alternativeRoutes: altPolylines,
      selectedRoute: 0,
      clearAlerts: true,
    );
    await _applyPlan(plans.first, altPolylines.first, startFollowing: startFollowing);
    _armMonitor();
  }

  Future<void> selectAlternative(int index) async {
    if (index < 0 || index >= state.alternatives.length) return;
    await _applyPlan(
      state.alternatives[index],
      state.alternativeRoutes[index],
      startFollowing: state.navigating,
      selected: index,
    );
  }

  Future<void> _applyPlan(
    RoutePlan plan,
    List<LatLng> polyline, {
    required bool startFollowing,
    int selected = 0,
  }) async {
    final pathLatLon = polyline.map((p) => [p.latitude, p.longitude]).toList();
    final sampled = _samplePath(polyline, 28);
    final pathQuery = sampled
        .map((p) =>
            '${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}')
        .join(';');

    final lats = polyline.map((p) => p.latitude);
    final lons = polyline.map((p) => p.longitude);
    var minLat = lats.reduce((a, b) => a < b ? a : b) - 0.01;
    var maxLat = lats.reduce((a, b) => a > b ? a : b) + 0.01;
    var minLon = lons.reduce((a, b) => a < b ? a : b) - 0.01;
    var maxLon = lons.reduce((a, b) => a > b ? a : b) + 0.01;

    var cameras = const <SpeedCamera>[];
    var limits = const <SpeedLimitPoint>[];
    try {
      final hazards = await _service.hazards(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        path: pathQuery,
      );
      cameras = hazards.cameras
          .where((c) => isNearPath(c.lat, c.lon, pathLatLon, maxMeters: 160))
          .toList();
      limits = hazards.limits
          .where((p) => isNearPath(p.lat, p.lon, pathLatLon, maxMeters: 90))
          .toList();
    } catch (_) {}

    final zones = _ref.read(zonesProvider).valueOrNull ?? const <EmissionZone>[];
    final onRoute = <EmissionZone>[];
    final seen = <String>{};
    final step = polyline.length < 80 ? 1 : (polyline.length / 80).ceil();
    for (var i = 0; i < polyline.length; i += step) {
      final p = polyline[i];
      for (final zone in zones) {
        if (seen.contains(zone.id)) continue;
        if (isInsideZone(p.latitude, p.longitude, zone)) {
          seen.add(zone.id);
          onRoute.add(zone);
        }
      }
    }

    if (!mounted) return;
    final forecast = _forecastAlerts(
      polyline,
      plan.durationSeconds,
      onRoute,
    );
    _rememberSnapshot(
      duration: plan.durationSeconds,
      distance: plan.distanceMeters,
      cameras: cameras,
      zones: onRoute,
    );
    _invalidateMetrics();
    final navigating = startFollowing || state.navigating;
    state = state.copyWith(
      route: polyline,
      steps: plan.steps,
      cameras: cameras,
      limits: limits,
      annotationSpeeds: plan.speeds,
      zonesOnRoute: onRoute,
      routing: false,
      navigating: navigating,
      selectedRoute: selected,
      routeDistanceMeters: plan.distanceMeters,
      routeDurationSeconds: plan.durationSeconds,
      alerts: _mergeAlerts(forecast, replaceForecast: true),
      lastMonitoredAt: DateTime.now(),
    );
    if (navigating) {
      _ref.read(locationProvider.notifier).setFollow(true);
    }
  }

  List<LatLng> _samplePath(List<LatLng> route, int maxPoints) {
    if (route.length <= maxPoints) return route;
    final step = (route.length / maxPoints).ceil();
    final out = <LatLng>[];
    for (var i = 0; i < route.length; i += step) {
      out.add(route[i]);
    }
    if (out.last != route.last) out.add(route.last);
    return out;
  }

  void stopNavigation() {
    _monitor?.cancel();
    _monitor = null;
    _watchedAt = null;
    _lastRerouteAt = null;
    _watchedDuration = null;
    _watchedDistance = null;
    _watchedCameras = {};
    _watchedZones = {};
    _invalidateMetrics();
    _ref.read(locationProvider.notifier).setFollow(true);
    state = const NavigationState();
  }

  void dismissAlert(String id) {
    state = state.copyWith(
      alerts: state.alerts.where((a) => a.id != id).toList(),
    );
  }

  void setEndpoint(PlaceHit place, SearchField field) {
    if (field == SearchField.origin) {
      state = state.copyWith(
        origin: place,
        originIsMyLocation: false,
        suggestions: const [],
        activeField: SearchField.origin,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        destination: place,
        suggestions: const [],
        activeField: SearchField.destination,
        clearError: true,
      );
    }
  }

  void _armMonitor() {
    _monitor?.cancel();
    if (!state.hasRoute || state.destination == null) return;
    _monitor = Timer.periodic(const Duration(seconds: 45), (_) {
      unawaited(_refreshRouteConditions());
    });
  }

  void _rememberSnapshot({
    required double duration,
    required double distance,
    required List<SpeedCamera> cameras,
    required List<EmissionZone> zones,
  }) {
    _watchedAt = DateTime.now();
    _watchedDuration = duration;
    _watchedDistance = distance;
    _watchedCameras = {for (final c in cameras) c.id};
    _watchedZones = {for (final z in zones) z.id};
  }

  Future<void> _refreshRouteConditions() async {
    if (_monitoring || !mounted || state.routing || !state.hasRoute) return;
    final dest = state.destination;
    if (dest == null) return;
    final from = _originCoords();
    if (from == null) return;

    _monitoring = true;
    try {
      final bundle = await _service.route(
        fromLat: from.lat,
        fromLon: from.lon,
        toLat: dest.lat,
        toLon: dest.lon,
      );
      final plans = bundle.alternatives.where((p) => p.points.isNotEmpty).toList();
      if (plans.isEmpty || !mounted) return;
      final plan = plans.first;
      final polyline = plan.points.map((c) => LatLng(c[1], c[0])).toList();
      final sampled = _samplePath(polyline, 28);
      final pathQuery = sampled
          .map((p) =>
              '${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}')
          .join(';');
      final pathLatLon = polyline.map((p) => [p.latitude, p.longitude]).toList();

      var cameras = const <SpeedCamera>[];
      var limits = const <SpeedLimitPoint>[];
      try {
        final lats = polyline.map((p) => p.latitude);
        final lons = polyline.map((p) => p.longitude);
        final hazards = await _service.hazards(
          minLat: lats.reduce((a, b) => a < b ? a : b) - 0.01,
          minLon: lons.reduce((a, b) => a < b ? a : b) - 0.01,
          maxLat: lats.reduce((a, b) => a > b ? a : b) + 0.01,
          maxLon: lons.reduce((a, b) => a > b ? a : b) + 0.01,
          path: pathQuery,
        );
        cameras = hazards.cameras
            .where((c) => isNearPath(c.lat, c.lon, pathLatLon, maxMeters: 160))
            .toList();
        limits = hazards.limits
            .where((p) => isNearPath(p.lat, p.lon, pathLatLon, maxMeters: 90))
            .toList();
      } catch (_) {}

      final zones = _ref.read(zonesProvider).valueOrNull ?? const <EmissionZone>[];
      final onRoute = <EmissionZone>[];
      final seen = <String>{};
      final step = polyline.length < 80 ? 1 : (polyline.length / 80).ceil();
      for (var i = 0; i < polyline.length; i += step) {
        final p = polyline[i];
        for (final zone in zones) {
          if (seen.contains(zone.id)) continue;
          if (isInsideZone(p.latitude, p.longitude, zone)) {
            seen.add(zone.id);
            onRoute.add(zone);
          }
        }
      }

      if (!mounted) return;
      final incoming = [
        ..._diffAlerts(
          duration: plan.durationSeconds,
          distance: plan.distanceMeters,
          cameras: cameras,
          zones: onRoute,
        ),
        ..._forecastAlerts(polyline, plan.durationSeconds, onRoute),
      ];
      final changed = incoming.any((a) =>
          a.kind == RouteAlertKind.delay ||
          a.kind == RouteAlertKind.detour ||
          a.kind == RouteAlertKind.faster);
      _rememberSnapshot(
        duration: plan.durationSeconds,
        distance: plan.distanceMeters,
        cameras: cameras,
        zones: onRoute,
      );

      // Periodic traffic check must not rewrite the live polyline — that
      // resets step progress and stalls HUD ticks while OSRM/Overpass run.
      // Off-route reroute (8s) handles deviation; apply a new plan only
      // when delay/detour/faster is actually detected.
      final applyLive = changed;
      if (applyLive) {
        _invalidateMetrics();
        final altPolylines = plans
            .map((p) => p.points.map((c) => LatLng(c[1], c[0])).toList())
            .toList();
        state = state.copyWith(
          alternatives: plans,
          alternativeRoutes: altPolylines,
          selectedRoute: 0,
          route: polyline,
          steps: plan.steps,
          cameras: cameras,
          limits: limits,
          annotationSpeeds: plan.speeds,
          zonesOnRoute: onRoute,
          routeDistanceMeters: plan.distanceMeters,
          routeDurationSeconds: plan.durationSeconds,
          alerts: _mergeAlerts(incoming),
          lastMonitoredAt: DateTime.now(),
        );
        if (state.navigating) {
          _ref.read(locationProvider.notifier).setFollow(true);
        }
      } else {
        state = state.copyWith(
          cameras: cameras,
          limits: limits,
          zonesOnRoute: onRoute,
          alerts: _mergeAlerts(incoming),
          lastMonitoredAt: DateTime.now(),
        );
      }
    } catch (_) {
    } finally {
      _monitoring = false;
    }
  }

  List<RouteChangeAlert> _diffAlerts({
    required double duration,
    required double distance,
    required List<SpeedCamera> cameras,
    required List<EmissionZone> zones,
  }) {
    final now = DateTime.now();
    final alerts = <RouteChangeAlert>[];
    final elapsed = _watchedAt == null ? 0 : now.difference(_watchedAt!).inSeconds;
    final expectedDuration =
        (_watchedDuration ?? duration) - elapsed;
    final safeExpected = expectedDuration < 0 ? 0.0 : expectedDuration;

    if (duration > safeExpected + 120) {
      final extra = duration - safeExpected;
      alerts.add(RouteChangeAlert(
        id: 'delay-${now.millisecondsSinceEpoch}',
        kind: RouteAlertKind.delay,
        title: 'Ritardo sul percorso',
        message:
            'Il tragitto è più lento di ${formatDuration(extra)}. Ricalcolo in corso.',
        at: now,
        critical: extra >= 300,
      ));
    } else if (_watchedDuration != null &&
        duration + 180 < safeExpected &&
        _watchedDuration! > 240) {
      alerts.add(RouteChangeAlert(
        id: 'faster-${now.millisecondsSinceEpoch}',
        kind: RouteAlertKind.faster,
        title: 'Percorso più veloce',
        message:
            'Trovato un tragitto più rapido (${formatDuration(duration)}).',
        at: now,
      ));
    }

    if (_watchedDistance != null &&
        distance > _watchedDistance! * 1.12 + 400) {
      alerts.add(RouteChangeAlert(
        id: 'detour-${now.millisecondsSinceEpoch}',
        kind: RouteAlertKind.detour,
        title: 'Deviazione sul tragitto',
        message:
            'Il percorso è cambiato: ora ${formatDistance(distance)} invece di ${formatDistance(_watchedDistance)}.',
        at: now,
        critical: true,
      ));
    }

    final newCameras =
        cameras.where((c) => !_watchedCameras.contains(c.id)).toList();
    if (newCameras.isNotEmpty && _watchedCameras.isNotEmpty) {
      alerts.add(RouteChangeAlert(
        id: 'cam-${newCameras.first.id}',
        kind: RouteAlertKind.newCamera,
        title: 'Nuovo autovelox',
        message: newCameras.length == 1
            ? 'È comparso un autovelox sul percorso restante.'
            : 'Sono comparsi ${newCameras.length} autovelox sul percorso restante.',
        at: now,
      ));
    }

    final newZones = zones.where((z) => !_watchedZones.contains(z.id)).toList();
    if (newZones.isNotEmpty && _watchedZones.isNotEmpty) {
      alerts.add(RouteChangeAlert(
        id: 'zone-${newZones.first.id}',
        kind: RouteAlertKind.newZone,
        title: 'Nuova zona sul percorso',
        message:
            'Attenzione: ${newZones.map((z) => z.name).take(2).join(' · ')} ora rientra nel tragitto.',
        at: now,
        critical: true,
      ));
    }
    return alerts;
  }

  List<RouteChangeAlert> _forecastAlerts(
    List<LatLng> polyline,
    double durationSeconds,
    List<EmissionZone> onRoute,
  ) {
    if (onRoute.isEmpty || polyline.length < 2) return const [];
    final now = DateTime.now();
    final path = polyline.map((p) => [p.latitude, p.longitude]).toList();
    final alerts = <RouteChangeAlert>[];
    for (final zone in onRoute) {
      final eta = secondsToZoneEntry(
        pathLatLon: path,
        totalDurationSeconds: durationSeconds,
        zone: zone,
      );
      final arriveAt = now.add(
        Duration(seconds: (eta ?? durationSeconds).round()),
      );
      final activeNow = zone.isActiveAt(now);
      final activeThen = zone.isActiveAt(arriveAt);
      if (!activeNow && activeThen) {
        alerts.add(RouteChangeAlert(
          id: 'activate-${zone.id}',
          kind: RouteAlertKind.zoneActivating,
          title: 'Zona in attivazione',
          message:
              '${zone.name} si attiva mentre sei in viaggio (ingresso tra ${formatDuration(eta ?? durationSeconds)}).',
          at: now,
          critical: true,
        ));
      } else if (activeNow && !activeThen) {
        alerts.add(RouteChangeAlert(
          id: 'expire-${zone.id}',
          kind: RouteAlertKind.zoneExpiring,
          title: 'Zona in scadenza',
          message:
              '${zone.name} potrebbe non essere più attiva all’ingresso (tra ${formatDuration(eta ?? durationSeconds)}).',
          at: now,
        ));
      }
    }
    return alerts;
  }

  List<RouteChangeAlert> _mergeAlerts(
    List<RouteChangeAlert> incoming, {
    bool replaceForecast = false,
  }) {
    final now = DateTime.now();
    var existing = state.alerts
        .where((a) => now.difference(a.at) < const Duration(minutes: 12))
        .toList();
    if (replaceForecast) {
      existing = existing
          .where((a) =>
              a.kind != RouteAlertKind.zoneActivating &&
              a.kind != RouteAlertKind.zoneExpiring)
          .toList();
    }
    final keys = {for (final a in existing) '${a.kind}:${a.message}'};
    final merged = [...existing];
    for (final alert in incoming) {
      final key = '${alert.kind}:${alert.message}';
      if (keys.contains(key)) continue;
      keys.add(key);
      merged.insert(0, alert);
    }
    if (merged.length <= 5) return merged;
    return merged.take(5).toList();
  }

  void _invalidateMetrics() {
    _metrics = null;
    _metricsRoute = const [];
    _metricsSteps = const [];
  }

  RouteMetrics? _routeMetrics() {
    if (!state.hasRoute) return null;
    if (_metrics != null &&
        identical(state.route, _metricsRoute) &&
        identical(state.steps, _metricsSteps)) {
      return _metrics;
    }
    _metricsRoute = state.route;
    _metricsSteps = state.steps;
    _metrics = RouteMetrics.build(state.route, state.steps);
    return _metrics;
  }

  void _onGps(LocationState loc) {
    if (!state.navigating || !state.hasRoute || state.routing) return;
    if (loc.latitude == null || loc.longitude == null) return;
    final info = liveInfo(
      loc.latitude!,
      loc.longitude!,
      heading: loc.heading,
      accuracy: loc.accuracy,
      speedMps: loc.speed,
    );
    if (!info.offRoute) return;
    final accuracy = loc.accuracy ?? 0;
    if (accuracy >= 50) return;
    unawaited(_rerouteFromLiveGps());
  }

  Future<void> _rerouteFromLiveGps() async {
    if (_checking || !mounted || state.routing || !state.navigating) return;
    final dest = state.destination;
    if (dest == null) return;
    final now = DateTime.now();
    if (_lastRerouteAt != null &&
        now.difference(_lastRerouteAt!) < const Duration(seconds: 8)) {
      return;
    }
    final loc = _ref.read(locationProvider);
    if (loc.latitude == null || loc.longitude == null) return;
    _lastRerouteAt = now;
    _checking = true;
    try {
      final bundle = await _service.route(
        fromLat: loc.latitude!,
        fromLon: loc.longitude!,
        toLat: dest.lat,
        toLon: dest.lon,
      );
      final plans = bundle.alternatives.where((p) => p.points.isNotEmpty).toList();
      if (plans.isEmpty || !mounted) return;
      final altPolylines = plans
          .map((p) => p.points.map((c) => LatLng(c[1], c[0])).toList())
          .toList();
      state = state.copyWith(
        alternatives: plans,
        alternativeRoutes: altPolylines,
        selectedRoute: 0,
      );
      await _applyPlan(
        plans.first,
        altPolylines.first,
        startFollowing: true,
      );
      _armMonitor();
    } catch (_) {
    } finally {
      _checking = false;
    }
  }

  LiveNavInfo liveInfo(
    double lat,
    double lon, {
    double? heading,
    double? accuracy,
    double? speedMps,
  }) {
    final dest = state.destination;
    if (!state.hasRoute) {
      final remaining = dest == null
          ? 0.0
          : haversineMeters(lat, lon, dest.lat, dest.lon);
      return LiveNavInfo(
        remainingMeters: remaining,
        remainingSeconds: 0,
        speedKmh: gpsSpeedKmh(speedMps),
      );
    }

    final metrics = _routeMetrics();
    final fix = computeGuidance(
      lat: lat,
      lon: lon,
      heading: heading,
      route: state.route,
      steps: state.steps,
      metrics: metrics,
    );

    int? limit;
    final cum = metrics?.cum;
    if (cum != null && cum.length == state.route.length) {
      limit = currentSpeedLimitKmh(
        alongMeters: fix.alongMeters,
        route: state.route,
        cum: cum,
        limits: state.limits,
        annotationSpeeds: state.annotationSpeeds,
        segmentIndex: fix.segmentIndex,
      );
    }
    if (limit == null) {
      var limitDist = double.infinity;
      for (final p in state.limits) {
        final d = haversineMeters(lat, lon, p.lat, p.lon);
        if (d < limitDist && d < 180) {
          limitDist = d;
          limit = p.maxspeed;
        }
      }
    }

    SpeedCamera? camera;
    double? cameraMeters;
    if (cum != null && cum.length == state.route.length) {
      for (final c in state.cameras) {
        final snap = projectOntoPolyline(c.lat, c.lon, state.route, cum);
        if (snap == null || snap.offsetMeters > 160) continue;
        final ahead = snap.alongMeters - fix.alongMeters;
        if (ahead < -25 || ahead > 1200) continue;
        final d = ahead < 0 ? 0.0 : ahead;
        if (cameraMeters == null || d < cameraMeters) {
          camera = c;
          cameraMeters = d;
        }
      }
    }
    if (camera == null) {
      for (final c in state.cameras) {
        final d = haversineMeters(lat, lon, c.lat, c.lon);
        if (d > 1200) continue;
        if (cameraMeters == null || d < cameraMeters) {
          camera = c;
          cameraMeters = d;
        }
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

    var remainingSeconds = state.routeDurationSeconds ?? 0;
    final totalDist = metrics?.totalMeters ?? state.routeDistanceMeters;
    final totalDur = state.routeDurationSeconds;
    if (totalDist != null && totalDist > 0 && totalDur != null) {
      remainingSeconds = fix.remainingMeters / totalDist * totalDur;
    }

    return LiveNavInfo(
      currentStep: fix.currentStep,
      stepIndex: fix.stepIndex,
      metersToManeuver: fix.metersToManeuver,
      remainingMeters: fix.remainingMeters,
      remainingSeconds: remainingSeconds,
      speedLimitKmh: limit,
      speedKmh: gpsSpeedKmh(speedMps),
      nextCamera: camera,
      nextCameraMeters: cameraMeters,
      currentZone: currentZone,
      offRouteMeters: fix.offRouteMeters,
      offRoute: fix.offRoute && (accuracy == null || accuracy < 50),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _monitor?.cancel();
    super.dispose();
  }
}
