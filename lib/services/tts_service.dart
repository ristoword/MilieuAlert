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
    final pitch = gender == NavVoiceGender.female ? 1.14 : 0.84;
    final rate = gender == NavVoiceGender.female ? 0.98 : 0.9;

    await engine.engineSpeak(
      text: trimmed,
      lang: lang,
      voiceName: picked?.name,
      pitch: pitch,
      rate: rate,
    );
  }

  static VoiceInfo? pickVoice(
    List<VoiceInfo> voices, {
    required String lang,
    required NavVoiceGender gender,
  }) {
    if (voices.isEmpty) return null;
    final prefix = lang.split('-').first.toLowerCase();
    final ranked = [...voices]..sort((a, b) {
        return _score(b, lang, prefix, gender)
            .compareTo(_score(a, lang, prefix, gender));
      });
    return ranked.first;
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
    final g = inferGender(v.name);
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
      'vrouw',
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
    ];
    const male = [
      'male',
      'man',
      'guy',
      'boy',
      'maschile',
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
}
