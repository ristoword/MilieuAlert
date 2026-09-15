import 'package:dio/dio.dart';
import '../../models/emission_zone.dart';

class NdwDatasource {
  final Dio _dio;

  NdwDatasource({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<EmissionZone>> fetchZones() async {
    try {
      final response = await _dio.get(
        'https://data.ndw.nu/api/rest/static-road-data/emission-zones/v1/map',
        options: Options(
          headers: {'Accept': 'application/geo+json'},
          responseType: ResponseType.json,
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final features = data['features'] as List? ?? [];
      final zones = <EmissionZone>[];

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>? ?? {};
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        if (geometry == null) continue;

        final geoType = geometry['type'] as String?;
        final coordinates = geometry['coordinates'];
        if (coordinates == null) continue;

        List<List<List<double>>> polygonCoords;

        if (geoType == 'Polygon') {
          polygonCoords = _parsePolygonCoords(coordinates);
        } else if (geoType == 'MultiPolygon') {
          // Use the first polygon from MultiPolygon
          final firstPolygon = (coordinates as List).first;
          polygonCoords = _parsePolygonCoords(firstPolygon);
        } else {
          continue;
        }

        final id = props['id']?.toString() ??
            'ndw_${props['name'] ?? features.indexOf(feature)}';
        final city = props['areaName'] ??
            props['name'] ??
            props['city'] ??
            'Unknown';
        final name = props['name'] ?? props['areaName'] ?? city;
        final zoneType = props['zoneType'] ??
            props['environmentalZoneType'] ??
            'ENVIRONMENTAL_ZONE';

        int? minEuro;
        final euroStr = props['minimumEuroClassification']?.toString();
        if (euroStr != null) {
          final match = RegExp(r'\d+').firstMatch(euroStr);
          if (match != null) minEuro = int.tryParse(match.group(0)!);
        }

        zones.add(EmissionZone(
          id: id,
          country: 'NL',
          city: city,
          name: name,
          zoneType: zoneType,
          polygonCoordinates: polygonCoords,
          minimumEuroLevel: minEuro,
          restrictions: props['restrictions']?.toString(),
          officialSource:
              'https://data.ndw.nu/api/rest/static-road-data/emission-zones/v1/map',
          lastVerifiedAt: DateTime.now(),
        ));
      }

      return zones;
    } catch (e) {
      // Return empty list on error; caller can retry later
      return [];
    }
  }

  List<List<List<double>>> _parsePolygonCoords(dynamic coords) {
    final rings = coords as List;
    return rings
        .map((ring) => (ring as List)
            .map((point) => [
                  (point[0] as num).toDouble(),
                  (point[1] as num).toDouble(),
                ])
            .toList())
        .toList();
  }
}
