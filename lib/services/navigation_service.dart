import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../models/navigation_models.dart';

class NavigationService {
  NavigationService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 25),
            ));

  final Dio _dio;

  Future<List<PlaceHit>> searchAddress(
    String query, {
    String lang = 'it',
    double? lat,
    double? lon,
  }) async {
    final response = await _dio.get(
      '/api/geo/search',
      queryParameters: {
        'q': query,
        'lang': lang,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
      },
    );
    final list = (response.data['results'] as List?) ?? const [];
    return list
        .map((e) => PlaceHit.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<PlaceHit>> searchNearby({
    required String category,
    required double lat,
    required double lon,
    String lang = 'it',
    int radius = 1800,
  }) async {
    final response = await _dio.get(
      '/api/geo/nearby',
      queryParameters: {
        'category': category,
        'lat': lat,
        'lon': lon,
        'lang': lang,
        'radius': radius,
      },
    );
    final list = (response.data['results'] as List?) ?? const [];
    return list
        .map((e) => PlaceHit.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<RouteBundle> route({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
  }) async {
    final response = await _dio.get(
      '/api/geo/route',
      queryParameters: {
        'fromLat': fromLat,
        'fromLon': fromLon,
        'toLat': toLat,
        'toLon': toLon,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final rawAlts = (data['alternatives'] as List?) ?? const [];
    final alternatives = rawAlts.isNotEmpty
        ? rawAlts
            .map((e) => RoutePlan.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : [RoutePlan.fromJson(data)];
    return RouteBundle(alternatives: alternatives);
  }

  Future<HazardSet> hazards({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
    String? path,
  }) async {
    final response = await _dio.get(
      '/api/geo/cameras',
      queryParameters: {
        'minLat': minLat,
        'minLon': minLon,
        'maxLat': maxLat,
        'maxLon': maxLon,
        if (path != null && path.isNotEmpty) 'path': path,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final cameras = ((data['cameras'] as List?) ?? const [])
        .map((e) => SpeedCamera.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final limits = ((data['limits'] as List?) ?? const [])
        .map((e) => SpeedLimitPoint.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return HazardSet(cameras: cameras, limits: limits);
  }
}
