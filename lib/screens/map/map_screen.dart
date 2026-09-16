import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../l10n/app_localizations.dart';
import '../../models/emission_zone.dart';
import '../../models/navigation_models.dart';
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
import 'widgets/favorites_panel.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.openNavigation = false});

  /// When true (`/map?nav=1`), focus the A→B destination field.
  final bool openNavigation;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _originCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();
  final FocusNode _originFocus = FocusNode();
  final FocusNode _destFocus = FocusNode();
  bool _movedToUser = false;
  bool _topExpanded = true;
  bool _bottomExpanded = false;
  bool _wasGuiding = false;
  String? _seenTopAlertKey;
  String? _seenCameraAlertId;

  static const _overlayAnim = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _originCtrl.text = 'La mia posizione';
    _originFocus.addListener(() {
      if (_originFocus.hasFocus) {
        ref.read(navigationProvider.notifier).setActiveField(SearchField.origin);
        _expandTopForInput();
      }
    });
    _destFocus.addListener(() {
      if (_destFocus.hasFocus) {
        ref.read(navigationProvider.notifier).setActiveField(SearchField.destination);
        _expandTopForInput();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).startTracking();
      if (widget.openNavigation) _enterNavMode();
    });
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
    setState(() => _topExpanded = true);
    _destFocus.requestFocus();
  }

  void _expandTopForInput() {
    if (_topExpanded) return;
    setState(() => _topExpanded = true);
  }

  bool _isGuiding(NavigationState nav, LocationState location) =>
      nav.navigating || (nav.hasRoute && location.follow);

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

  void _toggleTopPanel() {
    setState(() {
      _topExpanded = !_topExpanded;
      if (!_topExpanded) FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  void _toggleBottomHud([bool? expanded]) {
    setState(() {
      _bottomExpanded = expanded ?? !_bottomExpanded;
    });
  }

  @override
  void dispose() {
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
            _topExpanded ? 210 : 78,
            36,
            _bottomExpanded ? 240 : 118,
          ),
          maxZoom: 15,
        ),
      );
    } catch (_) {}
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
      final followLive = next.follow && nav.navigating && nav.originIsMyLocation;
      if (next.latitude == null || next.longitude == null) return;
      if (!_movedToUser || followLive) {
        _movedToUser = true;
        _mapController.move(
          LatLng(next.latitude!, next.longitude!),
          nav.navigating ? 16 : 14,
        );
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

    final guiding = _isGuiding(nav, location);
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
        (nav.suggestions.isNotEmpty && !_topExpanded);
    if (needsChromeSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (guiding != _wasGuiding) {
            _wasGuiding = guiding;
            if (guiding) {
              _topExpanded = topAlertKey.isNotEmpty;
              _bottomExpanded = false;
              FocusManager.instance.primaryFocus?.unfocus();
            } else {
              _topExpanded = true;
              _bottomExpanded = false;
              _seenCameraAlertId = null;
            }
          }
          if (topAlertKey != (_seenTopAlertKey ?? '')) {
            _seenTopAlertKey = topAlertKey.isEmpty ? null : topAlertKey;
            if (guiding && topAlertKey.isNotEmpty) {
              _topExpanded = true;
            }
          }
          if (cameraId != _seenCameraAlertId) {
            _seenCameraAlertId = cameraId;
            if (guiding && cameraId != null) {
              _bottomExpanded = true;
            }
          }
          if (nav.suggestions.isNotEmpty) {
            _topExpanded = true;
          }
        });
      });
    }

    final originPoint = !nav.originIsMyLocation && nav.origin != null
        ? LatLng(nav.origin!.lat, nav.origin!.lon)
        : null;

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
                          color: Colors.white.withValues(alpha: 0.35),
                          strokeWidth: 4,
                        ),
                  ],
                ),
              if (nav.route.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: nav.route,
                      color: NeonColors.cyan,
                      strokeWidth: 5.5,
                    ),
                  ],
                ),
              MarkerLayer(markers: [
                ...nav.cameras.map(
                  (c) => Marker(
                    point: LatLng(c.lat, c.lon),
                    width: 34,
                    height: 34,
                    child: const _CameraPin(),
                  ),
                ),
                if (originPoint != null)
                  Marker(
                    point: originPoint,
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.trip_origin,
                      color: NeonColors.neonGreen,
                      size: 30,
                    ),
                  ),
                if (nav.destination != null)
                  Marker(
                    point: LatLng(nav.destination!.lat, nav.destination!.lon),
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.location_on,
                      color: NeonColors.pink,
                      size: 36,
                    ),
                  ),
                if (location.latitude != null && location.longitude != null)
                  Marker(
                    point: LatLng(location.latitude!, location.longitude!),
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NeonColors.cyan,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: NeonColors.cyan.withValues(alpha: 0.6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
              ]),
              RichAttributionWidget(
                attributions: const [
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
                _DirectionsPanel(
                  originCtrl: _originCtrl,
                  destCtrl: _destCtrl,
                  originFocus: _originFocus,
                  destFocus: _destFocus,
                  nav: nav,
                  expanded: _topExpanded,
                  highlighted: widget.openNavigation && !guiding,
                  onToggleExpanded: _toggleTopPanel,
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
                  onSelect: (hit) async {
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
                            startFollowing: true,
                          );
                    }
                  },
                  onSwap: () {
                    final a = _originCtrl.text;
                    _originCtrl.text = _destCtrl.text;
                    _destCtrl.text = a;
                    ref.read(navigationProvider.notifier).swapEnds();
                  },
                  onGo: () {
                    ref.read(navigationProvider.notifier).planRoute(
                          startFollowing: nav.originIsMyLocation,
                        );
                  },
                  onSelectAlternative: (i) {
                    ref.read(navigationProvider.notifier).selectAlternative(i);
                  },
                  onSettings: () => context.push('/settings'),
                  onSavedPlaceTap: _onSavedPlaceTap,
                  onAddSuggested: (label) =>
                      _openFavoritesHub(tab: 0, prefillLabel: label),
                  onManagePlaces: () => _openFavoritesHub(tab: 0),
                  onOpenItineraries: () => _openFavoritesHub(tab: 1),
                  onOpenAi: _openAi,
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
                  _RouteChangeBanners(
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
                if (_topExpanded && nav.zonesOnRoute.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _RouteZoneBanner(zones: nav.zonesOnRoute),
                ],
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _NavigatorHud(
              location: location,
              nav: nav,
              live: live,
              expanded: _bottomExpanded,
              guiding: guiding,
              onToggleExpanded: (value) => _toggleBottomHud(value),
              onToggleTrack: () {
                ref.read(locationProvider.notifier).toggleFollow();
              },
              onOpenAi: _openAi,
              onStop: () {
                ref.read(navigationProvider.notifier).stopNavigation();
                _originCtrl.text = 'La mia posizione';
                _destCtrl.clear();
              },
            ),
          ),
        ],
      ),
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
            color: highlighted
                ? NeonColors.orange.withValues(alpha: 0.28)
                : NeonColors.neonGreen.withValues(alpha: 0.16),
            borderColor:
                highlighted ? NeonColors.orange : NeonColors.neonGreen,
            borderStrokeWidth: highlighted ? 3 : 2,
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
    SearchField? field;
    if (_originFocus.hasFocus) {
      field = SearchField.origin;
    } else if (_destFocus.hasFocus) {
      field = SearchField.destination;
    } else {
      field = await pickAddressField(context);
    }
    if (field == null || !mounted) return;
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
      await notifier.planRoute(startFollowing: next.originIsMyLocation);
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
    await notifier.planRoute(startFollowing: trip.originIsMyLocation);
    await ref.read(favoritesProvider.notifier).touchItinerary(trip.id);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }
}

class _CameraPin extends StatelessWidget {
  const _CameraPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NeonColors.orange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.videocam, color: Colors.white, size: 16),
    );
  }
}

class _DirectionsPanel extends StatelessWidget {
  const _DirectionsPanel({
    required this.originCtrl,
    required this.destCtrl,
    required this.originFocus,
    required this.destFocus,
    required this.nav,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onOriginQuery,
    required this.onDestQuery,
    required this.onSelect,
    required this.onUseMyLocation,
    required this.onSwap,
    required this.onGo,
    required this.onSelectAlternative,
    required this.onSettings,
    required this.onSavedPlaceTap,
    required this.onAddSuggested,
    required this.onManagePlaces,
    required this.onOpenItineraries,
    this.onOpenAi,
    this.highlighted = false,
  });

  final TextEditingController originCtrl;
  final TextEditingController destCtrl;
  final FocusNode originFocus;
  final FocusNode destFocus;
  final NavigationState nav;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<String> onOriginQuery;
  final ValueChanged<String> onDestQuery;
  final ValueChanged<PlaceHit> onSelect;
  final VoidCallback onUseMyLocation;
  final VoidCallback onSwap;
  final VoidCallback onGo;
  final ValueChanged<int> onSelectAlternative;
  final VoidCallback onSettings;
  final ValueChanged<SavedPlace> onSavedPlaceTap;
  final ValueChanged<String> onAddSuggested;
  final VoidCallback onManagePlaces;
  final VoidCallback onOpenItineraries;
  final VoidCallback? onOpenAi;
  final bool highlighted;

  String get _originLabel {
    final text = originCtrl.text.trim();
    return text.isEmpty ? 'Partenza' : text;
  }

  String get _destLabel {
    final text = destCtrl.text.trim();
    return text.isEmpty ? 'Destinazione' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: _MapScreenState._overlayAnim,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: highlighted
                ? Border.all(color: NeonColors.magenta, width: 1.8)
                : Border.all(
                    color: NeonColors.cyan.withValues(alpha: 0.28),
                    width: 1,
                  ),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: NeonColors.magenta.withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: NeonColors.cyan.withValues(alpha: 0.12),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: Material(
            color: NeonColors.darkCard.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: AnimatedSize(
              duration: _MapScreenState._overlayAnim,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded ? _buildExpanded(context) : _buildCollapsed(context),
            ),
          ),
        ),
        if (expanded && nav.suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: NeonColors.darkCard.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(14),
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final hit in nav.suggestions)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      nav.activeField == SearchField.origin
                          ? Icons.trip_origin
                          : Icons.place,
                      color: nav.activeField == SearchField.origin
                          ? NeonColors.neonGreen
                          : NeonColors.cyan,
                    ),
                    title: Text(
                      hit.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    onTap: () => onSelect(hit),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    return InkWell(
      onTap: onToggleExpanded,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
        child: Row(
          children: [
            const Icon(Icons.trip_origin, color: NeonColors.neonGreen, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$_originLabel  →  $_destLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.exo2(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (onOpenAi != null)
              IconButton(
                tooltip: 'Assistente AI',
                onPressed: onOpenAi,
                icon: const Icon(Icons.auto_awesome, color: NeonColors.cyan, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            IconButton(
              tooltip: 'Apri pannello percorso',
              onPressed: onToggleExpanded,
              icon: const Icon(Icons.expand_more, color: NeonColors.cyan),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggleExpanded,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 4),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: NeonColors.cyan.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.expand_less,
                        color: NeonColors.cyan.withValues(alpha: 0.85),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Riduci pannello',
                        style: GoogleFonts.exo2(
                          color: NeonColors.cyan.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (highlighted)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.navigation,
                    color: NeonColors.magenta,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)?.navNavigation ??
                        'Navigazione',
                    style: GoogleFonts.exo2(
                      color: NeonColors.magenta,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _AddressField(
                  fieldId: 'origin',
                  controller: originCtrl,
                  focusNode: originFocus,
                  hint: 'Da: indirizzo di partenza',
                  icon: Icons.trip_origin,
                  iconColor: NeonColors.neonGreen,
                  onChanged: onOriginQuery,
                ),
              ),
              IconButton(
                tooltip: 'Usa la mia posizione',
                onPressed: onUseMyLocation,
                icon: Icon(
                  Icons.my_location,
                  color: nav.originIsMyLocation
                      ? NeonColors.cyan
                      : Colors.white54,
                ),
              ),
              _IconChip(icon: Icons.settings, onTap: onSettings),
              if (onOpenAi != null)
                _IconChip(icon: Icons.auto_awesome, onTap: onOpenAi!),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _AddressField(
                  fieldId: 'destination',
                  controller: destCtrl,
                  focusNode: destFocus,
                  hint: 'A: dove vuoi andare',
                  icon: Icons.flag,
                  iconColor: NeonColors.pink,
                  onChanged: onDestQuery,
                ),
              ),
              IconButton(
                tooltip: 'Inverti A e B',
                onPressed: onSwap,
                icon: const Icon(Icons.swap_vert, color: Colors.white70),
              ),
              IconButton(
                tooltip: 'Calcola percorso',
                onPressed: nav.routing ? null : onGo,
                icon: Icon(
                  nav.routing ? Icons.hourglass_top : Icons.directions,
                  color: NeonColors.cyan,
                ),
              ),
            ],
          ),
          SavedPlacesQuickBar(
            onPlaceTap: onSavedPlaceTap,
            onAddSuggested: onAddSuggested,
            onManagePlaces: onManagePlaces,
            onOpenItineraries: onOpenItineraries,
          ),
          if (nav.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  nav.error!,
                  style: const TextStyle(
                    color: NeonColors.pink,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if (nav.hasRoute)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.route,
                    label:
                        '${formatDistance(nav.routeDistanceMeters)} · ${formatDuration(nav.routeDurationSeconds)}',
                  ),
                  _InfoChip(
                    icon: Icons.shield,
                    label: nav.zonesOnRoute.isEmpty
                        ? 'Nessuna zona'
                        : '${nav.zonesOnRoute.length} zone',
                    color: nav.zonesOnRoute.isEmpty
                        ? NeonColors.neonGreen
                        : NeonColors.orange,
                  ),
                  _InfoChip(
                    icon: Icons.videocam,
                    label: nav.cameras.isEmpty
                        ? 'Nessun autovelox'
                        : '${nav.cameras.length} autovelox',
                    color: nav.cameras.isEmpty
                        ? NeonColors.neonGreen
                        : NeonColors.orange,
                  ),
                ],
              ),
            ),
          if (nav.alternatives.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: nav.alternatives.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final plan = nav.alternatives[i];
                    final selected = i == nav.selectedRoute;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(
                        'Percorso ${i + 1} · ${formatDuration(plan.durationSeconds)}',
                        style: TextStyle(
                          color: selected
                              ? NeonColors.deepSpace
                              : Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      selectedColor: NeonColors.cyan,
                      backgroundColor: NeonColors.darkSurface,
                      onSelected: (_) => onSelectAlternative(i),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.fieldId,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.onChanged,
  });

  final String fieldId;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: ValueKey('address-$fieldId'),
      controller: controller,
      focusNode: focusNode,
      obscureText: false,
      autocorrect: !kIsWeb,
      enableSuggestions: true,
      enableInteractiveSelection: true,
      maxLines: 1,
      keyboardType:
          kIsWeb ? TextInputType.multiline : TextInputType.streetAddress,
      textCapitalization: TextCapitalization.words,
      autofillHints: const [
        AutofillHints.streetAddressLine1,
        AutofillHints.addressCity,
        AutofillHints.location,
      ],
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      cursorColor: NeonColors.cyan,
      cursorWidth: 2,
      style: const TextStyle(
        color: Color(0xFFF4FBFF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.3,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0x99D6EEF7),
          fontSize: 15,
          letterSpacing: 0,
        ),
        prefixIcon: Icon(icon, color: iconColor, size: 22),
        filled: true,
        fillColor: const Color(0xFF0B0B1C),
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeonColors.cyan, width: 1.5),
        ),
      ),
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = NeonColors.cyan,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NeonColors.darkSurface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: NeonColors.cyan, size: 20),
        ),
      ),
    );
  }
}

class _RouteChangeBanners extends StatelessWidget {
  const _RouteChangeBanners({
    required this.alerts,
    required this.onDismiss,
    this.onAskAi,
  });

  final List<RouteChangeAlert> alerts;
  final ValueChanged<String> onDismiss;
  final ValueChanged<RouteChangeAlert>? onAskAi;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final alert in alerts.take(3)) ...[
          Material(
            color: (alert.critical ? NeonColors.pink : NeonColors.orange)
                .withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              child: Row(
                children: [
                  Icon(
                    _iconFor(alert.kind),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          alert.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chiedi all\'AI',
                    onPressed: onAskAi == null ? null : () => onAskAi!(alert),
                    icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: 'Chiudi avviso',
                    onPressed: () => onDismiss(alert.id),
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  IconData _iconFor(RouteAlertKind kind) {
    switch (kind) {
      case RouteAlertKind.delay:
        return Icons.schedule;
      case RouteAlertKind.faster:
        return Icons.speed;
      case RouteAlertKind.detour:
        return Icons.alt_route;
      case RouteAlertKind.newCamera:
        return Icons.videocam;
      case RouteAlertKind.newZone:
        return Icons.shield;
      case RouteAlertKind.zoneActivating:
        return Icons.warning_amber_rounded;
      case RouteAlertKind.zoneExpiring:
        return Icons.timer_off;
    }
  }
}

class _RouteZoneBanner extends StatelessWidget {
  const _RouteZoneBanner({required this.zones});
  final List<EmissionZone> zones;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NeonColors.orange.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'Percorso in ${zones.length} zona/e: ${zones.map((z) => z.name).take(3).join(' · ')}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _NavigatorHud extends StatelessWidget {
  const _NavigatorHud({
    required this.location,
    required this.nav,
    required this.live,
    required this.expanded,
    required this.guiding,
    required this.onToggleExpanded,
    required this.onToggleTrack,
    required this.onStop,
    this.onOpenAi,
  });

  final LocationState location;
  final NavigationState nav;
  final LiveNavInfo? live;
  final bool expanded;
  final bool guiding;
  final ValueChanged<bool?> onToggleExpanded;
  final VoidCallback onToggleTrack;
  final VoidCallback onStop;
  final VoidCallback? onOpenAi;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        final v = details.velocity.pixelsPerSecond.dy;
        if (v < -180) {
          onToggleExpanded(true);
        } else if (v > 180) {
          onToggleExpanded(false);
        }
      },
      child: Material(
        color: NeonColors.deepSpace.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedSize(
          duration: _MapScreenState._overlayAnim,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
          child: expanded ? _buildExpanded(context) : _buildCollapsed(context),
        ),
      ),
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    final speedKmh = ((location.speed ?? 0) * 3.6).round();
    final limit = live?.speedLimitKmh;
    final overLimit = limit != null && speedKmh > limit + 2;
    final instruction = _compactInstruction(live, nav);
    final remaining = live?.remainingMeters ?? nav.routeDistanceMeters;
    final showGuidance = nav.hasRoute || guiding;

    return InkWell(
      onTap: () => onToggleExpanded(true),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: NeonColors.cyan.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _turnIcon(live?.currentStep),
                  color: NeonColors.cyan,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    instruction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.exo2(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (live?.nextCamera != null) ...[
                  const Icon(Icons.videocam, color: NeonColors.orange, size: 16),
                  const SizedBox(width: 6),
                ],
                if (showGuidance) ...[
                  Text(
                    formatDistance(remaining),
                    style: GoogleFonts.exo2(
                      color: NeonColors.cyan,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (overLimit ? NeonColors.pink : NeonColors.neonGreen)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(
                    limit == null ? '$speedKmh' : '$speedKmh/$limit',
                    style: GoogleFonts.exo2(
                      color: overLimit ? NeonColors.pink : NeonColors.neonGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Apri guida',
                  onPressed: () => onToggleExpanded(true),
                  icon: const Icon(Icons.expand_less, color: NeonColors.cyan),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    final speedKmh = ((location.speed ?? 0) * 3.6).round();
    final zone = location.nearestZone;
    final limit = live?.speedLimitKmh;
    final overLimit = limit != null && speedKmh > limit + 2;
    final tracking = location.follow || nav.navigating;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onToggleExpanded(false),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: NeonColors.cyan.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.expand_more,
                        color: NeonColors.cyan.withValues(alpha: 0.85),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Riduci guida',
                        style: GoogleFonts.exo2(
                          color: NeonColors.cyan.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (nav.hasRoute && nav.destination != null) ...[
            Row(
              children: [
                Icon(_turnIcon(live?.currentStep), color: NeonColors.cyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _compactInstruction(live, nav),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.exo2(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  formatDistance(live?.remainingMeters ?? nav.routeDistanceMeters),
                  style: GoogleFonts.exo2(
                    color: NeonColors.cyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              _HudTile(
                label: 'Velocità',
                value: '$speedKmh',
                unit: 'km/h',
                color: overLimit ? NeonColors.pink : NeonColors.cyan,
              ),
              _HudTile(
                label: 'Limite',
                value: limit?.toString() ?? '—',
                unit: 'km/h',
                color: overLimit ? NeonColors.pink : NeonColors.neonGreen,
              ),
              _HudTile(
                label: 'Zona',
                value: zone == null
                    ? 'Fuori'
                    : (zone.status == ZoneStatus.inside ? 'Dentro' : 'Vicino'),
                unit: zone == null ? '' : formatDistance(zone.distanceMeters),
                color: zone == null
                    ? NeonColors.neonGreen
                    : zone.status == ZoneStatus.inside
                        ? NeonColors.pink
                        : NeonColors.orange,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              zone == null
                  ? 'Nessuna milieuzone nelle vicinanze'
                  : '${formatZoneType(zone.zoneType)} · ${zone.zoneName}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
          ),
          if (live?.nextCamera != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.videocam, color: NeonColors.orange, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Autovelox tra ${formatDistance(live!.nextCameraMeters)}'
                    '${live!.nextCamera!.maxspeed != null ? ' · ${live!.nextCamera!.maxspeed} km/h' : ''}',
                    style: const TextStyle(
                      color: NeonColors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (nav.hasRoute) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                nav.lastMonitoredAt == null
                    ? 'Avvisi attivi: controllo del tragitto ogni 45 secondi'
                    : 'Tragitto controllato · avvisi se cambia zona, autovelox o tempi',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onToggleTrack,
                  icon: Icon(tracking ? Icons.gps_fixed : Icons.gps_not_fixed),
                  label: Text(tracking ? 'Traccia ON' : 'Traccia'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        tracking ? NeonColors.cyan : NeonColors.darkCard,
                    foregroundColor:
                        tracking ? NeonColors.deepSpace : Colors.white,
                  ),
                ),
              ),
              if (onOpenAi != null) ...[
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onOpenAi,
                  style: FilledButton.styleFrom(
                    backgroundColor: NeonColors.cyan,
                    foregroundColor: NeonColors.deepSpace,
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.auto_awesome),
                ),
              ],
              if (nav.hasRoute) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onStop,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NeonColors.pink,
                    side: const BorderSide(color: NeonColors.pink),
                  ),
                  child: const Text('Stop'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _compactInstruction(LiveNavInfo? live, NavigationState nav) {
  final step = live?.currentStep;
  if (step != null) {
    final text = step.instructionIt;
    if (step.type == 'arrive') return text;
    final dist = formatDistance(step.distanceMeters);
    if (dist == '—' || step.distanceMeters <= 0) return text;
    return '$text tra $dist';
  }
  if (nav.destination != null) {
    return 'Verso ${nav.destination!.label}';
  }
  if (nav.hasRoute) return 'Percorso pronto';
  return 'Nessun percorso';
}

IconData _turnIcon(NavStep? step) {
  if (step == null) return Icons.navigation;
  switch (step.type) {
    case 'arrive':
      return Icons.flag;
    case 'roundabout':
    case 'rotary':
      return Icons.roundabout_left;
    case 'on ramp':
      return Icons.merge_type;
    case 'off ramp':
    case 'exit':
      return Icons.logout;
    case 'merge':
      return Icons.merge;
    case 'fork':
    case 'turn':
      if (step.modifier.contains('uturn')) return Icons.u_turn_left;
      if (step.modifier.contains('left')) return Icons.turn_left;
      if (step.modifier.contains('right')) return Icons.turn_right;
      return Icons.arrow_upward;
    case 'depart':
    case 'continue':
    case 'new name':
    default:
      return Icons.arrow_upward;
  }
}

class _HudTile extends StatelessWidget {
  const _HudTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.exo2(
                color: color,
                fontSize: 9,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.exo2(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
