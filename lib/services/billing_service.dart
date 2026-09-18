import '../core/constants.dart';
import '../models/entitlement.dart';
import 'billing_impl.dart';
import 'billing_types.dart';

export 'billing_types.dart';

class BillingService {
  static const productId = Entitlement.playProductId;
  static const gsCheckoutUrl = Entitlement.gsCheckoutUrl;
  static const apiBase = AppConstants.apiBaseUrl;

  static Future<Map<String, dynamic>?> fetchEntitlement({
    required String token,
    String? trialStartedAt,
  }) =>
      billingFetchEntitlement(token: token, trialStartedAt: trialStartedAt);

  static Future<BillingResult> purchase({
    String? token,
    String? trialStartedAt,
  }) =>
      billingPurchase(token: token, trialStartedAt: trialStartedAt);

  static Future<BillingResult> redeem({
    String? token,
    required String code,
  }) =>
      billingRedeem(token: token, code: code);
}
