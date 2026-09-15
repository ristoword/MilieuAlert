import 'dart:convert';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../models/emission_zone.dart';
import '../../../models/zone_status.dart';

class ZoneOverlay {
  final MapLibreMapController controller;

  ZoneOverlay({required this.controller});

  Future<void> addZones(List<EmissionZone> zones,
      {ZoneProximity? proximity}) async {
    final features = <Map<String, dynamic>>[];

    for (final zone in zones) {
      if (zone.polygonCoordinates.isEmpty) continue;

      String color;
      double opacity;

      if (proximity != null && proximity.zoneId == zone.id) {
        switch (proximity.status) {
          case ZoneStatus.inside:
            color = '#FF1744';
            opacity = 0.30;
            break;
          case ZoneStatus.approaching:
            color = '#FF6D00';
            opacity = 0.25;
            break;
          case ZoneStatus.safe:
            color = '#00E676';
            opacity = 0.20;
            break;
        }
      } else {
        color = '#00E676';
        opacity = 0.15;
      }

      features.add({
        'type': 'Feature',
        'id': zone.id,
        'properties': {
          'id': zone.id,
          'name': zone.name,
          'color': color,
          'opacity': opacity,
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

    try {
      await controller.removeLayer('zones-fill');
      await controller.removeLayer('zones-line');
      await controller.removeSource('zones-source');
    } catch (_) {}

    await controller.addSource(
      'zones-source',
      GeojsonSourceProperties(data: jsonEncode(geoJson)),
    );

    await controller.addFillLayer(
      'zones-source',
      'zones-fill',
      FillLayerProperties(
        fillColor: ['get', 'color'],
        fillOpacity: ['get', 'opacity'],
      ),
    );

    await controller.addLineLayer(
      'zones-source',
      'zones-line',
      LineLayerProperties(
        lineColor: ['get', 'color'],
        lineWidth: 2.5,
        lineOpacity: 0.9,
      ),
    );
  }
}
