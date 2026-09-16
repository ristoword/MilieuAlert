import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/emission_zone.dart';
import '../../models/navigation_models.dart';
import '../../models/zone_status.dart';
import '../../providers/location_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/zone_provider.dart';
import 'widgets/alert_banner.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _originCtrl.text = 'La mia posizione';
    _originFocus.addListener(() {
      if (_originFocus.hasFocus) {
        ref.read(navigationProvider.notifier).setActiveField(SearchField.origin);
      }
    });
    _destFocus.addListener(() {
      if (_destFocus.hasFocus) {
        ref.read(navigationProvider.notifier).setActiveField(SearchField.destination);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).startTracking();
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
          padding: const EdgeInsets.fromLTRB(36, 210, 36, 240),
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
      if (!next.hasRoute) return;
      final routeChanged = prev?.selectedRoute != next.selectedRoute ||
          prev?.routeDistanceMeters != next.routeDistanceMeters ||
          prev?.destination?.label != next.destination?.label;
      if (routeChanged && !(next.navigating && prev?.hasRoute == true)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fitRoute(next.route);
        });
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

    final originPoint = !nav.originIsMyLocation && nav.origin != null
        ? LatLng(nav.origin!.lat, nav.origin!.lon)
        : null;

    return Scaffold(
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
                ),
                const SizedBox(height: 8),
                AlertBanner(proximity: location.nearestZone),
                if (nav.zonesOnRoute.isNotEmpty) ...[
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
              onToggleTrack: () {
                ref.read(locationProvider.notifier).toggleFollow();
              },
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
    required this.onOriginQuery,
    required this.onDestQuery,
    required this.onSelect,
    required this.onUseMyLocation,
    required this.onSwap,
    required this.onGo,
    required this.onSelectAlternative,
    required this.onSettings,
  });

  final TextEditingController originCtrl;
  final TextEditingController destCtrl;
  final FocusNode originFocus;
  final FocusNode destFocus;
  final NavigationState nav;
  final ValueChanged<String> onOriginQuery;
  final ValueChanged<String> onDestQuery;
  final ValueChanged<PlaceHit> onSelect;
  final VoidCallback onUseMyLocation;
  final VoidCallback onSwap;
  final VoidCallback onGo;
  final ValueChanged<int> onSelectAlternative;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: NeonColors.darkCard.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Column(
              children: [
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
          ),
        ),
        if (nav.suggestions.isNotEmpty)
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
    required this.onToggleTrack,
    required this.onStop,
  });

  final LocationState location;
  final NavigationState nav;
  final LiveNavInfo? live;
  final VoidCallback onToggleTrack;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final speedKmh = ((location.speed ?? 0) * 3.6).round();
    final zone = location.nearestZone;
    final limit = live?.speedLimitKmh;
    final overLimit = limit != null && speedKmh > limit + 2;
    final tracking = location.follow || nav.navigating;

    return Material(
      color: NeonColors.deepSpace.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (nav.hasRoute && nav.destination != null) ...[
              Row(
                children: [
                  const Icon(Icons.navigation, color: NeonColors.cyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      live?.currentStep?.instructionIt ??
                          'Verso ${nav.destination!.label}',
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
                  unit: zone == null
                      ? ''
                      : formatDistance(zone.distanceMeters),
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
      ),
    );
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
