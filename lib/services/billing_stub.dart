import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../models/entitlement.dart';
import 'billing_types.dart';

final _dio = Dio(BaseOptions(
  baseUrl: AppConstants.apiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  headers: {'Content-Type': 'application/json'},
));

Options _auth(String? token, {String? trialStartedAt}) {
  return Options(headers: {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    if (trialStartedAt != null) 'X-Trial-Started-At': trialStartedAt,
  });
}

Map<String, dynamic>? _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return null;
}

Entitlement? _entitlementOf(Map<String, dynamic>? data) {
  if (data == null) return null;
  final map = data['entitlement'] is Map
      ? Map<String, dynamic>.from(data['entitlement'] as Map)
      : data;
  if (map['premium'] == null && map['navigatorOnly'] == null) return null;
  return Entitlement.fromJson(map);
}

Future<Map<String, dynamic>?> billingFetchEntitlement({
  required String token,
  String? trialStartedAt,
}) async {
  try {
    final response = await _dio.get(
      '/api/users/me',
      options: _auth(token, trialStartedAt: trialStartedAt),
    );
    return _asMap(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      try {
        final response = await _dio.get(
          '/api/auth/me',
          options: _auth(token, trialStartedAt: trialStartedAt),
        );
        return _asMap(response.data);
      } catch (_) {
        return null;
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

Future<BillingResult> billingPurchase({
  String? token,
  String? trialStartedAt,
}) async {
  final uri = Uri.parse(Entitlement.gsCheckoutUrl);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  return BillingResult(
    ok: launched,
    openedExternal: launched,
    message: launched
        ? 'Apri Gestione Semplificata per l’abbonamento 1,99 €/mese.'
        : 'Impossibile aprire la pagina di pagamento.',
  );
}

Future<BillingResult> billingRedeem({
  String? token,
  required String code,
}) async {
  if (token == null || token.isEmpty) {
    return const BillingResult(
      ok: false,
      message: 'Accedi per riscattare il codice.',
    );
  }
  try {
    final response = await _dio.post(
      '/api/billing/redeem',
      data: {'code': code},
      options: _auth(token),
    );
    final data = _asMap(response.data);
    return BillingResult(
      ok: true,
      entitlement: _entitlementOf(data),
      message: 'Premium attivo.',
    );
  } on DioException catch (e) {
    final msg = e.response?.data is Map
        ? (e.response!.data['error']?.toString())
        : null;
    return BillingResult(ok: false, message: msg ?? 'Codice non valido.');
  } catch (e) {
    return BillingResult(ok: false, message: 'Errore: $e');
  }
}
