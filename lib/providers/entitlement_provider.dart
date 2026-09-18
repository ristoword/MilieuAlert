import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/entitlement.dart';
import 'auth_provider.dart';
import 'settings_provider.dart';
import '../services/billing_service.dart';

const kTrialStartedPref = 'trial_started_at';
const kPremiumPref = 'is_premium';

class EntitlementNotifier extends StateNotifier<Entitlement> {
  EntitlementNotifier(this._prefs, this._ref)
      : super(_fromPrefs(_prefs, _ref.read(authProvider))) {
    _ensureLocalStart();
    refresh();
  }

  final SharedPreferences _prefs;
  final Ref _ref;

  static Entitlement _fromPrefs(SharedPreferences prefs, AuthState auth) {
    final raw = prefs.getString(kTrialStartedPref);
    final started = raw == null ? null : DateTime.tryParse(raw);
    return Entitlement.local(
      now: DateTime.now(),
      trialStartedAt: started,
      premium: prefs.getBool(kPremiumPref) ?? false,
      email: auth.email,
      displayName: auth.displayName,
    );
  }

  Future<void> _ensureLocalStart() async {
    if (_prefs.getString(kTrialStartedPref) != null) return;
    final now = DateTime.now().toUtc();
    await _prefs.setString(kTrialStartedPref, now.toIso8601String());
    if (!mounted) return;
    state = Entitlement.local(
      now: DateTime.now(),
      trialStartedAt: now,
      premium: state.premium,
      email: _ref.read(authProvider).email,
      displayName: _ref.read(authProvider).displayName,
    );
  }

  String? get localTrialStartedAt => _prefs.getString(kTrialStartedPref);

  Future<void> refresh({Map<String, dynamic>? payload}) async {
    await _ensureLocalStart();
    final auth = _ref.read(authProvider);
    Map<String, dynamic>? data = payload;
    if (data == null && auth.token != null && auth.token!.isNotEmpty) {
      data = await BillingService.fetchEntitlement(
        token: auth.token!,
        trialStartedAt: localTrialStartedAt,
      );
    }
    final localStart = DateTime.tryParse(localTrialStartedAt ?? '');
    if (data != null) {
      final map = data['entitlement'] is Map
          ? Map<String, dynamic>.from(data['entitlement'] as Map)
          : data;
      var next = Entitlement.fromJson(map);
      if (next.trialStartedAt == null && localStart != null) {
        next = Entitlement.local(
          now: DateTime.now(),
          trialStartedAt: localStart,
          premium: next.premium,
          complimentary: next.complimentary,
          email: auth.email ?? data['email'] as String?,
          displayName: auth.displayName ?? data['display_name'] as String?,
        );
      }
      await _prefs.setBool(kPremiumPref, next.premium);
      if (next.trialStartedAt != null) {
        final existing = localStart;
        final start = existing == null ||
                next.trialStartedAt!.isBefore(existing)
            ? next.trialStartedAt!
            : existing;
        await _prefs.setString(kTrialStartedPref, start.toIso8601String());
      }
      if (!mounted) return;
      state = next;
      return;
    }
    if (!mounted) return;
    state = Entitlement.local(
      now: DateTime.now(),
      trialStartedAt: localStart,
      premium: _prefs.getBool(kPremiumPref) ?? false,
      email: auth.email,
      displayName: auth.displayName,
    );
  }

  Future<BillingResult> upgrade() async {
    final auth = _ref.read(authProvider);
    final result = await BillingService.purchase(
      token: auth.token,
      trialStartedAt: localTrialStartedAt,
    );
    if (result.entitlement != null) {
      await _prefs.setBool(kPremiumPref, result.entitlement!.premium);
      if (!mounted) return result;
      state = result.entitlement!;
    } else if (result.ok) {
      await refresh();
    }
    return result;
  }

  Future<BillingResult> redeem(String code) async {
    final auth = _ref.read(authProvider);
    final result = await BillingService.redeem(
      token: auth.token,
      code: code,
    );
    if (result.entitlement != null) {
      await _prefs.setBool(kPremiumPref, true);
      if (!mounted) return result;
      state = result.entitlement!;
    } else if (result.ok) {
      await refresh();
    }
    return result;
  }
}

final entitlementProvider =
    StateNotifierProvider<EntitlementNotifier, Entitlement>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return EntitlementNotifier(prefs, ref);
});

final navigatorOnlyProvider = Provider<bool>((ref) {
  return ref.watch(entitlementProvider).navigatorOnly;
});
