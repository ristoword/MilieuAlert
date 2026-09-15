import 'package:dio/dio.dart';
import '../../models/emission_zone.dart';
import '../../core/constants.dart';

class BelgiumDatasource {
  final Dio _dio;

  BelgiumDatasource({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<EmissionZone>> fetchAllZones() async {
    final results = await Future.wait([
      _fetchAntwerpenZones(),
      _fetchBrusselsZones(),
    ]);
    return results.expand((list) => list).toList();
  }

  Future<List<EmissionZone>> _fetchAntwerpenZones() async {
    try {
      final response = await _dio.get(
        AppConstants.antwerpenApiUrl,
        options: Options(responseType: ResponseType.json),
      );

      final data = response.data as Map<String, dynamic>;
      final features = data['features'] as List? ?? [];
      final zones = <EmissionZone>[];

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>? ?? {};
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        if (geometry == null) continue;

        final coords = _extractPolygonCoords(geometry);
        if (coords == null) continue;

        final id = 'antwerpen_${props['OBJECTID'] ?? zones.length}';

        zones.add(EmissionZone(
          id: id,
          country: 'BE',
          city: 'Antwerpen',
          name: props['NAAM'] ?? 'Antwerpen LEZ',
          zoneType: 'ENVIRONMENTAL_ZONE',
          polygonCoordinates: coords,
          restrictions: props['OMSCHRIJVING']?.toString(),
          officialSource: 'https://www.slimnaarantwerpen.be/en/low-emission-zone',
          lastVerifiedAt: DateTime.now(),
        ));
      }

      return zones;
    } catch (e) {
      return [];
    }
  }

  Future<List<EmissionZone>> _fetchBrusselsZones() async {
    try {
      final response = await _dio.get(
        AppConstants.brusselsApiUrl,
        options: Options(responseType: ResponseType.json),
      );

      final data = response.data as Map<String, dynamic>;
      final features = data['features'] as List? ?? [];
      final zones = <EmissionZone>[];

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>? ?? {};
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        if (geometry == null) continue;

        final coords = _extractPolygonCoords(geometry);
        if (coords == null) continue;

        final id = 'brussels_${props['gid'] ?? zones.length}';

        zones.add(EmissionZone(
          id: id,
          country: 'BE',
          city: 'Brussels',
          name: props['name_en'] ?? props['name_fr'] ?? 'Brussels LEZ',
          zoneType: 'ENVIRONMENTAL_ZONE',
          polygonCoordinates: coords,
          officialSource: 'https://lez.brussels/',
          lastVerifiedAt: DateTime.now(),
        ));
      }

      return zones;
    } catch (e) {
      return [];
    }
  }

  List<List<List<double>>>? _extractPolygonCoords(
      Map<String, dynamic> geometry) {
    final geoType = geometry['type'] as String?;
    final coordinates = geometry['coordinates'];
    if (coordinates == null) return null;

    if (geoType == 'Polygon') {
      return _parsePolygonCoords(coordinates);
    } else if (geoType == 'MultiPolygon') {
      final firstPolygon = (coordinates as List).first;
      return _parsePolygonCoords(firstPolygon);
    }
    return null;
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
