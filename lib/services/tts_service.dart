import 'package:flutter/foundation.dart';

import 'speech_engine_stub.dart'
    if (dart.library.js_interop) 'speech_engine_web.dart' as engine;
import 'speech_types.dart';

export 'speech_types.dart';

enum _TtsVoiceKind { female, male, unknown }

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
    final picked = pickVoice(voices, lang: lang);
    _debugLogVoices(voices, picked, lang);

    // Web Speech API: rate 1.0 = normal (2.0 ≈ double speed).
    // flutter_tts (Android/iOS): 0.5 ≈ normal, 1.0 ≈ 2× — see speech_engine_stub.dart.
    await engine.engineSpeak(
      text: trimmed,
      lang: lang,
      voiceName: picked?.name,
      pitch: kIsWeb ? 1.0 : 1.0,
      rate: kIsWeb ? 1.0 : 0.5,
    );
  }

  static VoiceInfo? pickVoice(
    List<VoiceInfo> voices, {
    required String lang,
  }) {
    if (voices.isEmpty) return null;
    final prefix = lang.split('-').first.toLowerCase();
    final ranked = [...voices]
      ..sort(
        (a, b) => _score(b, lang, prefix).compareTo(_score(a, lang, prefix)),
      );
    return ranked.first;
  }

  static int _score(VoiceInfo v, String lang, String prefix) {
    var s = 0;
    final vLang = v.lang.toLowerCase();
    if (vLang == lang.toLowerCase()) {
      s += 80;
    } else if (vLang.startsWith(prefix)) {
      s += 50;
    }
    if (v.localService) s += 20;
    final voiceKind = _voiceKind(v.genderHint);
    if (voiceKind == _TtsVoiceKind.female) s += 45;
    if (voiceKind == _TtsVoiceKind.male) s -= 80;
    return s;
  }

  static _TtsVoiceKind _voiceKind(String name) {
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
      'google italiano',
    ];
    const male = [
      'male',
      'man',
      'uomo',
      'maschile',
      'mannelijk',
    ];
    final hasF = has(female);
    final hasM = has(male);
    if (hasF && !hasM) return _TtsVoiceKind.female;
    if (hasM && !hasF) return _TtsVoiceKind.male;
    return _TtsVoiceKind.unknown;
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
    String lang,
  ) {
    if (!kDebugMode) return;
    final sample = voices.take(12).map((v) {
      final g = _voiceKind(v.genderHint).name;
      return '${v.name} (${v.lang}, local=${v.localService}, g=$g)';
    }).join('; ');
    debugPrint(
      'TTS pick lang=$lang picked=${picked?.name ?? "none"} '
      'of ${voices.length}: $sample',
    );
  }
}
