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
  final TextEditingController _searchCtrl = TextEditingController();
  bool _movedToUser = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final zonesAsync = ref.watch(zonesProvider);
    final nav = ref.watch(navigationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;

    ref.listen(locationProvider, (prev, next) {
      final shouldFollow = next.follow || nav.navigating;
      if (next.latitude == null || next.longitude == null) return;
      if (!_movedToUser || shouldFollow) {
        _movedToUser = true;
        _mapController.move(
          LatLng(next.latitude!, next.longitude!),
          nav.navigating ? 16 : 14,
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
                data: (zones) => PolygonLayer(polygons: _polygonsFor(zones)),
                loading: () => const PolygonLayer(polygons: <Polygon>[]),
                error: (_, __) => const PolygonLayer(polygons: <Polygon>[]),
              ),
              if (nav.route.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: nav.route,
                      color: NeonColors.cyan,
                      strokeWidth: 5,
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
            child: _SearchPanel(
              controller: _searchCtrl,
              nav: nav,
              onQuery: (q) {
                final lang = ref.read(localeProvider).languageCode;
                ref.read(navigationProvider.notifier).search(q, lang: lang);
              },
              onSelect: (hit) async {
                _searchCtrl.text = hit.label;
                await ref.read(navigationProvider.notifier).startNavigation(hit);
                _mapController.move(LatLng(hit.lat, hit.lon), 14);
              },
              onSettings: () => context.push('/settings'),
            ),
          ),
          Positioned(
            top: topPad + 72,
            left: 0,
            right: 0,
            child: AlertBanner(proximity: location.nearestZone),
          ),
          if (nav.zonesOnRoute.isNotEmpty)
            Positioned(
              top: topPad + 132,
              left: 12,
              right: 12,
              child: _RouteZoneBanner(zones: nav.zonesOnRoute),
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
                _searchCtrl.clear();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Polygon> _polygonsFor(List<EmissionZone> zones) {
    final polygons = <Polygon>[];
    for (final zone in zones) {
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
            color: NeonColors.neonGreen.withValues(alpha: 0.18),
            borderColor: NeonColors.neonGreen,
            borderStrokeWidth: 2,
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

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.nav,
    required this.onQuery,
    required this.onSelect,
    required this.onSettings,
  });

  final TextEditingController controller;
  final NavigationState nav;
  final ValueChanged<String> onQuery;
  final ValueChanged<PlaceHit> onSelect;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Material(
                color: NeonColors.darkCard.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(16),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Naviga verso un indirizzo…',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    prefixIcon: Icon(
                      nav.routing ? Icons.hourglass_top : Icons.search,
                      color: NeonColors.cyan,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: onQuery,
                  textInputAction: TextInputAction.search,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _IconChip(icon: Icons.settings, onTap: onSettings),
          ],
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
                    leading: const Icon(Icons.place, color: NeonColors.cyan),
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

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NeonColors.darkCard.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: NeonColors.cyan),
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
            if (nav.navigating && live?.currentStep != null) ...[
              Row(
                children: [
                  const Icon(Icons.navigation, color: NeonColors.cyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      live!.currentStep!.instructionIt,
                      style: GoogleFonts.exo2(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    formatDistance(live!.remainingMeters),
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
                  Text(
                    'Autovelox tra ${formatDistance(live!.nextCameraMeters)}'
                    '${live!.nextCamera!.maxspeed != null ? ' · ${live!.nextCamera!.maxspeed} km/h' : ''}',
                    style: const TextStyle(
                      color: NeonColors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
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
                if (nav.navigating) ...[
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
