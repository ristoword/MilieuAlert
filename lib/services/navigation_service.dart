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

  Future<List<PlaceHit>> searchAddress(String query, {String lang = 'it'}) async {
    final response = await _dio.get(
      '/api/geo/search',
      queryParameters: {'q': query, 'lang': lang},
    );
    final list = (response.data['results'] as List?) ?? const [];
    return list
        .map((e) => PlaceHit.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<RoutePlan> route({
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
    final points = ((data['points'] as List?) ?? const [])
        .map((p) {
          final m = Map<String, dynamic>.from(p as Map);
          return <double>[
            (m['lon'] as num).toDouble(),
            (m['lat'] as num).toDouble(),
          ];
        })
        .toList();
    final steps = ((data['steps'] as List?) ?? const [])
        .map((s) => NavStep.fromJson(Map<String, dynamic>.from(s as Map)))
        .toList();
    final speeds = ((data['speeds'] as List?) ?? const [])
        .map((n) => (n as num).toDouble())
        .toList();
    return RoutePlan(
      points: points,
      steps: steps,
      speeds: speeds,
      distanceMeters: (data['distanceMeters'] as num?)?.toDouble() ?? 0,
      durationSeconds: (data['durationSeconds'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<HazardSet> hazards({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
  }) async {
    final response = await _dio.get(
      '/api/geo/cameras',
      queryParameters: {
        'minLat': minLat,
        'minLon': minLon,
        'maxLat': maxLat,
        'maxLon': maxLon,
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
