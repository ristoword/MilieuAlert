import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/widgets/install_app_button.dart';
import '../../models/emission_zone.dart';
import '../../providers/location_provider.dart';
import '../../providers/zone_provider.dart';
import 'widgets/alert_banner.dart';
import 'widgets/status_bar.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _movedToUser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final zonesAsync = ref.watch(zonesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(locationProvider, (prev, next) {
      if (!_movedToUser && next.latitude != null && next.longitude != null) {
        _movedToUser = true;
        _mapController.move(
          LatLng(next.latitude!, next.longitude!),
          13,
        );
      }
    });

    final center = LatLng(
      locationState.latitude ?? AppConstants.initialLat,
      locationState.longitude ?? AppConstants.initialLng,
    );

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: locationState.latitude != null
                  ? 13
                  : AppConstants.initialZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.milieualert.app',
              ),
              zonesAsync.when(
                data: (zones) => PolygonLayer(polygons: _polygonsFor(zones)),
                loading: () => PolygonLayer(polygons: <Polygon>[]),
                error: (_, __) => PolygonLayer(polygons: <Polygon>[]),
              ),
              if (locationState.latitude != null &&
                  locationState.longitude != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        locationState.latitude!,
                        locationState.longitude!,
                      ),
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
                  ],
                ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: AlertBanner(proximity: locationState.nearestZone),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: _roundButton(
              isDark: isDark,
              icon: Icons.settings,
              onTap: () => context.push('/settings'),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: const InstallAppButton(compact: true),
          ),
          if (locationState.error != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              left: 16,
              right: 16,
              child: Material(
                color: NeonColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    locationState.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StatusBar(
              speed: locationState.speed,
              proximity: locationState.nearestZone,
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          backgroundColor: NeonColors.electricBlue,
          onPressed: () {
            ref.read(locationProvider.notifier).startTracking();
            final loc = ref.read(locationProvider);
            if (loc.latitude != null && loc.longitude != null) {
              _mapController.move(LatLng(loc.latitude!, loc.longitude!), 14);
            }
          },
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
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

  Widget _roundButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark
          ? Colors.black.withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: NeonColors.cyan, size: 22),
        ),
      ),
    );
  }
}
