import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../models/hazard_report.dart';
import '../models/navigation_models.dart';

class HazardService {
  HazardService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 15),
            ));

  final Dio _dio;

  Options _opts({String? token, required String deviceId}) {
    return Options(headers: {
      'Content-Type': 'application/json',
      'X-Device-Id': deviceId,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });
  }

  Future<List<HazardReport>> nearby({
    required double lat,
    required double lon,
    int radius = 4000,
    String? token,
    required String deviceId,
  }) async {
    final response = await _dio.get(
      '/api/hazards/nearby',
      queryParameters: {'lat': lat, 'lon': lon, 'radius': radius},
      options: _opts(token: token, deviceId: deviceId),
    );
    final list = (response.data['reports'] as List?) ?? const [];
    return list
        .map((e) => HazardReport.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<HazardReport> report({
    required HazardType type,
    required double lat,
    required double lon,
    double? heading,
    String? note,
    String? token,
    required String deviceId,
  }) async {
    final response = await _dio.post(
      '/api/hazards/report',
      data: {
        'type': type.apiValue,
        'lat': lat,
        'lon': lon,
        if (heading != null) 'heading': heading,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        'device_id': deviceId,
      },
      options: _opts(token: token, deviceId: deviceId),
    );
    return HazardReport.fromJson(
      Map<String, dynamic>.from(response.data['report'] as Map),
    );
  }

  Future<HazardReport> vote({
    required String id,
    required String vote,
    String? token,
    required String deviceId,
  }) async {
    final response = await _dio.post(
      '/api/hazards/$id/vote',
      data: {'vote': vote, 'device_id': deviceId},
      options: _opts(token: token, deviceId: deviceId),
    );
    return HazardReport.fromJson(
      Map<String, dynamic>.from(response.data['report'] as Map),
    );
  }

  Future<List<HazardComment>> comments({
    required String id,
    String? token,
    required String deviceId,
  }) async {
    final response = await _dio.get(
      '/api/hazards/$id/comments',
      options: _opts(token: token, deviceId: deviceId),
    );
    final list = (response.data['comments'] as List?) ?? const [];
    return list
        .map((e) => HazardComment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<HazardComment> addComment({
    required String id,
    required String text,
    String? token,
    required String deviceId,
  }) async {
    final response = await _dio.post(
      '/api/hazards/$id/comments',
      data: {'text': text, 'device_id': deviceId},
      options: _opts(token: token, deviceId: deviceId),
    );
    return HazardComment.fromJson(
      Map<String, dynamic>.from(response.data['comment'] as Map),
    );
  }

  Future<List<SpeedCamera>> osmAndCommunityCameras({
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
    return ((data['cameras'] as List?) ?? const [])
        .map((e) => SpeedCamera.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
