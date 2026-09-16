import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/emission_zone.dart';
import '../models/navigation_models.dart';
import '../models/zone_status.dart';
import '../services/dropoff_planner.dart';
import '../services/geo_utils.dart';
import '../services/navigation_guidance.dart';
import '../services/navigation_service.dart';
import 'location_provider.dart';
import 'settings_provider.dart';
import 'vehicle_provider.dart';
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
  final TravelMode mode;
  final bool recalculating;
  final bool usingDropOff;
  final bool walkLegActive;
  final PlaceHit? dropOff;
  final List<LatLng> walkRoute;
  final List<NavStep> walkSteps;
  final double? walkMeters;
  final String? dropOffMessage;

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
    this.mode = TravelMode.car,
    this.recalculating = false,
    this.usingDropOff = false,
    this.walkLegActive = false,
    this.dropOff,
    this.walkRoute = const [],
    this.walkSteps = const [],
    this.walkMeters,
    this.dropOffMessage,
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
    TravelMode? mode,
    bool? recalculating,
    bool? usingDropOff,
    bool? walkLegActive,
    PlaceHit? dropOff,
    List<LatLng>? walkRoute,
    List<NavStep>? walkSteps,
    double? walkMeters,
    String? dropOffMessage,
    bool clearOrigin = false,
    bool clearDestination = false,
    bool clearError = false,
    bool clearAlerts = false,
    bool clearNearby = false,
    bool clearNearbyCategory = false,
    bool clearDropOff = false,
    bool clearWalkMeters = false,
    bool clearDropOffMessage = false,
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
      mode: mode ?? this.mode,
      recalculating: recalculating ?? this.recalculating,
      usingDropOff: usingDropOff ?? this.usingDropOff,
      walkLegActive: walkLegActive ?? this.walkLegActive,
      dropOff: clearDropOff ? null : (dropOff ?? this.dropOff),
      walkRoute: walkRoute ?? this.walkRoute,
      walkSteps: walkSteps ?? this.walkSteps,
      walkMeters: clearWalkMeters ? null : (walkMeters ?? this.walkMeters),
      dropOffMessage: clearDropOffMessage
          ? null
          : (dropOffMessage ?? this.dropOffMessage),
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

  TravelMode get _travelMode => _ref.read(travelModeProvider);

  String _routeErrorMessage(Object e, TravelMode mode) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        final msg = (data['error'] as String).trim();
        if (msg.isNotEmpty) return msg;
      }
    }
    switch (mode) {
      case TravelMode.transit:
        return 'Percorso mezzi non disponibile. Riprova più tardi.';
      case TravelMode.foot:
        return 'Percorso a piedi non disponibile. Riprova più tardi.';
      case TravelMode.car:
        return 'Percorso non disponibile. Riprova più tardi.';
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
      recalculating: false,
    );
    if (keepFollow) {
      _ref.read(locationProvider.notifier).setFollow(true);
    } else {
      _ref.read(locationProvider.notifier).setFollow(false);
    }

    List<RoutePlan> plans = const [];
    String? routeError;
    final mode = _travelMode;
    try {
      final bundle = await _service.route(
        fromLat: from.lat,
        fromLon: from.lon,
        toLat: dest.lat,
        toLon: dest.lon,
        mode: mode,
      );
      plans = bundle.alternatives.where((p) => p.points.isNotEmpty).toList();
    } catch (e) {
      routeError = _routeErrorMessage(e, mode);
      plans = const [];
    }

    if (plans.isEmpty) {
      if (state.navigating && state.hasRoute) {
        if (!mounted) return;
        state = state.copyWith(
          routing: false,
          error: routeError ?? 'Ricalcolo non riuscito, restiamo sul percorso',
        );
        return;
      }
      if (mode != TravelMode.car) {
        if (!mounted) return;
        state = state.copyWith(
          routing: false,
          navigating: false,
          mode: mode,
          error: routeError ??
              (mode == TravelMode.transit
                  ? 'Nessun mezzo trovato per questo tragitto.'
                  : 'Percorso a piedi non disponibile. Riprova più tardi.'),
        );
        return;
      }
      plans = [
        RoutePlan(
          mode: TravelMode.car,
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

    if (mode == TravelMode.car) {
      plans = await _withDropOffOptions(
        from: from,
        dest: dest,
        plans: plans,
      );
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
    if (plan.mode.isCar) {
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
    }

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
    _rememberSnapshot(
      duration: plan.durationSeconds,
      distance: plan.distanceMeters,
      cameras: cameras,
      zones: onRoute,
    );
    _invalidateMetrics();
    final navigating = startFollowing || state.navigating;
    final isDrop = plan.isDropOff;
    final walkPts = plan.walkPoints
        .map((c) => LatLng(c[1], c[0]))
        .where((p) => p.latitude.isFinite && p.longitude.isFinite)
        .toList();
    var alerts = _forecastAlerts(
      polyline,
      plan.durationSeconds,
      onRoute,
    );
    if (isDrop && !navigating) {
      alerts = [
        RouteChangeAlert(
          id: 'dropoff-${plan.dropOff?.lat}-${plan.dropOff?.lon}',
          kind: RouteAlertKind.detour,
          title: 'Sosta e ultimi metri a piedi',
          message: _dropOffMessage(plan),
          at: DateTime.now(),
          critical: true,
        ),
        ...alerts,
      ];
    } else if (plan.isDriveToDoor && !navigating) {
      alerts = [
        RouteChangeAlert(
          id: 'door-lez-${plan.zoneName}',
          kind: RouteAlertKind.newZone,
          title: 'Tratto in milieuzone',
          message: _doorWarning(plan),
          at: DateTime.now(),
          critical: true,
        ),
        ...alerts,
      ];
    }
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
      mode: plan.mode,
      routeDistanceMeters: plan.distanceMeters,
      routeDurationSeconds: plan.durationSeconds,
      alerts: _mergeAlerts(alerts, replaceForecast: true),
      lastMonitoredAt: DateTime.now(),
      recalculating: false,
      usingDropOff: isDrop,
      walkLegActive: false,
      dropOff: isDrop ? plan.dropOff : null,
      walkRoute: isDrop ? walkPts : const [],
      walkSteps: isDrop ? plan.walkSteps : const [],
      walkMeters: isDrop ? plan.walkMeters : null,
      dropOffMessage: isDrop
          ? _dropOffMessage(plan)
          : (plan.isDriveToDoor ? _doorWarning(plan) : null),
      clearDropOff: !isDrop,
      clearWalkMeters: !isDrop,
      clearDropOffMessage: !isDrop && !plan.isDriveToDoor,
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

  String _dropOffMessage(RoutePlan plan) {
    final walk = formatDistance(plan.walkMeters);
    final zone = (plan.zoneName ?? '').trim();
    final zoneBit = zone.isEmpty ? 'la milieuzone' : zone;
    if ((plan.insideZoneMeters ?? 0) >= kLongLezDriveMeters) {
      return 'Il percorso fino alla porta ti fa percorrere tanta $zoneBit. '
          'Meglio avvicinarti e poi camminare $walk.';
    }
    return 'Destinazione dentro $zoneBit e il veicolo non è autorizzato. '
        'Avvicinati al bordo e cammina $walk.';
  }

  String _doorWarning(RoutePlan plan) {
    final zone = (plan.zoneName ?? 'milieuzone').trim();
    return 'Attenzione: tratto lungo in $zone. Veicolo non autorizzato.';
  }

  PlaceHit? get _rerouteTarget {
    if (state.walkLegActive) return state.destination;
    if (state.usingDropOff && state.dropOff != null) return state.dropOff;
    return state.destination;
  }

  TravelMode get _rerouteMode {
    if (state.walkLegActive) return TravelMode.foot;
    return state.mode;
  }

  Future<List<RoutePlan>> _withDropOffOptions({
    required ({double lat, double lon}) from,
    required PlaceHit dest,
    required List<RoutePlan> plans,
  }) async {
    final zones = _ref.read(zonesProvider).valueOrNull ?? const <EmissionZone>[];
    final vehicle = _ref.read(vehicleProvider).valueOrNull;
    final denying = denyingZonesAt(
      lat: dest.lat,
      lon: dest.lon,
      zones: zones,
      vehicle: vehicle,
    );
    if (denying.isEmpty) return plans;
    if (!originOutsideDenyingZones(
      lat: from.lat,
      lon: from.lon,
      denyingZones: denying,
    )) {
      return plans;
    }

    final door = plans.first;
    final doorPath = door.points
        .map((c) => c.length >= 2 ? <double>[c[1], c[0]] : const <double>[])
        .where((c) => c.length >= 2)
        .toList();
    final insideM = insideDriveMetersFor(doorPath, denying);
    final hint = suggestDropOff(
      destLat: dest.lat,
      destLon: dest.lon,
      denyingZones: denying,
      insideDriveMeters: insideM,
      originLat: from.lat,
      originLon: from.lon,
      originKnown: true,
    );
    if (hint == null) return plans;

    RoutePlan? carToCurb;
    RoutePlan? walkToDoor;
    try {
      final carBundle = await _service.route(
        fromLat: from.lat,
        fromLon: from.lon,
        toLat: hint.lat,
        toLon: hint.lon,
        mode: TravelMode.car,
      );
      carToCurb = carBundle.alternatives.where((p) => p.points.isNotEmpty).isEmpty
          ? null
          : carBundle.alternatives.where((p) => p.points.isNotEmpty).first;
      final walkBundle = await _service.route(
        fromLat: hint.lat,
        fromLon: hint.lon,
        toLat: dest.lat,
        toLon: dest.lon,
        mode: TravelMode.foot,
      );
      walkToDoor = walkBundle.alternatives
          .where((p) => p.points.isNotEmpty)
          .firstOrNull;
    } catch (_) {
      return plans;
    }
    if (carToCurb == null || walkToDoor == null) return plans;

    final curbInside = insideDriveMetersFor(
      carToCurb.points
          .map((c) => c.length >= 2 ? <double>[c[1], c[0]] : const <double>[])
          .where((c) => c.length >= 2)
          .toList(),
      denying,
    );
    if (curbInside > insideM && curbInside > 80) {
      return plans;
    }

    final dropHit = PlaceHit(
      label: 'Sosta a ${formatDistance(hint.walkMeters)} a piedi',
      lat: hint.lat,
      lon: hint.lon,
    );
    final recommended = carToCurb.copyWith(
      kind: RouteOptionKind.dropOff,
      walkMeters: walkToDoor.distanceMeters > 0
          ? walkToDoor.distanceMeters
          : hint.walkMeters,
      dropOff: dropHit,
      walkPoints: walkToDoor.points,
      walkSteps: walkToDoor.steps,
      insideZoneMeters: insideM,
      zoneName: hint.zone.name,
      durationSeconds: carToCurb.durationSeconds + walkToDoor.durationSeconds,
    );
    final warnedDoor = door.copyWith(
      kind: RouteOptionKind.driveToDoor,
      insideZoneMeters: insideM,
      zoneName: hint.zone.name,
    );
    final rest = plans.skip(1).where((p) => !identical(p, door)).toList();
    return [recommended, warnedDoor, ...rest];
  }

  Future<void> _startWalkRemainder() async {
    if (!mounted || !state.usingDropOff || state.walkLegActive) return;
    final dest = state.destination;
    var walk = state.walkRoute;
    var steps = state.walkSteps;
    var meters = state.walkMeters ?? 0;
    var seconds = meters > 0 ? meters / 1.3 : 0.0;
    if (walk.length < 2 && dest != null) {
      final loc = _ref.read(locationProvider);
      if (loc.latitude == null || loc.longitude == null) return;
      try {
        final bundle = await _service.route(
          fromLat: loc.latitude!,
          fromLon: loc.longitude!,
          toLat: dest.lat,
          toLon: dest.lon,
          mode: TravelMode.foot,
        );
        final plan = bundle.alternatives
            .where((p) => p.points.isNotEmpty)
            .firstOrNull;
        if (plan != null) {
          walk = plan.points.map((c) => LatLng(c[1], c[0])).toList();
          steps = plan.steps;
          meters = plan.distanceMeters;
          seconds = plan.durationSeconds;
        }
      } catch (_) {}
    }
    if (walk.length < 2) return;
    _invalidateMetrics();
    state = state.copyWith(
      route: walk,
      steps: steps,
      mode: TravelMode.foot,
      walkLegActive: true,
      navigating: true,
      routing: false,
      recalculating: false,
      routeDistanceMeters: meters,
      routeDurationSeconds: seconds,
      alternativeRoutes: const [],
      selectedRoute: 0,
    );
    _ref.read(locationProvider.notifier).setFollow(true);
    _armMonitor();
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
    final dest = _rerouteTarget;
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
        mode: _rerouteMode,
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
      if (plan.mode.isCar) {
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
      }

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
          mode: _rerouteMode,
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
    if (!state.navigating || !state.hasRoute) return;
    if (loc.latitude == null || loc.longitude == null) return;
    if (state.usingDropOff &&
        !state.walkLegActive &&
        state.dropOff != null) {
      final toCurb = haversineMeters(
        loc.latitude!,
        loc.longitude!,
        state.dropOff!.lat,
        state.dropOff!.lon,
      );
      if (toCurb < 45) {
        unawaited(_startWalkRemainder());
        return;
      }
    }
    if (state.routing) return;
    final info = liveInfo(
      loc.latitude!,
      loc.longitude!,
      heading: loc.heading,
      accuracy: loc.accuracy,
      speedMps: loc.speed,
    );
    if (!info.offRoute) return;
    unawaited(_rerouteFromLiveGps());
  }

  Future<void> _rerouteFromLiveGps() async {
    if (_checking || !mounted || !state.navigating) return;
    final dest = _rerouteTarget;
    if (dest == null) return;
    final now = DateTime.now();
    if (_lastRerouteAt != null &&
        now.difference(_lastRerouteAt!) < const Duration(seconds: 4)) {
      return;
    }
    final loc = _ref.read(locationProvider);
    if (loc.latitude == null || loc.longitude == null) return;
    _lastRerouteAt = now;
    _checking = true;
    final previous = state;
    state = state.copyWith(
      recalculating: true,
      originIsMyLocation: true,
      origin: PlaceHit(
        label: 'La mia posizione',
        lat: loc.latitude!,
        lon: loc.longitude!,
      ),
    );
    try {
      final bundle = await _service.route(
        fromLat: loc.latitude!,
        fromLon: loc.longitude!,
        toLat: dest.lat,
        toLon: dest.lon,
        mode: _rerouteMode,
      );
      final plans =
          bundle.alternatives.where((p) => p.points.isNotEmpty).toList();
      if (!mounted) return;
      if (plans.isEmpty) {
        state = previous.copyWith(recalculating: false);
        return;
      }
      var plan = plans.first;
      if (previous.usingDropOff &&
          !previous.walkLegActive &&
          previous.dropOff != null) {
        plan = plan.copyWith(
          kind: RouteOptionKind.dropOff,
          walkMeters: previous.walkMeters,
          dropOff: previous.dropOff,
          walkPoints: previous.walkRoute
              .map((p) => <double>[p.longitude, p.latitude])
              .toList(),
          walkSteps: previous.walkSteps,
        );
      }
      final altPolylines = plans
          .map((p) => p.points.map((c) => LatLng(c[1], c[0])).toList())
          .toList();
      state = state.copyWith(
        alternatives: plans,
        alternativeRoutes: altPolylines,
        selectedRoute: 0,
        recalculating: false,
      );
      await _applyPlan(
        plan,
        altPolylines.first,
        startFollowing: true,
      );
      if (previous.usingDropOff && !previous.walkLegActive) {
        state = state.copyWith(
          usingDropOff: true,
          walkLegActive: false,
          dropOff: previous.dropOff,
          walkRoute: previous.walkRoute,
          walkSteps: previous.walkSteps,
          walkMeters: previous.walkMeters,
          dropOffMessage: previous.dropOffMessage,
        );
      }
      if (previous.walkLegActive) {
        state = state.copyWith(
          usingDropOff: true,
          walkLegActive: true,
          mode: TravelMode.foot,
          dropOff: previous.dropOff,
          walkMeters: previous.walkMeters,
          dropOffMessage: previous.dropOffMessage,
        );
      }
      _armMonitor();
    } catch (_) {
      if (!mounted) return;
      state = previous.copyWith(recalculating: false);
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
    final acc = accuracy ?? 0;
    final threshold = acc > 40
        ? (acc * 0.55 + 45).clamp(90.0, 180.0).toDouble()
        : kOffRouteMeters;
    final fix = computeGuidance(
      lat: lat,
      lon: lon,
      heading: heading,
      route: state.route,
      steps: state.steps,
      metrics: metrics,
      offRouteThreshold: threshold,
    );

    final target = _rerouteTarget;
    final crowToTarget = target == null
        ? fix.remainingMeters
        : haversineMeters(lat, lon, target.lat, target.lon);
    var offRoute = fix.offRoute;
    if (crowToTarget > 80 && fix.remainingMeters < 40) {
      offRoute = true;
    }

    var remainingMeters = offRoute ? crowToTarget : fix.remainingMeters;
    if (state.usingDropOff && !state.walkLegActive && !offRoute) {
      remainingMeters += state.walkMeters ?? 0;
    }

    NavStep? step = fix.currentStep;
    if (offRoute || state.recalculating) {
      step = const NavStep(
        type: 'continue',
        modifier: '',
        name: 'Ricalcolo percorso',
        distanceMeters: 0,
      );
    }

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
    if (totalDist != null && totalDist > 0 && totalDur != null && !offRoute) {
      remainingSeconds = fix.remainingMeters / totalDist * totalDur;
    } else if (offRoute && remainingMeters > 0) {
      remainingSeconds = remainingMeters / 11.0;
    }

    return LiveNavInfo(
      currentStep: step,
      stepIndex: fix.stepIndex,
      metersToManeuver:
          offRoute || state.recalculating ? remainingMeters : fix.metersToManeuver,
      remainingMeters: remainingMeters,
      remainingSeconds: remainingSeconds,
      speedLimitKmh: limit,
      speedKmh: gpsSpeedKmh(speedMps),
      nextCamera: camera,
      nextCameraMeters: cameraMeters,
      currentZone: currentZone,
      offRouteMeters: fix.offRouteMeters,
      offRoute: offRoute,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _monitor?.cancel();
    super.dispose();
  }
}
