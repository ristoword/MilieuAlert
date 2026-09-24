import 'dart:async';
import 'dart:js_interop';

import 'speech_types.dart';

@JS('speechSynthesis')
external SpeechSynthesis get _synth;

@JS('SpeechSynthesisUtterance')
extension type SpeechSynthesisUtterance._(JSObject _) implements JSObject {
  external factory SpeechSynthesisUtterance(String text);
  external set lang(String value);
  external set pitch(num value);
  external set rate(num value);
  external set volume(num value);
  external set voice(SpeechSynthesisVoice? value);
  external set onend(JSFunction? value);
  external set onerror(JSFunction? value);
}

extension type SpeechSynthesisVoice._(JSObject _) implements JSObject {
  external String get name;
  external String get lang;
  external String get voiceURI;
  external bool get localService;
}

extension type SpeechSynthesis._(JSObject _) implements JSObject {
  external JSArray<SpeechSynthesisVoice> getVoices();
  external void speak(SpeechSynthesisUtterance utterance);
  external void cancel();
  external bool get speaking;
  external set onvoiceschanged(JSFunction? value);
}

Future<void> engineInit() async {
  await engineListVoices();
}

Future<List<VoiceInfo>> engineListVoices() async {
  try {
    var voices = _readVoices();
    if (voices.isNotEmpty) return voices;

    final completer = Completer<List<VoiceInfo>>();

    void tryFinish() {
      final v = _readVoices();
      if (v.isNotEmpty && !completer.isCompleted) {
        completer.complete(v);
      }
    }

    try {
      _synth.onvoiceschanged = (() => tryFinish()).toJS;
    } catch (_) {}

    tryFinish();

    for (var i = 0; i < 25; i++) {
      voices = _readVoices();
      if (voices.isNotEmpty) {
        tryFinish();
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    if (!completer.isCompleted) {
      completer.complete(_readVoices());
    }

    final result = await completer.future;
    return result;
  } catch (_) {
    return const [];
  } finally {
    try {
      _synth.onvoiceschanged = null;
    } catch (_) {}
  }
}

List<VoiceInfo> _readVoices() {
  final raw = _synth.getVoices().toDart;
  return [
    for (final v in raw)
      VoiceInfo(
        name: v.name,
        lang: v.lang,
        voiceUri: v.voiceURI,
        localService: v.localService,
      ),
  ];
}

bool engineSpeaking() {
  try {
    return _synth.speaking;
  } catch (_) {
    return false;
  }
}

Future<void> engineStop() async {
  try {
    _synth.cancel();
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
  SpeechSynthesisVoice? selected;
  try {
    final raw = _synth.getVoices().toDart;
    if (voiceName != null) {
      for (final v in raw) {
        if (v.name == voiceName) {
          selected = v;
          break;
        }
      }
    }
    if (selected == null && !skipLangFallback) {
      for (final v in raw) {
        if (v.lang
            .toLowerCase()
            .startsWith(lang.split('-').first.toLowerCase())) {
          selected = v;
          break;
        }
      }
    }
  } catch (_) {}

  final utterance = SpeechSynthesisUtterance(text);
  utterance.lang = lang;
  utterance.pitch = pitch.clamp(0.5, 1.5);
  // Cap at 1.0 so misconfigured callers never trigger Chrome "2×" speech.
  utterance.rate = rate.clamp(0.5, 1.0);
  utterance.volume = 1;
  if (selected != null) {
    utterance.voice = selected;
  }

  final done = Completer<void>();
  utterance.onend = (() {
    if (!done.isCompleted) done.complete();
  }).toJS;
  utterance.onerror = (() {
    if (!done.isCompleted) done.complete();
  }).toJS;

  try {
    if (_synth.speaking) _synth.cancel();
    _synth.speak(utterance);
  } catch (_) {
    if (!done.isCompleted) done.complete();
  }

  await done.future.timeout(
    Duration(seconds: 12 + (text.length ~/ 12)),
    onTimeout: () {},
  );
}
