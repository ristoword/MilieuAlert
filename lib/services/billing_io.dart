import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants.dart';
import '../models/entitlement.dart';
import 'billing_types.dart';

final _dio = Dio(BaseOptions(
  baseUrl: AppConstants.apiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 12),
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

StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
String? Function()? _tokenOf;
void Function(Entitlement entitlement)? _onEntitlement;
Completer<BillingResult>? _pendingPurchase;
String? _restoredForToken;

/// Listens to Google Play purchase updates for the whole app lifetime.
/// Every purchase is verified by the API, then acknowledged with
/// [InAppPurchase.completePurchase] (Play refunds unacknowledged buys after 3 days).
void billingInit({
  required String? Function() token,
  required void Function(Entitlement entitlement) onEntitlement,
}) {
  _tokenOf = token;
  _onEntitlement = onEntitlement;
  if (!Platform.isAndroid || _purchaseSub != null) return;
  _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
    _onPurchases,
    onError: (Object _) {
      _finishPurchase(const BillingResult(
        ok: false,
        message: 'Google Play non disponibile. Riprova.',
      ));
    },
  );
}

/// Re-delivers active Play subscriptions once per login so renewals and
/// reinstalls re-activate premium (and pending acknowledgements complete).
Future<void> billingRestore({String? token}) async {
  if (!Platform.isAndroid || _purchaseSub == null) return;
  if (token == null || token.isEmpty || _restoredForToken == token) return;
  _restoredForToken = token;
  try {
    if (await InAppPurchase.instance.isAvailable()) {
      await InAppPurchase.instance.restorePurchases();
    }
  } catch (_) {
    _restoredForToken = null;
  }
}

void _finishPurchase(BillingResult result) {
  final pending = _pendingPurchase;
  _pendingPurchase = null;
  if (pending != null && !pending.isCompleted) pending.complete(result);
}

Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
  final iap = InAppPurchase.instance;
  for (final p in purchases) {
    if (p.productID != Entitlement.playProductId) {
      if (p.pendingCompletePurchase) await iap.completePurchase(p);
      continue;
    }
    switch (p.status) {
      case PurchaseStatus.pending:
        continue;
      case PurchaseStatus.canceled:
        if (p.pendingCompletePurchase) await iap.completePurchase(p);
        _finishPurchase(const BillingResult(
          ok: false,
          message: 'Acquisto annullato.',
        ));
        continue;
      case PurchaseStatus.error:
        if (p.pendingCompletePurchase) await iap.completePurchase(p);
        _finishPurchase(const BillingResult(
          ok: false,
          message: 'Pagamento non riuscito. Riprova.',
        ));
        continue;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final entitlement = await _verifyPlay(p);
        if (entitlement == null) {
          // Not acknowledged: Play re-delivers it on the next restore.
          _restoredForToken = null;
          _finishPurchase(const BillingResult(
            ok: false,
            message:
                'Pagamento ricevuto, attivazione in corso. Riapri l’app tra qualche minuto.',
          ));
          continue;
        }
        if (p.pendingCompletePurchase) await iap.completePurchase(p);
        _onEntitlement?.call(entitlement);
        _finishPurchase(BillingResult(
          ok: true,
          entitlement: entitlement,
          message: 'Premium attivo.',
        ));
    }
  }
}

Future<Entitlement?> _verifyPlay(PurchaseDetails p) async {
  final token = _tokenOf?.call();
  final purchaseToken = p.verificationData.serverVerificationData;
  if (token == null || token.isEmpty || purchaseToken.isEmpty) return null;
  try {
    final response = await _dio.post(
      '/api/billing/play',
      data: {
        'productId': p.productID,
        'purchaseToken': purchaseToken,
        if (p.purchaseID != null) 'orderId': p.purchaseID,
      },
      options: _auth(token),
    );
    final entitlement = _entitlementOf(_asMap(response.data));
    if (entitlement == null || !entitlement.premium) return null;
    return entitlement;
  } catch (_) {
    return null;
  }
}

Future<BillingResult> billingPurchase({
  String? token,
  String? trialStartedAt,
}) async {
  if (!Platform.isAndroid) {
    return const BillingResult(
      ok: false,
      message: 'L’abbonamento è disponibile su Google Play.',
    );
  }
  if (token == null || token.isEmpty) {
    return const BillingResult(
      ok: false,
      message: 'Accedi per attivare l’abbonamento.',
    );
  }
  if (_purchaseSub == null) {
    return const BillingResult(
      ok: false,
      message: 'Google Play non pronto. Riprova.',
    );
  }
  if (_pendingPurchase != null) {
    return const BillingResult(
      ok: false,
      message: 'Acquisto già in corso su Google Play.',
    );
  }
  final iap = InAppPurchase.instance;
  if (!await iap.isAvailable()) {
    return const BillingResult(
      ok: false,
      message: 'Google Play non disponibile su questo dispositivo.',
    );
  }
  final response = await iap.queryProductDetails({Entitlement.playProductId});
  if (response.productDetails.isEmpty) {
    return const BillingResult(
      ok: false,
      message: 'Abbonamento non ancora disponibile. Riprova più tardi.',
    );
  }
  final pending = Completer<BillingResult>();
  _pendingPurchase = pending;
  try {
    final started = await iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: response.productDetails.first),
    );
    if (!started) {
      _finishPurchase(const BillingResult(
        ok: false,
        message: 'Acquisto Play non avviato.',
      ));
    }
  } catch (_) {
    _finishPurchase(const BillingResult(
      ok: false,
      message: 'Acquisto Play non avviato.',
    ));
  }
  return pending.future.timeout(
    const Duration(minutes: 5),
    onTimeout: () {
      _pendingPurchase = null;
      return const BillingResult(
        ok: false,
        message: 'Pagamento in attesa su Google Play.',
      );
    },
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
