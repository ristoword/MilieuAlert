class AiAssistResult {
  final String reply;
  final String hint;
  final String source;
  final String language;

  const AiAssistResult({
    required this.reply,
    required this.hint,
    required this.source,
    required this.language,
  });

  factory AiAssistResult.fromJson(Map<String, dynamic> json) {
    final reply = (json['reply'] ?? json['response'] ?? '').toString().trim();
    final hint = (json['hint'] ?? '').toString().trim();
    return AiAssistResult(
      reply: reply,
      hint: hint.isEmpty ? reply : hint,
      source: (json['source'] ?? 'fallback').toString(),
      language: (json['language'] ?? 'it').toString(),
    );
  }
}

class AiChatMessage {
  final String id;
  final bool fromUser;
  final String text;
  final DateTime at;

  const AiChatMessage({
    required this.id,
    required this.fromUser,
    required this.text,
    required this.at,
  });
}

class AiHint {
  final String id;
  final String text;

  const AiHint({required this.id, required this.text});
}

String firstAiSentence(String text) {
  final raw = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (raw.isEmpty) return '';
  final match = RegExp(r'^[^.!?]+[.!?]?').firstMatch(raw);
  final cut = (match?.group(0) ?? raw).trim();
  if (cut.length > 220) return '${cut.substring(0, 217)}...';
  return cut;
}

String formatAiDistance(num? meters) {
  if (meters == null) return '';
  final m = meters.toDouble();
  if (!m.isFinite) return '';
  if (m < 1000) return '${m.round()} m';
  return '${(m / 1000).toStringAsFixed(1)} km';
}

AiAssistResult localAiFallback({
  required String message,
  required String intent,
  required String language,
  required Map<String, dynamic> context,
}) {
  final lang = _lang(language);
  final q = message.toLowerCase();
  final nearest = _map(context['nearestAlert']);
  final camera = _map(context['nextCamera']);
  final route = _map(context['route']);
  final vehicle = _map(context['vehicle']);
  final zones = _list(context['zonesOnRoute']);
  final alerts = _list(context['alerts']);
  final places = (context['savedPlaces'] as List?)
          ?.map((e) => e.toString().toLowerCase())
          .toList() ??
      const <String>[];

  final zoneName = (nearest['zoneName'] ?? nearest['name'] ?? '').toString();
  final status = (nearest['status'] ?? '').toString().toLowerCase();
  final dist = formatAiDistance(nearest['distanceMeters'] as num?);
  final denied = nearest['vehicleAllowed'] == false || _vehicleDenied(vehicle, zones);

  if (intent == 'alert_hint' && alerts.isNotEmpty) {
    return _pack(_alertLine(alerts.first, camera, lang), lang);
  }

  if (_has(q, const ['casa', 'home', 'thuis', 'maison', 'a casa'])) {
    if (!_hasPlace(places, const ['casa', 'home', 'thuis'])) {
      return _pack(_t(lang, missingHome: true), lang);
    }
    return _pack(_t(lang, goingHome: true), lang);
  }
  if (_has(q, const ['lavoro', 'work', 'werk', 'travail', 'ufficio'])) {
    if (!_hasPlace(places, const ['lavoro', 'work', 'werk'])) {
      return _pack(_t(lang, missingWork: true), lang);
    }
    return _pack(_t(lang, goingWork: true), lang);
  }
  if (_has(q, const ['alternativ', 'altro percorso', 'altro itinerario'])) {
    final n = (route['alternativeCount'] as num?)?.toInt() ?? 0;
    if (n <= 1) return _pack(_t(lang, noAlt: true), lang);
    return _pack(_t(lang, switchAlt: true), lang);
  }
  if (_has(q, const ['autovelox', 'camera', 'flitser', 'blitzer', 'radar'])) {
    final camDist = formatAiDistance(camera['distanceMeters'] as num?);
    if (camDist.isEmpty) {
      return _pack(_t(lang, noCamera: true), lang);
    }
    return _pack(_cameraLine(lang, camDist, camera['maxspeed']?.toString()), lang);
  }
  if (_has(q, const ['veicol', 'euro', 'diesel', 'conforme', 'allowed', 'autorizz'])) {
    final name = zoneName.isEmpty ? _zoneNames(zones) : zoneName;
    if (denied) {
      return _pack(_t(lang, vehicleBad: true, zone: name, euro: vehicle['euroClass']?.toString(), fuel: vehicle['fuel']?.toString()), lang);
    }
    return _pack(_t(lang, vehicleOk: true, zone: name), lang);
  }

  if (status == 'inside' && denied && zoneName.isNotEmpty) {
    return _pack(_t(lang, insideDenied: true, zone: zoneName), lang);
  }
  if (status == 'inside' && zoneName.isNotEmpty) {
    return _pack(_t(lang, insideOk: true, zone: zoneName), lang);
  }
  if (status == 'approaching' && denied && zoneName.isNotEmpty) {
    return _pack(
      _t(lang, approachingDenied: true, zone: zoneName, dist: dist.isEmpty ? '400 m' : dist),
      lang,
    );
  }
  if (status == 'approaching' && zoneName.isNotEmpty) {
    return _pack(
      _t(lang, approachingOk: true, zone: zoneName, dist: dist.isEmpty ? '400 m' : dist),
      lang,
    );
  }

  final camDist = formatAiDistance(camera['distanceMeters'] as num?);
  final camMeters = (camera['distanceMeters'] as num?)?.toDouble();
  if (camDist.isNotEmpty && camMeters != null && camMeters < 800) {
    return _pack(_cameraLine(lang, camDist, camera['maxspeed']?.toString()), lang);
  }

  if (alerts.isNotEmpty) {
    return _pack(_alertLine(alerts.first, camera, lang), lang);
  }

  final dest = (route['destLabel'] ?? '').toString();
  final remain = formatAiDistance(route['remainingMeters'] as num?);
  final names = _zoneNames(zones);
  final alts = ((route['alternativeCount'] as num?)?.toInt() ?? 0) > 1;
  if (names.isNotEmpty && dest.isNotEmpty) {
    return _pack(
      _t(lang, briefingZones: true, dest: dest, dist: remain, zones: names, alts: alts),
      lang,
    );
  }
  if (dest.isNotEmpty || route['hasRoute'] == true) {
    return _pack(_t(lang, briefingClear: true, dest: dest, dist: remain), lang);
  }
  return _pack(_t(lang, help: true), lang);
}

String _lang(String raw) {
  final v = raw.toLowerCase();
  if (v.startsWith('nl')) return 'nl';
  if (v.startsWith('en')) return 'en';
  if (v.startsWith('de')) return 'de';
  if (v.startsWith('fr')) return 'fr';
  return 'it';
}

Map<String, dynamic> _map(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

List<Map<String, dynamic>> _list(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

bool _has(String q, List<String> words) => words.any(q.contains);

bool _hasPlace(List<String> places, List<String> keys) {
  return places.any((p) => keys.contains(p.trim().toLowerCase()));
}

bool _vehicleDenied(
  Map<String, dynamic> vehicle,
  List<Map<String, dynamic>> zones,
) {
  final euro = (vehicle['euroLevel'] as num?)?.toInt();
  final fuel = (vehicle['fuel'] ?? '').toString().toLowerCase();
  if (fuel == 'electric') return false;
  for (final z in zones) {
    final min = (z['minimumEuroLevel'] as num?)?.toInt();
    if (euro != null && min != null && euro < min) return true;
  }
  return false;
}

String _zoneNames(List<Map<String, dynamic>> zones) {
  return zones
      .map((z) => (z['name'] ?? '').toString())
      .where((n) => n.isNotEmpty)
      .take(3)
      .join(', ');
}

AiAssistResult _pack(String reply, String lang) {
  return AiAssistResult(
    reply: reply,
    hint: firstAiSentence(reply),
    source: 'fallback',
    language: lang,
  );
}

String _cameraLine(String lang, String dist, String? limit) {
  if (lang == 'nl') {
    return limit == null || limit.isEmpty
        ? 'Flitser over $dist: controleer je snelheid.'
        : 'Flitser over $dist, limiet $limit km/u: minderen.';
  }
  if (lang == 'en') {
    return limit == null || limit.isEmpty
        ? 'Speed camera in $dist: check your speed.'
        : 'Speed camera in $dist, limit $limit km/h: slow down.';
  }
  return limit == null || limit.isEmpty
      ? 'Autovelox tra $dist: controlla la velocità.'
      : 'Autovelox tra $dist, limite $limit km/h: rallenta ora.';
}

String _alertLine(Map<String, dynamic> alert, Map<String, dynamic> camera, String lang) {
  final kind = (alert['kind'] ?? '').toString().toLowerCase();
  final msg = (alert['message'] ?? '').toString();
  if (kind.contains('camera')) {
    final dist = formatAiDistance(camera['distanceMeters'] as num?);
    return _cameraLine(lang, dist.isEmpty ? '400 m' : dist, camera['maxspeed']?.toString());
  }
  if (msg.isNotEmpty) return msg;
  return _t(lang, help: true);
}

String _t(
  String lang, {
  bool missingHome = false,
  bool missingWork = false,
  bool goingHome = false,
  bool goingWork = false,
  bool noAlt = false,
  bool switchAlt = false,
  bool noCamera = false,
  bool vehicleOk = false,
  bool vehicleBad = false,
  bool insideDenied = false,
  bool insideOk = false,
  bool approachingDenied = false,
  bool approachingOk = false,
  bool briefingClear = false,
  bool briefingZones = false,
  bool help = false,
  String zone = '',
  String dist = '',
  String dest = '',
  String zones = '',
  String? euro,
  String? fuel,
  bool alts = false,
}) {
  if (lang == 'nl') {
    if (missingHome) return 'Thuis is nog niet opgeslagen.';
    if (missingWork) return 'Werk is nog niet opgeslagen.';
    if (goingHome) return 'Bestemming Thuis, route wordt berekend.';
    if (goingWork) return 'Bestemming Werk, route wordt berekend.';
    if (noAlt) return 'Geen alternatieve routes nu.';
    if (switchAlt) return 'Ik schakel naar een alternatieve route.';
    if (noCamera) return 'Geen flitser dichtbij op dit traject.';
    if (vehicleBad) return 'Je ${euro ?? 'voertuig'} ${fuel ?? ''} mag $zone niet in. Kies een andere route.';
    if (vehicleOk) return 'Met dit voertuig lijkt $zone toegelaten.';
    if (insideDenied) return 'Je bent in $zone en het voertuig is niet toegelaten. Verlaat de zone.';
    if (insideOk) return 'Je bent in $zone: voertuig toegelaten.';
    if (approachingDenied) {
      return 'Over $dist milieuzone $zone, voertuig niet toegelaten: kies een alternatieve route.';
    }
    if (approachingOk) return 'Over $dist rijd je $zone in. Voertuig lijkt toegelaten.';
    if (briefingZones) {
      return 'Naar $dest${dist.isEmpty ? '' : ', $dist'}: zones $zones.${alts ? ' Er zijn alternatieven.' : ''}';
    }
    if (briefingClear) {
      return dest.isEmpty
          ? 'Geen route. Stel A en B of Thuis/Werk in.'
          : 'Route naar $dest${dist.isEmpty ? '' : ', nog $dist'}. Geen kritieke zone nu.';
    }
    return 'Ik help met milieuzones, toelating, flitsers en alternatieven.';
  }
  if (lang == 'en') {
    if (missingHome) return 'Home is not saved yet. Save it from the places bar.';
    if (missingWork) return 'Work is not saved yet.';
    if (goingHome) return 'Setting Home as destination and calculating a route.';
    if (goingWork) return 'Setting Work as destination and calculating a route.';
    if (noAlt) return 'No alternative routes right now.';
    if (switchAlt) return 'Switching to an alternative route.';
    if (noCamera) return 'No speed camera close on this stretch.';
    if (vehicleBad) return 'Your ${euro ?? 'vehicle'} ${fuel ?? ''} is not allowed in $zone. Use another route.';
    if (vehicleOk) return 'With this vehicle $zone looks allowed.';
    if (insideDenied) return 'You are inside $zone and the vehicle is not authorized. Leave or reroute now.';
    if (insideOk) return 'Inside $zone: vehicle authorized. Keep to zone rules.';
    if (approachingDenied) {
      return 'In $dist: LEZ $zone — vehicle not allowed. Take an alternative.';
    }
    if (approachingOk) return 'In $dist you enter $zone. Vehicle looks allowed — keep to the limit.';
    if (briefingZones) {
      return 'To $dest${dist.isEmpty ? '' : ', $dist'}: zones $zones.${alts ? ' Alternatives available.' : ''}';
    }
    if (briefingClear) {
      return dest.isEmpty
          ? 'No A→B route yet. Set destination or Home/Work.'
          : 'Route to $dest${dist.isEmpty ? '' : ', $dist left'}. No critical zone right now.';
    }
    return 'I can warn about LEZs, vehicle access, cameras and alternatives.';
  }
  if (missingHome) return 'Casa non è ancora salvata. Tocca Casa + nella barra luoghi.';
  if (missingWork) return 'Lavoro non è ancora salvato. Tocca Lavoro + e imposta l’ufficio.';
  if (goingHome) return 'Imposto Casa come destinazione e calcolo il percorso.';
  if (goingWork) return 'Imposto Lavoro come destinazione e calcolo il percorso.';
  if (noAlt) return 'Non ci sono itinerari alternativi al momento.';
  if (switchAlt) return 'Passo a un itinerario alternativo e controllo zone e autovelox.';
  if (noCamera) return 'Nessun autovelox vicino su questo tratto.';
  if (vehicleBad) {
    return 'Il tuo ${euro ?? 'veicolo'} ${fuel ?? ''} non è conforme per $zone. Usa un altro itinerario.';
  }
  if (vehicleOk) return 'Con il veicolo attuale $zone risulta accessibile. Conferma le regole ufficiali.';
  if (insideDenied) return 'Sei dentro $zone e il veicolo non è autorizzato. Esci o cambia percorso.';
  if (insideOk) return 'Sei dentro $zone: veicolo autorizzato. Mantieni i limiti della zona.';
  if (approachingDenied) {
    return 'Tra $dist zona ambientale $zone, veicolo non conforme: evita l’ingresso o scegli un itinerario alternativo.';
  }
  if (approachingOk) {
    return 'Tra $dist entri in $zone. Il veicolo risulta conforme: procedi e rispetta i limiti.';
  }
  if (briefingZones) {
    return 'Verso $dest${dist.isEmpty ? '' : ', $dist'}: zone $zones.${alts ? ' Hai itinerari alternativi.' : ' Verifica conformità prima di entrare.'}';
  }
  if (briefingClear) {
    return dest.isEmpty
        ? 'Nessun itinerario attivo. Imposta A e B, oppure Casa/Lavoro.'
        : 'Percorso verso $dest${dist.isEmpty ? '' : ', mancano $dist'}. Nessuna zona critica ora.';
  }
  return 'Posso dirti zone LEZ sul percorso, se il veicolo può entrare, autovelox vicini e alternative. Prova: “ci sono zone?”, “autovelox?”, “portami a casa”.';
}
