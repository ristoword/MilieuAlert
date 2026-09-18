import '../models/entitlement.dart';

class BillingResult {
  const BillingResult({
    required this.ok,
    this.message,
    this.entitlement,
    this.openedExternal = false,
  });

  final bool ok;
  final String? message;
  final Entitlement? entitlement;
  final bool openedExternal;
}
