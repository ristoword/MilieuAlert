import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../models/emission_zone.dart';
import '../../models/navigation_models.dart';
import '../../models/poi_category.dart';
import '../../models/zone_status.dart';
import '../../models/saved_places.dart';
import '../../providers/ai_assist_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/zone_provider.dart';
import 'widgets/ai_assist_sheet.dart';
import 'widgets/ai_hint_banner.dart';
import 'widgets/alert_banner.dart';
import 'widgets/apple_eta_tray.dart';
import 'widgets/apple_guidance_card.dart';
import 'widgets/favorites_panel.dart';
import 'widgets/incident_banners.dart';
import 'widgets/map_pins.dart';
import 'widgets/search_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.openNavigation = false});

  /// When true (`/map?nav=1`), focus the A→B destination field.
  final bool openNavigation;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with WidgetsBindingObserver {
  static const _distance = Distance();

  final MapController _mapController = MapController();
  final TextEditingController _originCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();
  final FocusNode _originFocus = FocusNode();
  final FocusNode _destFocus = FocusNode();
  bool _movedToUser = false;
  bool _sheetExpanded = false;
  bool _trayExpanded = false;
  bool _wasGuiding = false;
  String? _seenTopAlertKey;
  String? _seenCameraAlertId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _originCtrl.text = 'La mia posizione';
    _originFocus.addListener(() {
      if (_originFocus.hasFocus) {
        ref.read(navigationProvider.notifier).setActiveField(SearchField.origin);
        _expandSheetForInput();
      }
    });
    _destFocus.addListener(() {
      if (_destFocus.hasFocus) {
        ref
            .read(navigationProvider.notifier)
            .setActiveField(SearchField.destination);
        _expandSheetForInput();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = ref.read(locationProvider.notifier);
      loc.startTracking();
      loc.setFollow(true);
      if (widget.openNavigation) _enterNavMode();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(locationProvider.notifier).startTracking(restart: true);
    }
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openNavigation && !oldWidget.openNavigation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _enterNavMode();
      });
    }
  }

  void _enterNavMode() {
    ref.read(navigationProvider.notifier).setActiveField(SearchField.destination);
    setState(() => _sheetExpanded = true);
    _destFocus.requestFocus();
  }

  void _expandSheetForInput() {
    if (_sheetExpanded) return;
    setState(() => _sheetExpanded = true);
  }

  bool _zoneAlertActive(ZoneProximity? zone) =>
      zone != null && zone.status != ZoneStatus.safe;

  String _topAlertKey({
    required ZoneProximity? zone,
    required List<RouteChangeAlert> alerts,
    required String? hintText,
  }) {
    final parts = <String>[];
    if (_zoneAlertActive(zone)) {
      parts.add('z:${zone!.zoneId}:${zone.status}:${zone.isVehicleAllowed}');
    }
    if (alerts.isNotEmpty) {
      parts.add('a:${alerts.map((a) => a.id).join(',')}');
    }
    if (hintText != null && hintText.isNotEmpty) {
      parts.add('h:$hintText');
    }
    return parts.join('|');
  }

  void _toggleSheet() {
    setState(() {
      _sheetExpanded = !_sheetExpanded;
      if (!_sheetExpanded) FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  void _toggleTray([bool? expanded]) {
    setState(() {
      _trayExpanded = expanded ?? !_trayExpanded;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _originCtrl.dispose();
    _destCtrl.dispose();
    _originFocus.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  void _fitRoute(List<LatLng> route) {
    if (route.length < 2) return;
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(route),
          padding: EdgeInsets.fromLTRB(
            36,
            120,
            36,
            _trayExpanded ? 240 : 140,
          ),
          maxZoom: 15,
        ),
      );
    } catch (_) {}
  }

  void _moveToUser(double lat, double lon, {double? zoom}) {
    try {
      final z = zoom ?? _mapController.camera.zoom;
      _mapController.move(LatLng(lat, lon), z);
    } catch (_) {}
  }

  void _pauseFollowIfUserPanned(MapCamera camera) {
    final loc = ref.read(locationProvider);
    if (!loc.follow || loc.latitude == null || loc.longitude == null) return;
    final meters = _distance.as(
      LengthUnit.Meter,
      LatLng(loc.latitude!, loc.longitude!),
      camera.center,
    );
    if (meters > 50) {
      ref.read(locationProvider.notifier).setFollow(false);
    }
  }

  Widget _recenterButton(LocationState location) {
    return _RoundMapButton(
      icon: location.follow ? Icons.gps_fixed : Icons.gps_not_fixed,
      tooltip: location.follow ? 'Centrato' : 'Ricentra',
      emphasized: !location.follow,
      onTap: _recenter,
    );
  }

  void _fitPois(List<PlaceHit> hits, LocationState location) {
    if (hits.isEmpty) return;
    ref.read(locationProvider.notifier).setFollow(false);
    final pts = hits.map((h) => LatLng(h.lat, h.lon)).toList();
    if (location.latitude != null && location.longitude != null) {
      pts.add(LatLng(location.latitude!, location.longitude!));
    }
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(pts),
          padding: const EdgeInsets.fromLTRB(40, 80, 40, 280),
          maxZoom: 15,
        ),
      );
    } catch (_) {}
  }

  void _showOverview() {
    final nav = ref.read(navigationProvider);
    ref.read(locationProvider.notifier).setFollow(false);
    _fitRoute(nav.route);
    setState(() => _trayExpanded = true);
  }

  void _recenter() {
    final loc = ref.read(locationProvider);
    ref.read(locationProvider.notifier).setFollow(true);
    ref.read(locationProvider.notifier).startTracking();
    if (loc.latitude != null && loc.longitude != null) {
      _moveToUser(loc.latitude!, loc.longitude!, zoom: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final zonesAsync = ref.watch(zonesProvider);
    final nav = ref.watch(navigationProvider);
    final ai = ref.watch(aiAssistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;

    ref.listen(locationProvider, (prev, next) {
      if (next.latitude == null || next.longitude == null) return;
      // Follow the puck whenever follow is on — including walking with no
      // destination. During A→B, only follow when origin is "my location".
      final followLive =
          next.follow && (!nav.navigating || nav.originIsMyLocation);
      if (!_movedToUser || followLive) {
        final zoom = _movedToUser ? null : 16.0;
        _movedToUser = true;
        _moveToUser(next.latitude!, next.longitude!, zoom: zoom);
      }
    });

    ref.listen(navigationProvider, (prev, next) {
      if (next.originIsMyLocation &&
          (prev == null || !prev.originIsMyLocation) &&
          !_originFocus.hasFocus) {
        _originCtrl.text = 'La mia posizione';
      } else if (!next.originIsMyLocation &&
          next.origin != null &&
          next.origin!.label != prev?.origin?.label &&
          !_originFocus.hasFocus) {
        _originCtrl.text = next.origin!.label;
      }
      if (next.destination != null &&
          next.destination!.label != prev?.destination?.label &&
          !_destFocus.hasFocus) {
        _destCtrl.text = next.destination!.label;
      }
      if (next.nearbyResults.isNotEmpty &&
          next.nearbyResults != prev?.nearbyResults) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fitPois(next.nearbyResults, ref.read(locationProvider));
        });
      }
      if (!next.hasRoute) return;
      final routeChanged = prev?.selectedRoute != next.selectedRoute ||
          prev?.routeDistanceMeters != next.routeDistanceMeters ||
          prev?.destination?.label != next.destination?.label;
      if (routeChanged && !(next.navigating && prev?.hasRoute == true)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fitRoute(next.route);
        });
      }
      final justPlanned = prev?.routing == true && !next.routing;
      if (justPlanned && next.destination != null) {
        ref.read(favoritesProvider.notifier).rememberSuccessfulTrip(
              origin: next.origin,
              originIsMyLocation: next.originIsMyLocation,
              destination: next.destination!,
              location: ref.read(locationProvider),
            );
      }
    });

    final center = LatLng(
      location.latitude ?? AppConstants.initialLat,
      location.longitude ?? AppConstants.initialLng,
    );

    LiveNavInfo? live;
    if (location.latitude != null && location.longitude != null) {
      live = ref
          .read(navigationProvider.notifier)
          .liveInfo(location.latitude!, location.longitude!);
    }

    final guiding = nav.navigating;
    final topAlertKey = _topAlertKey(
      zone: location.nearestZone,
      alerts: nav.alerts,
      hintText: ai.hint?.text,
    );
    final nextCamera = live?.nextCamera;
    final cameraId =
        nextCamera != null && (live?.nextCameraMeters ?? 9999) <= 1000
            ? nextCamera.id
            : null;
    final needsChromeSync = guiding != _wasGuiding ||
        topAlertKey != (_seenTopAlertKey ?? '') ||
        cameraId != _seenCameraAlertId ||
        (nav.suggestions.isNotEmpty && !_sheetExpanded);
    if (needsChromeSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (guiding != _wasGuiding) {
            _wasGuiding = guiding;
            if (guiding) {
              _sheetExpanded = false;
              _trayExpanded = topAlertKey.isNotEmpty;
              FocusManager.instance.primaryFocus?.unfocus();
            } else {
              _sheetExpanded = true;
              _trayExpanded = false;
              _seenCameraAlertId = null;
            }
          }
          if (topAlertKey != (_seenTopAlertKey ?? '')) {
            _seenTopAlertKey = topAlertKey.isEmpty ? null : topAlertKey;
            if (guiding && topAlertKey.isNotEmpty) {
              _trayExpanded = true;
            }
          }
          if (cameraId != _seenCameraAlertId) {
            _seenCameraAlertId = cameraId;
            if (guiding && cameraId != null) {
              _trayExpanded = true;
            }
          }
          if (nav.suggestions.isNotEmpty) {
            _sheetExpanded = true;
          }
        });
      });
    }

    final originPoint = !nav.originIsMyLocation && nav.origin != null
        ? LatLng(nav.origin!.lat, nav.origin!.lon)
        : null;

    final showCameraBanner =
        guiding && nextCamera != null && (live?.nextCameraMeters ?? 9999) <= 1000;

    return Scaffold(
      bottomNavigationBar: const MainBottomNav(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: location.latitude != null
                  ? 13
                  : AppConstants.initialZoom,
              onTap: (_, __) => FocusScope.of(context).unfocus(),
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) _pauseFollowIfUserPanned(pos);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? AppConstants.osmTileUrl
                    : AppConstants.osmTileUrlLight,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.milieualert.app',
              ),
              zonesAsync.when(
                data: (zones) => PolygonLayer(
                  polygons: _polygonsFor(zones, nav.zonesOnRoute),
                ),
                loading: () => const PolygonLayer(polygons: <Polygon>[]),
                error: (_, __) => const PolygonLayer(polygons: <Polygon>[]),
              ),
              if (nav.alternativeRoutes.length > 1)
                PolylineLayer(
                  polylines: [
                    for (var i = 0; i < nav.alternativeRoutes.length; i++)
                      if (i != nav.selectedRoute &&
                          nav.alternativeRoutes[i].length >= 2)
                        Polyline(
                          points: nav.alternativeRoutes[i],
                          color: MapsColors.routeAlt,
                          strokeWidth: 6,
                        ),
                  ],
                ),
              if (nav.route.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: nav.route,
                      color: MapsColors.routeCasing,
                      strokeWidth: 11,
                    ),
                    Polyline(
                      points: nav.route,
                      color: MapsColors.route,
                      strokeWidth: 7,
                    ),
                  ],
                ),
              MarkerLayer(markers: [
                if (!guiding)
                  for (final poi in nav.nearbyResults)
                    Marker(
                      point: LatLng(poi.lat, poi.lon),
                      width: 32,
                      height: 32,
                      child: PoiPin(hit: poi),
                    ),
                ...nav.cameras.map(
                  (c) => Marker(
                    point: LatLng(c.lat, c.lon),
                    width: 34,
                    height: 34,
                    child: const CameraPin(),
                  ),
                ),
                if (originPoint != null)
                  Marker(
                    point: originPoint,
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.trip_origin,
                      color: Color(0xFF34C759),
                      size: 28,
                    ),
                  ),
                if (nav.destination != null)
                  Marker(
                    point: LatLng(nav.destination!.lat, nav.destination!.lon),
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.location_on,
                      color: MapsColors.endRed,
                      size: 36,
                    ),
                  ),
                if (location.latitude != null && location.longitude != null)
                  Marker(
                    point: LatLng(location.latitude!, location.longitude!),
                    width: 40,
                    height: 40,
                    child: LocationPuck(heading: location.heading),
                  ),
              ]),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap © CARTO'),
                ],
              ),
            ],
          ),
          Positioned(
            top: topPad + 8,
            left: 12,
            right: 12,
            child: Column(
              children: [
                if (guiding)
                  AppleGuidanceCard(nav: nav, live: live)
                else
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoundMapButton(
                          icon: Icons.auto_awesome,
                          tooltip: 'Assistente AI',
                          onTap: _openAi,
                        ),
                        const SizedBox(width: 8),
                        _RoundMapButton(
                          icon: Icons.settings_outlined,
                          tooltip: 'Impostazioni',
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                AlertBanner(
                  proximity: location.nearestZone,
                  onAskAi: location.nearestZone == null ||
                          location.nearestZone!.status == ZoneStatus.safe
                      ? null
                      : () {
                          ref.read(aiAssistProvider.notifier).askAboutProximity();
                          _openAi();
                        },
                ),
                if (nav.alerts.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  RouteChangeBanners(
                    alerts: nav.alerts,
                    onDismiss: (id) =>
                        ref.read(navigationProvider.notifier).dismissAlert(id),
                    onAskAi: (alert) {
                      ref.read(aiAssistProvider.notifier).askAboutAlert(alert);
                      _openAi();
                    },
                  ),
                ],
                if (ai.hint != null) ...[
                  const SizedBox(height: 6),
                  AiHintBanner(
                    hint: ai.hint!,
                    onDismiss: () =>
                        ref.read(aiAssistProvider.notifier).dismissHint(),
                    onOpen: _openAi,
                  ),
                ],
                if (showCameraBanner) ...[
                  const SizedBox(height: 6),
                  CameraIncidentBanner(
                    meters: live?.nextCameraMeters,
                    maxspeed: nextCamera.maxspeed,
                  ),
                ],
                if (guiding && nav.zonesOnRoute.isNotEmpty && _trayExpanded) ...[
                  const SizedBox(height: 6),
                  RouteZoneBanner(zones: nav.zonesOnRoute),
                ],
              ],
            ),
          ),
          if (!guiding)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _recenterButton(location),
                    ),
                  ),
                  ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.62,
                ),
                child: SingleChildScrollView(
                  child: SearchSheet(
                originCtrl: _originCtrl,
                destCtrl: _destCtrl,
                originFocus: _originFocus,
                destFocus: _destFocus,
                nav: nav,
                expanded: _sheetExpanded,
                highlighted: widget.openNavigation,
                onToggleExpanded: _toggleSheet,
                onOriginQuery: (q) {
                  if (q.trim().toLowerCase() == 'la mia posizione') return;
                  final lang = ref.read(localeProvider).languageCode;
                  ref.read(navigationProvider.notifier).search(
                        q,
                        lang: lang,
                        field: SearchField.origin,
                      );
                },
                onDestQuery: (q) {
                  final lang = ref.read(localeProvider).languageCode;
                  ref.read(navigationProvider.notifier).search(
                        q,
                        lang: lang,
                        field: SearchField.destination,
                      );
                },
                onSelectSuggestion: (hit) async {
                  final field = nav.activeField;
                  if (field == SearchField.origin) {
                    _originCtrl.text = hit.label;
                  } else {
                    _destCtrl.text = hit.label;
                  }
                  await ref.read(navigationProvider.notifier).selectPlace(hit);
                  if (!context.mounted) return;
                  FocusScope.of(context).unfocus();
                },
                onUseMyLocation: () {
                  _originCtrl.text = 'La mia posizione';
                  ref.read(navigationProvider.notifier).useMyLocationAsOrigin();
                  if (nav.destination != null) {
                    ref.read(navigationProvider.notifier).planRoute(
                          startFollowing: false,
                        );
                  }
                },
                onSwap: () {
                  final a = _originCtrl.text;
                  _originCtrl.text = _destCtrl.text;
                  _destCtrl.text = a;
                  ref.read(navigationProvider.notifier).swapEnds();
                },
                onPlan: () {
                  ref.read(navigationProvider.notifier).planRoute(
                        startFollowing: false,
                      );
                },
                onGo: () {
                  if (!nav.hasRoute) {
                    ref.read(navigationProvider.notifier).planRoute(
                          startFollowing: true,
                        );
                  } else {
                    ref.read(navigationProvider.notifier).beginGuidance();
                  }
                },
                onSelectAlternative: (i) {
                  ref.read(navigationProvider.notifier).selectAlternative(i);
                },
                onSavedPlaceTap: _onSavedPlaceTap,
                onAddSuggested: (label) =>
                    _openFavoritesHub(tab: 0, prefillLabel: label),
                onManagePlaces: () => _openFavoritesHub(tab: 0),
                onOpenItineraries: () => _openFavoritesHub(tab: 1),
                onSelectPoi: (hit) async {
                  _destCtrl.text = hit.label;
                  await ref.read(navigationProvider.notifier).goToPoi(hit);
                  if (!context.mounted) return;
                  FocusScope.of(context).unfocus();
                },
                onSelectCategory: _onSelectCategory,
                onApplyItinerary: _applyItinerary,
              ),
                ),
              ),
                ],
              ),
            ),
          if (guiding)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _recenterButton(location),
                    ),
                  ),
                  AppleEtaTray(
                location: location,
                nav: nav,
                live: live,
                expanded: _trayExpanded,
                onToggleExpanded: _toggleTray,
                onStop: () {
                  ref.read(navigationProvider.notifier).stopNavigation();
                  _originCtrl.text = 'La mia posizione';
                  _destCtrl.clear();
                },
                onOverview: _showOverview,
                onRecenter: _recenter,
                onSelectAlternative: (i) {
                  ref.read(navigationProvider.notifier).selectAlternative(i);
                },
                onOpenAi: _openAi,
              ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onSelectCategory(PoiCategory category) async {
    setState(() => _sheetExpanded = true);
    FocusManager.instance.primaryFocus?.unfocus();
    final loc = ref.read(locationProvider);
    var lat = loc.latitude;
    var lon = loc.longitude;
    if (lat == null || lon == null) {
      try {
        final cam = _mapController.camera.center;
        lat = cam.latitude;
        lon = cam.longitude;
      } catch (_) {}
    }
    await ref.read(navigationProvider.notifier).searchNearby(
          category.id,
          lat: lat,
          lon: lon,
        );
  }

  List<Polygon> _polygonsFor(
    List<EmissionZone> zones,
    List<EmissionZone> onRoute,
  ) {
    final onRouteIds = {for (final z in onRoute) z.id};
    final polygons = <Polygon>[];
    for (final zone in zones) {
      final highlighted = onRouteIds.contains(zone.id);
      for (final ring in zone.polygonCoordinates) {
        if (ring.length < 3) continue;
        final points = <LatLng>[];
        for (final pt in ring) {
          if (pt.length < 2) continue;
          points.add(LatLng(pt[1], pt[0]));
        }
        if (points.length < 3) continue;
        polygons.add(
          Polygon(
            points: points,
            color: highlighted ? MapsColors.lezOnRouteFill : MapsColors.lezFill,
            borderColor: highlighted
                ? MapsColors.lezOnRouteBorder
                : MapsColors.lezBorder,
            borderStrokeWidth: highlighted ? 2.5 : 1.6,
          ),
        );
      }
    }
    return polygons;
  }

  PlaceHit? _originHitForSave(NavigationState nav) {
    if (nav.origin != null) return nav.origin;
    final loc = ref.read(locationProvider);
    if (nav.originIsMyLocation &&
        loc.latitude != null &&
        loc.longitude != null) {
      return PlaceHit(
        label: 'La mia posizione',
        lat: loc.latitude!,
        lon: loc.longitude!,
      );
    }
    return null;
  }

  void _openFavoritesHub({int tab = 0, String? prefillLabel}) {
    final nav = ref.read(navigationProvider);
    showFavoritesHub(
      context: context,
      initialTab: tab,
      currentOrigin: _originHitForSave(nav),
      currentDestination: nav.destination,
      prefillLabel: prefillLabel,
      onApplyPlace: _onSavedPlaceTap,
      onApplyItinerary: _applyItinerary,
    );
  }

  void _openAi() {
    showAiAssistSheet(context);
  }

  Future<void> _onSavedPlaceTap(SavedPlace place) async {
    SearchField field;
    if (_originFocus.hasFocus) {
      field = SearchField.origin;
    } else {
      field = SearchField.destination;
    }
    await _applySavedPlace(place, field);
  }

  Future<void> _applySavedPlace(SavedPlace place, SearchField field) async {
    final display =
        place.address.trim().isEmpty ? place.label : place.address;
    if (field == SearchField.origin) {
      _originCtrl.text = display;
    } else {
      _destCtrl.text = display;
    }
    final notifier = ref.read(navigationProvider.notifier);
    notifier.setEndpoint(
      PlaceHit(label: display, lat: place.lat, lon: place.lon),
      field,
    );
    final next = ref.read(navigationProvider);
    final hasOrigin = next.origin != null || next.originIsMyLocation;
    if (hasOrigin && next.destination != null) {
      await notifier.planRoute(startFollowing: false);
    }
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  Future<void> _applyItinerary(FavoriteItinerary trip) async {
    _originCtrl.text = trip.originLabel;
    _destCtrl.text = trip.destLabel;
    final notifier = ref.read(navigationProvider.notifier);
    if (trip.originIsMyLocation) {
      notifier.useMyLocationAsOrigin();
    } else {
      notifier.setEndpoint(
        PlaceHit(
          label: trip.originLabel,
          lat: trip.originLat,
          lon: trip.originLon,
        ),
        SearchField.origin,
      );
    }
    notifier.setEndpoint(
      PlaceHit(
        label: trip.destLabel,
        lat: trip.destLat,
        lon: trip.destLon,
      ),
      SearchField.destination,
    );
    await notifier.planRoute(startFollowing: false);
    await ref.read(favoritesProvider.notifier).touchItinerary(trip.id);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return MapsGlass(
      radius: 22,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(
          icon,
          color: emphasized ? MapsColors.route : MapsColors.accent,
          size: 20,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
