import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs)
      : super(Locale(_prefs.getString('locale') ?? 'en'));

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await _prefs.setString('locale', languageCode);
  }
}

final alertDistanceProvider =
    StateNotifierProvider<AlertDistanceNotifier, int>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return AlertDistanceNotifier(prefs);
});

class AlertDistanceNotifier extends StateNotifier<int> {
  final SharedPreferences _prefs;

  AlertDistanceNotifier(this._prefs)
      : super(
            _prefs.getInt('alertDistance') ?? AppConstants.defaultAlertDistance);

  Future<void> setDistance(int meters) async {
    state = meters;
    await _prefs.setInt('alertDistance', meters);
  }
}

final onboardingCompleteProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool('onboardingComplete') ?? false;
});
