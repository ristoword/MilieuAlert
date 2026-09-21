import 'package:flutter/foundation.dart';

import 'speech_engine_stub.dart'
    if (dart.library.js_interop) 'speech_engine_web.dart' as engine;
import 'speech_types.dart';

export 'speech_types.dart';

enum NavVoiceGender { female, male }

class TtsService {
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await engine.engineInit();
    _ready = true;
  }

  bool get speaking => engine.engineSpeaking();

  Future<void> stop() => engine.engineStop();

  Future<void> speak(
    String text, {
    required String languageCode,
    required NavVoiceGender gender,
    bool critical = false,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (!critical && speaking) return;

    await init();
    if (critical && speaking) {
      await stop();
    }

    final lang = bcp47(languageCode);
    final voices = await engine.engineListVoices();
    final picked = pickVoice(voices, lang: lang, gender: gender);
    _debugLogVoices(voices, picked, gender, lang);

    final double pitch;
    final double rate;
    if (gender == NavVoiceGender.female) {
      pitch = 1.14;
      rate = 0.98;
    } else {
      // Never pitch-shift a female/cloud voice into "male" — use a real male-named voice at natural pitch.
      pitch = 1.0;
      rate = 0.92;
    }

    await engine.engineSpeak(
      text: trimmed,
      lang: lang,
      voiceName: picked?.name,
      pitch: pitch,
      rate: rate,
      skipLangFallback: gender == NavVoiceGender.male,
    );
  }

  static VoiceInfo? pickVoice(
    List<VoiceInfo> voices, {
    required String lang,
    required NavVoiceGender gender,
  }) {
    if (voices.isEmpty) return null;
    final prefix = lang.split('-').first.toLowerCase();

    if (gender == NavVoiceGender.female) {
      final ranked = [...voices]
        ..sort(
          (a, b) => _score(b, lang, prefix, gender)
              .compareTo(_score(a, lang, prefix, gender)),
        );
      return ranked.first;
    }

    final maleVoices = voices
        .where((v) => inferGender(v.genderHint) == NavVoiceGender.male)
        .toList();
    if (maleVoices.isEmpty) return null;

    final ranked = [...maleVoices]
      ..sort(
        (a, b) =>
            _scoreMale(b, lang, prefix).compareTo(_scoreMale(a, lang, prefix)),
      );
    return ranked.first;
  }

  static int _scoreMale(VoiceInfo v, String lang, String prefix) {
    var s = 0;
    final vLang = v.lang.toLowerCase();
    if (vLang == lang.toLowerCase()) {
      s += 80;
    } else if (vLang.startsWith(prefix)) {
      s += 50;
    } else {
      s += 8;
    }
    if (v.localService) s += 35;
    return s;
  }

  static int _score(
    VoiceInfo v,
    String lang,
    String prefix,
    NavVoiceGender gender,
  ) {
    var s = 0;
    final vLang = v.lang.toLowerCase();
    if (vLang == lang.toLowerCase()) {
      s += 80;
    } else if (vLang.startsWith(prefix)) {
      s += 50;
    }
    if (v.localService) s += 20;
    final g = inferGender(v.genderHint);
    if (g == gender) s += 40;
    if (g != null && g != gender) s -= 25;
    return s;
  }

  static NavVoiceGender? inferGender(String name) {
    final padded =
        ' ${name.toLowerCase().replaceAll(RegExp(r'[^a-zàèéìòù]'), ' ')} ';
    bool has(List<String> tokens) =>
        tokens.any((t) => padded.contains(' $t '));
    const female = [
      'female',
      'woman',
      'girl',
      'femminile',
      'feminine',
      'vrouw',
      'vrouwelijk',
      'zira',
      'samantha',
      'karen',
      'susan',
      'fiona',
      'nicky',
      'helena',
      'hazel',
      'catherine',
      'elsa',
      'elisa',
      'elena',
      'giulia',
      'paola',
      'clara',
      'sofia',
      'laura',
      'emma',
      'alice',
      'rosa',
      'maria',
      'anna',
      'lisa',
      'isabella',
      'bianca',
      'francesca',
      'silvia',
      'jenny',
      'aria',
      'sonia',
      'elsie',
      'moira',
      'tessa',
      'veena',
    ];
    const male = [
      'male',
      'man',
      'uomo',
      'maschile',
      'mannelijk',
      'guy',
      'boy',
      'david',
      'mark',
      'daniel',
      'james',
      'thomas',
      'george',
      'richard',
      'stefan',
      'stefano',
      'luca',
      'giorgio',
      'cosimo',
      'matteo',
      'francesco',
      'marco',
      'paolo',
      'diego',
      'giuseppe',
      'alessandro',
      'roberto',
      'bruno',
      'ralf',
      'frank',
      'paul',
      'alex',
      'ryan',
      'brian',
      'christopher',
      'fred',
      'aaron',
      'maarten',
      'ruben',
      'xander',
      'coen',
      'sem',
    ];
    final hasF = has(female);
    final hasM = has(male);
    if (hasF && !hasM) return NavVoiceGender.female;
    if (hasM && !hasF) return NavVoiceGender.male;
    return null;
  }

  static String bcp47(String locale) {
    switch (locale.toLowerCase()) {
      case 'it':
        return 'it-IT';
      case 'nl':
        return 'nl-NL';
      case 'de':
        return 'de-DE';
      case 'fr':
        return 'fr-FR';
      default:
        return 'en-US';
    }
  }

  static void _debugLogVoices(
    List<VoiceInfo> voices,
    VoiceInfo? picked,
    NavVoiceGender gender,
    String lang,
  ) {
    if (!kDebugMode) return;
    final sample = voices.take(12).map((v) {
      final g = inferGender(v.genderHint)?.name ?? '?';
      return '${v.name} (${v.lang}, local=${v.localService}, g=$g)';
    }).join('; ');
    debugPrint(
      'TTS pick gender=${gender.name} lang=$lang picked=${picked?.name ?? "none"} '
      'of ${voices.length}: $sample',
    );
  }
}
