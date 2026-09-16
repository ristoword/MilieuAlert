import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  String _currentLanguage = 'en-US';

  Future<void> init() async {
    try {
      await _tts.setSharedInstance(true);
    } catch (_) {}
    try {
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> setLanguage(String locale) async {
    final langMap = {
      'it': 'it-IT',
      'nl': 'nl-NL',
      'en': 'en-US',
      'de': 'de-DE',
      'fr': 'fr-FR',
    };
    _currentLanguage = langMap[locale] ?? 'en-US';
    await _tts.setLanguage(_currentLanguage);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
