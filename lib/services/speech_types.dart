class VoiceInfo {
  final String name;
  final String lang;
  final String voiceUri;
  final bool localService;

  const VoiceInfo({
    required this.name,
    required this.lang,
    this.voiceUri = '',
    this.localService = false,
  });

  String get genderHint => '$name $voiceUri';
}
