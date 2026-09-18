import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/navigation_models.dart';
import '../core/constants.dart';
import '../services/tts_service.dart';

export '../services/tts_service.dart' show NavVoiceGender;

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
      : super(Locale(_prefs.getString('locale') ?? 'it'));

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

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return OnboardingNotifier(prefs);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs)
      : super(_prefs.getBool('onboardingComplete') ?? false);

  Future<void> complete() async {
    state = true;
    await _prefs.setBool('onboardingComplete', true);
  }
}

final navVoiceProvider =
    StateNotifierProvider<NavVoiceNotifier, NavVoiceGender>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return NavVoiceNotifier(prefs);
});

class NavVoiceNotifier extends StateNotifier<NavVoiceGender> {
  NavVoiceNotifier(this._prefs)
      : super(_parse(_prefs.getString('nav_voice_gender')));

  final SharedPreferences _prefs;

  static NavVoiceGender _parse(String? raw) {
    switch (raw) {
      case 'male':
      case 'maschile':
        return NavVoiceGender.male;
      default:
        return NavVoiceGender.female;
    }
  }

  Future<void> setGender(NavVoiceGender gender) async {
    state = gender;
    await _prefs.setString('nav_voice_gender', gender.name);
  }
}

final travelModeProvider =
    StateNotifierProvider<TravelModeNotifier, TravelMode>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return TravelModeNotifier(prefs);
});

class TravelModeNotifier extends StateNotifier<TravelMode> {
  TravelModeNotifier(this._prefs)
      : super(parseTravelMode(_prefs.getString('travel_mode')));

  final SharedPreferences _prefs;

  Future<void> setMode(TravelMode mode) async {
    if (state == mode) return;
    state = mode;
    await _prefs.setString('travel_mode', mode.name);
  }
}
