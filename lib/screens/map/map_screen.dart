import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/zone_provider.dart';
import '../../providers/location_provider.dart';
import 'widgets/status_bar.dart';
import 'widgets/alert_banner.dart';

const String _mapStyle = '''
{
  "version": 8,
  "sources": {
    "osm": {
      "type": "raster",
      "tiles": ["https://tile.openstreetmap.org/{z}/{x}/{y}.png"],
      "tileSize": 256,
      "attribution": "&copy; OpenStreetMap contributors"
    }
  },
  "layers": [
    {
      "id": "osm",
      "type": "raster",
      "source": "osm"
    }
  ]
}
''';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapLibreMapController? _mapController;
  bool _zonesAdded = false;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final zonesAsync = ref.watch(zonesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _mapStyle,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                locationState.latitude ?? AppConstants.initialLat,
                locationState.longitude ?? AppConstants.initialLng,
              ),
              zoom: locationState.latitude != null
                  ? 12.0
                  : AppConstants.initialZoom,
            ),
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.trackingGps,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: () => _onStyleLoaded(zonesAsync),
          ),
          // Alert banner at top
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: AlertBanner(
              proximity: locationState.nearestZone,
            ),
          ),
          // Settings button with glassmorphism
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: NeonColors.cyan.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: NeonColors.cyan.withValues(alpha: 0.15),
                        blurRadius: 10,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.push('/settings'),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              NeonColors.primaryGradient.createShader(bounds),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Status bar at bottom
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
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoaded(AsyncValue zonesAsync) {
    zonesAsync.whenData((zones) {
      if (!_zonesAdded && _mapController != null) {
        _addZoneLayers(zones);
        _zonesAdded = true;
      }
    });
  }

  Future<void> _addZoneLayers(List zones) async {
    if (_mapController == null) return;

    final features = <Map<String, dynamic>>[];
    for (final zone in zones) {
      if (zone.polygonCoordinates.isEmpty) continue;
      features.add({
        'type': 'Feature',
        'id': zone.id,
        'properties': {
          'id': zone.id,
          'name': zone.name,
          'zoneType': zone.zoneType,
        },
        'geometry': {
          'type': 'Polygon',
          'coordinates': zone.polygonCoordinates,
        },
      });
    }

    final geoJson = {
      'type': 'FeatureCollection',
      'features': features,
    };

    await _mapController!.addSource(
      'zones-source',
      GeojsonSourceProperties(data: jsonEncode(geoJson)),
    );

    await _mapController!.addFillLayer(
      'zones-source',
      'zones-fill',
      const FillLayerProperties(
        fillColor: '#00E676',
        fillOpacity: 0.18,
      ),
    );

    await _mapController!.addLineLayer(
      'zones-source',
      'zones-line',
      const LineLayerProperties(
        lineColor: '#00E676',
        lineWidth: 2.5,
        lineOpacity: 0.85,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
