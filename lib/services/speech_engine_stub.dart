import 'package:flutter_tts/flutter_tts.dart';

import 'speech_types.dart';

final FlutterTts _tts = FlutterTts();
bool _inited = false;

Future<void> engineInit() async {
  if (_inited) return;
  try {
    await _tts.setSharedInstance(true);
  } catch (_) {}
  try {
    await _tts.setVolume(1.0);
  } catch (_) {}
  _inited = true;
}

Future<List<VoiceInfo>> engineListVoices() async {
  await engineInit();
  try {
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    final out = <VoiceInfo>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final name = map['name']?.toString() ?? '';
      final lang = map['locale']?.toString() ?? map['lang']?.toString() ?? '';
      if (name.isEmpty) continue;
      out.add(VoiceInfo(name: name, lang: lang));
    }
    return out;
  } catch (_) {
    return const [];
  }
}

bool engineSpeaking() => false;

Future<void> engineStop() async {
  try {
    await _tts.stop();
  } catch (_) {}
}

Future<void> engineSpeak({
  required String text,
  required String lang,
  String? voiceName,
  required double pitch,
  required double rate,
  bool skipLangFallback = false,
}) async {
  await engineInit();
  try {
    await _tts.setLanguage(lang);
  } catch (_) {}
  if (voiceName != null && voiceName.isNotEmpty) {
    try {
      await _tts.setVoice({'name': voiceName, 'locale': lang});
    } catch (_) {}
  }
  try {
    await _tts.setPitch(pitch.clamp(0.5, 1.5));
    // flutter_tts: platform normal is ~0.5; 1.0 is roughly double speed.
    final nativeRate = rate.clamp(0.1, 1.0);
    final speechRate = nativeRate > 0.65 ? 0.5 : nativeRate;
    await _tts.setSpeechRate(speechRate);
  } catch (_) {}
  await _tts.speak(text);
}
