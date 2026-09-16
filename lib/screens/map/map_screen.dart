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
import '../../models/hazard_report.dart';
import '../../l10n/hazard_strings.dart';
import '../../providers/ai_assist_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/hazard_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/voice_guidance_provider.dart';
import '../../providers/zone_provider.dart';
import 'widgets/ai_assist_sheet.dart';
import 'widgets/ai_hint_banner.dart';
import 'widgets/alert_banner.dart';
import 'widgets/apple_eta_tray.dart';
import 'widgets/apple_guidance_card.dart';
import 'widgets/driver_map_frame.dart';
import 'widgets/favorites_panel.dart';
import 'widgets/hazard_detail_sheet.dart';
import 'widgets/incident_banners.dart';
import 'widgets/map_pins.dart';
import 'widgets/report_sheet.dart';
import 'widgets/search_sheet.dart';
import 'widgets/transient_alert.dart';

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
  bool _tilt3d = false;
  bool _userSetMapMode = false;

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
      final locN = ref.read(locationProvider.notifier);
      locN.startTracking();
      locN.setFollow(true);
      final loc = ref.read(locationProvider);
      ref.read(hazardProvider.notifier).start(
            lat: loc.latitude,
            lon: loc.longitude,
          );
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

  List<TransientAlert> _flashCandidates({
    required LocationState location,
    required NavigationState nav,
    required HazardState hazards,
    required AiAssistState ai,
    required LiveNavInfo? live,
    required bool guiding,
    required bool showCameraBanner,
    required HazardReport? crowdUpcoming,
    required HazardStrings crowdL10n,
  }) {
    final out = <TransientAlert>[];
    final zone = location.nearestZone;
    if (_zoneAlertActive(zone)) {
      final unauthorized = zone!.isVehicleAllowed == false;
      out.add(TransientAlert(
        id: 'zone:${zone.zoneId}:${zone.status}:${zone.isVehicleAllowed}',
        priority: unauthorized
            ? (zone.status == ZoneStatus.inside ? 85 : 80)
            : (zone.status == ZoneStatus.inside ? 60 : 70),
        child: AlertBanner(
          proximity: zone,
          onAskAi: () {
            ref.read(aiAssistProvider.notifier).askAboutProximity();
            _openAi();
          },
        ),
      ));
    }
    for (final alert in nav.alerts) {
      out.add(TransientAlert(
        id: 'alert:${alert.id}',
        priority: alert.critical ? 50 : 40,
        child: RouteChangeBanners(
          alerts: [alert],
          onDismiss: (id) =>
              ref.read(navigationProvider.notifier).dismissAlert(id),
          onAskAi: (a) {
            ref.read(aiAssistProvider.notifier).askAboutAlert(a);
            _openAi();
          },
        ),
      ));
    }
    if (ai.hint != null) {
      out.add(TransientAlert(
        id: 'hint:${ai.hint!.id}',
        priority: 20,
        child: AiHintBanner(
          hint: ai.hint!,
          onDismiss: () => ref.read(aiAssistProvider.notifier).dismissHint(),
          onOpen: _openAi,
        ),
      ));
    }
    final nextCamera = live?.nextCamera;
    if (showCameraBanner && nextCamera != null) {
      out.add(TransientAlert(
        id: 'cam:${nextCamera.id}',
        priority: 90,
        child: CameraIncidentBanner(
          meters: live?.nextCameraMeters,
          maxspeed: nextCamera.maxspeed,
          community: nextCamera.isCommunity,
        ),
      ));
    }
    if (crowdUpcoming != null &&
        (!showCameraBanner || !crowdUpcoming.type.isCamera)) {
      out.add(TransientAlert(
        id: 'crowd:${crowdUpcoming.id}',
        priority: 95,
        child: CrowdHazardBanner(
          title: crowdL10n.bannerTitle(
            crowdUpcoming.type,
            formatDistance(crowdUpcoming.distanceMeters),
          ),
          subtitle:
              '${crowdL10n.aDriver} · ${crowdL10n.timeAgo(crowdUpcoming.createdAt)}',
          icon: hazardIcon(crowdUpcoming.type),
          color: hazardColor(crowdUpcoming.type),
          onTap: () => showHazardDetailSheet(context, crowdUpcoming),
        ),
      ));
    }
    for (final incoming in hazards.incoming) {
      if (incoming.id == crowdUpcoming?.id) continue;
      out.add(TransientAlert(
        id: 'in:${incoming.id}',
        priority: 100,
        child: CrowdHazardBanner(
          title: crowdL10n.bannerTitle(
            incoming.type,
            formatDistance(incoming.distanceMeters),
          ),
          subtitle:
              '${crowdL10n.aDriver} · ${crowdL10n.timeAgo(incoming.createdAt)}',
          icon: hazardIcon(incoming.type),
          color: hazardColor(incoming.type),
          onTap: () => showHazardDetailSheet(context, incoming),
          onDismiss: () =>
              ref.read(hazardProvider.notifier).dismissIncoming(incoming.id),
        ),
      ));
    }
    if (guiding && nav.zonesOnRoute.isNotEmpty) {
      out.add(TransientAlert(
        id: 'routezones:${nav.zonesOnRoute.map((z) => z.id).join(',')}',
        priority: 25,
        child: RouteZoneBanner(zones: nav.zonesOnRoute),
      ));
    }
    return out;
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
    ref.read(hazardProvider.notifier).stop();
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
      final loc = ref.read(locationProvider);
      final heading = loc.heading;
      if (_tilt3d && heading != null && heading >= 0) {
        _mapController.moveAndRotate(LatLng(lat, lon), z, heading);
        _mapController.move(
          LatLng(lat, lon),
          z,
          offset: const Offset(0, 120),
        );
      } else {
        if (!_tilt3d && _mapController.camera.rotation.abs() > 0.4) {
          _mapController.rotate(0);
        }
        _mapController.move(LatLng(lat, lon), z);
      }
    } catch (_) {}
  }

  void _toggle3d() {
    setState(() {
      _userSetMapMode = true;
      _tilt3d = !_tilt3d;
    });
    if (!_tilt3d) {
      try {
        _mapController.rotate(0);
      } catch (_) {}
    } else {
      final loc = ref.read(locationProvider);
      if (loc.latitude != null && loc.longitude != null) {
        _moveToUser(loc.latitude!, loc.longitude!);
      }
    }
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

  Widget _sideMapButtons(LocationState location) {
    final l10n = HazardStrings.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundMapButton(
          icon: _tilt3d ? Icons.threed_rotation : Icons.map_outlined,
          tooltip: _tilt3d ? l10n.toggle3d : l10n.toggle2d,
          emphasized: _tilt3d,
          label: _tilt3d ? '3D' : '2D',
          onTap: _toggle3d,
        ),
        const SizedBox(height: 8),
        _RoundMapButton(
          icon: Icons.campaign_outlined,
          tooltip: l10n.nearbyFeed,
          onTap: () => showHazardFeedSheet(context),
        ),
        const SizedBox(height: 8),
        _recenterButton(location),
        const SizedBox(height: 10),
        Material(
          color: const Color(0xFFFF9F0A),
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => showHazardReportSheet(context, ref),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  List<Marker> _cameraAndHazardMarkers(
    NavigationState nav,
    HazardState hazards,
  ) {
    final markers = <Marker>[];
    final osmIds = <String>{};
    for (final c in [...nav.cameras, ...hazards.cameras]) {
      if (c.isCommunity) continue;
      if (!osmIds.add(c.id)) continue;
      markers.add(
        Marker(
          point: LatLng(c.lat, c.lon),
          width: 34,
          height: 34,
          child: const CameraPin(),
        ),
      );
    }
    for (final r in hazards.reports) {
      markers.add(
        Marker(
          point: LatLng(r.lat, r.lon),
          width: 38,
          height: 38,
          child: GestureDetector(
            onTap: () => showHazardDetailSheet(context, r),
            child: r.type.isCamera
                ? const CameraPin(community: true)
                : HazardPin(
                    icon: hazardIcon(r.type),
                    color: hazardColor(r.type),
                  ),
          ),
        ),
      );
    }
    return markers;
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
    final hazards = ref.watch(hazardProvider);
    final ai = ref.watch(aiAssistProvider);
    ref.watch(voiceGuidanceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;

    ref.listen(locationProvider, (prev, next) {
      if (next.latitude == null || next.longitude == null) return;
      ref.read(hazardProvider.notifier).updateAnchor(
            next.latitude!,
            next.longitude!,
          );
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
    final nextCamera = live?.nextCamera;
    final needsChromeSync = guiding != _wasGuiding ||
        (nav.suggestions.isNotEmpty && !_sheetExpanded);
    if (needsChromeSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (guiding != _wasGuiding) {
            _wasGuiding = guiding;
            if (guiding) {
              _sheetExpanded = false;
              _trayExpanded = false;
              FocusManager.instance.primaryFocus?.unfocus();
              if (!_userSetMapMode) _tilt3d = true;
            } else {
              // Full map when driving without a destination.
              _sheetExpanded = nav.destination != null;
              _trayExpanded = false;
              if (!_userSetMapMode) _tilt3d = false;
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

    final showCameraBanner = nextCamera != null &&
        (live?.nextCameraMeters ?? 9999) <= 1000 &&
        (!nextCamera.isCommunity ||
            hazards.reports.any((r) =>
                !r.hiddenByVotes &&
                (r.id == nextCamera.reportId ||
                    'c-${r.id}' == nextCamera.id)));
    final crowdL10n = HazardStrings.of(context);
    final crowdUpcoming = (location.latitude != null && location.longitude != null)
        ? ref.read(hazardProvider.notifier).upcoming(
              lat: location.latitude!,
              lon: location.longitude!,
              heading: location.heading,
            )
        : null;

    return Scaffold(
      bottomNavigationBar: const MainBottomNav(),
      body: Stack(
        children: [
          DriverMapFrame(
            tilted: _tilt3d,
            child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: location.latitude != null
                  ? 13
                  : AppConstants.initialZoom,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
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
                userAgentPackageName: 'com.milieualert.app',
                maxNativeZoom: 19,
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
                ..._cameraAndHazardMarkers(nav, hazards),
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
                    child: LocationPuck(
                      heading: _tilt3d ? 0 : location.heading,
                    ),
                  ),
              ]),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
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
                    child: _RoundMapButton(
                      icon: Icons.settings_outlined,
                      tooltip: 'Impostazioni',
                      onTap: () => context.push('/settings'),
                    ),
                  ),
                const SizedBox(height: 8),
                TransientAlertSlot(
                  candidates: _flashCandidates(
                    location: location,
                    nav: nav,
                    hazards: hazards,
                    ai: ai,
                    live: live,
                    guiding: guiding,
                    showCameraBanner: showCameraBanner,
                    crowdUpcoming: crowdUpcoming,
                    crowdL10n: crowdL10n,
                  ),
                ),
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
                      child: _sideMapButtons(location),
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
                  setState(() => _sheetExpanded = true);
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
                onGo: () async {
                  var n = ref.read(navigationProvider);
                  if (n.destination == null && n.suggestions.isNotEmpty) {
                    _destCtrl.text = n.suggestions.first.label;
                    await ref
                        .read(navigationProvider.notifier)
                        .selectPlace(n.suggestions.first);
                    n = ref.read(navigationProvider);
                  }
                  if (!n.hasRoute) {
                    await ref.read(navigationProvider.notifier).planRoute(
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
                      child: _sideMapButtons(location),
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
    this.label,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool emphasized;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return MapsGlass(
      radius: 22,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: label == null
            ? Icon(
                icon,
                color: emphasized ? MapsColors.route : MapsColors.accent,
                size: 20,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: emphasized ? MapsColors.route : MapsColors.accent,
                    size: 16,
                  ),
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: emphasized ? MapsColors.route : MapsColors.accent,
                    ),
                  ),
                ],
              ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
