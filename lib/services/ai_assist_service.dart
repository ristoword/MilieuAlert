import 'package:dio/dio.dart';

import '../core/constants.dart';
import 'ai_fallback.dart';

class AiAssistService {
  AiAssistService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 16),
              headers: {'Content-Type': 'application/json'},
            ));

  final Dio _dio;

  Future<AiAssistResult> assist({
    required String message,
    required String intent,
    required String language,
    required Map<String, dynamic> context,
    String? token,
    String? sessionId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/ai/assist',
        data: {
          'message': message,
          'intent': intent,
          'language': language,
          'context': context,
          'sessionId': sessionId ?? 'nav-assist',
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );
      final data = response.data;
      if (data is Map) {
        final parsed = AiAssistResult.fromJson(Map<String, dynamic>.from(data));
        if (parsed.reply.isNotEmpty) return parsed;
      }
    } catch (_) {}
    return localAiFallback(
      message: message,
      intent: intent,
      language: language,
      context: context,
    );
  }
}
