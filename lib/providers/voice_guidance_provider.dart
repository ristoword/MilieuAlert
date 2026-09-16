import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/hazard_strings.dart';
import '../models/hazard_report.dart';
import '../models/navigation_models.dart';
import '../models/zone_status.dart';
import '../services/tts_service.dart';
import 'hazard_provider.dart';
import 'location_provider.dart';
import 'navigation_provider.dart';
import 'settings_provider.dart';

final ttsServiceProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  ref.onDispose(() {
    tts.stop();
  });
  return tts;
});

/// Keeps turn-by-turn and alert speech running while the map is open.
final voiceGuidanceProvider = Provider<VoiceGuidance>((ref) {
  final guidance = VoiceGuidance(ref);
  ref.listen<LocationState>(locationProvider, guidance.onLocation);
  ref.listen<HazardState>(hazardProvider, guidance.onHazards);
  ref.listen<NavigationState>(navigationProvider, guidance.onNavigation);
  ref.onDispose(guidance.dispose);
  return guidance;
});

class VoiceGuidance {
  VoiceGuidance(this._ref);

  final Ref _ref;
  final Set<String> _spoken = {};
  DateTime? _lastSpeakAt;

  TtsService get _tts => _ref.read(ttsServiceProvider);
  String get _lang => _ref.read(localeProvider).languageCode;
  NavVoiceGender get _gender => _ref.read(navVoiceProvider);

  void dispose() {
    _tts.stop();
  }

  void onLocation(LocationState? prev, LocationState next) {
    _maybeSpeakLez(prev?.nearestZone, next.nearestZone);

    final nav = _ref.read(navigationProvider);
    LiveNavInfo? live;
    if (next.latitude != null && next.longitude != null) {
      live = _ref.read(navigationProvider.notifier).liveInfo(
            next.latitude!,
            next.longitude!,
            heading: next.heading,
            accuracy: next.accuracy,
            speedMps: next.speed,
          );
    }
    if (nav.navigating) {
      _maybeSpeakTurn(live);
    }
    if (nav.mode.isCar) {
      _maybeSpeakCamera(live?.nextCamera, live?.nextCameraMeters);
    }
  }

  void onHazards(HazardState? prev, HazardState next) {
    final seen = {for (final r in prev?.incoming ?? const []) r.id};
    for (final report in next.incoming) {
      if (seen.contains(report.id)) continue;
      _speakReport(report);
    }
  }

  void onNavigation(NavigationState? prev, NavigationState next) {
    if (prev?.navigating == true && !next.navigating) {
      _spoken.removeWhere((k) => k.startsWith('turn-') || k.startsWith('cam-'));
    }
    if (prev?.routeDistanceMeters != next.routeDistanceMeters ||
        prev?.steps != next.steps) {
      _spoken.removeWhere((k) => k.startsWith('turn-'));
    }
    final seen = {for (final a in prev?.alerts ?? const []) a.id};
    for (final alert in next.alerts) {
      if (seen.contains(alert.id)) continue;
      if (alert.kind == RouteAlertKind.newCamera ||
          alert.kind == RouteAlertKind.newZone) {
        continue;
      }
      _speak('alert-${alert.id}', alert.message);
    }
  }

  void _maybeSpeakTurn(LiveNavInfo? live) {
    final step = live?.currentStep;
    if (step == null || live == null) return;
    if (!step.isManeuver && step.lanes.isEmpty) return;
    final meters = live.metersToManeuver;
    final bucket = meters <= 40
        ? 'now'
        : meters <= 80
            ? 'near80'
            : meters <= 200
                ? 'mid200'
                : meters <= 400
                    ? 'far400'
                    : null;
    if (bucket == null) return;
    final key = 'turn-${live.stepIndex}-$bucket';
    final text = _turnPhrase(step, bucket, meters);
    _speak(key, text, critical: bucket == 'now', skipCooldown: true);
  }

  void _maybeSpeakLez(ZoneProximity? prev, ZoneProximity? next) {
    if (next == null || next.status == ZoneStatus.safe) return;
    if (prev != null &&
        prev.zoneId == next.zoneId &&
        prev.status == next.status &&
        prev.isVehicleAllowed == next.isVehicleAllowed) {
      return;
    }
    final key =
        'lez-${next.zoneId}-${next.status.name}-${next.isVehicleAllowed}';
    final dist = formatDistance(next.distanceMeters);
    final allowed = next.isVehicleAllowed != false;
    final text = switch (next.status) {
      ZoneStatus.approaching => _t(
          it: 'Zona ambientale tra $dist. ${next.zoneName}',
          nl: 'Milieuzone over $dist. ${next.zoneName}',
          en: 'Low emission zone in $dist. ${next.zoneName}',
        ),
      ZoneStatus.inside => allowed
          ? _t(
              it: 'Sei dentro ${next.zoneName}. Veicolo autorizzato',
              nl: 'Je bent in ${next.zoneName}. Voertuig toegestaan',
              en: 'You are inside ${next.zoneName}. Vehicle allowed',
            )
          : _t(
              it: 'Attenzione. Sei dentro ${next.zoneName}. Veicolo non autorizzato',
              nl: 'Let op. Je bent in ${next.zoneName}. Voertuig niet toegestaan',
              en: 'Warning. You are inside ${next.zoneName}. Vehicle not allowed',
            ),
      ZoneStatus.safe => '',
    };
    _speak(key, text, critical: next.status == ZoneStatus.inside && !allowed);
  }

  void _maybeSpeakCamera(SpeedCamera? camera, double? meters) {
    if (camera == null || meters == null || meters > 500) return;
    final bucket = meters <= 120 ? 'near' : 'far';
    final key = 'cam-${camera.id}-$bucket';
    final dist = formatDistance(meters);
    final limit = camera.maxspeed;
    final limitBit = (limit != null && limit.isNotEmpty)
        ? _t(it: '. Limite $limit', nl: '. Limiet $limit', en: '. Limit $limit')
        : '';
    final text = _t(
      it: 'Autovelox tra $dist$limitBit',
      nl: 'Flitser over $dist$limitBit',
      en: 'Speed camera in $dist$limitBit',
    );
    _speak(key, text, critical: meters <= 120);
  }

  void _speakReport(HazardReport report) {
    final dist = formatDistance(report.distanceMeters);
    final title = HazardStrings(_lang).bannerTitle(report.type, dist);
    _speak('haz-${report.id}', title);
  }

  String _turnPhrase(NavStep step, String bucket, double meters) {
    final action = _maneuver(_lang, step);
    if (step.type == 'arrive') {
      return _t(it: 'Sei arrivato', nl: 'Je bent er', en: 'You have arrived');
    }
    if (bucket == 'now') {
      return _t(it: 'Adesso, $action', nl: 'Nu, $action', en: 'Now, $action');
    }
    final dist = formatDistance(meters);
    return _t(
      it: 'Tra $dist, $action',
      nl: 'Over $dist, $action',
      en: 'In $dist, $action',
    );
  }

  String _maneuver(String lang, NavStep step) {
    if (lang == 'nl') return _maneuverNl(step);
    if (lang == 'en') return _maneuverEn(step);
    return step.maneuverIt;
  }

  String _maneuverEn(NavStep step) {
    switch (step.type) {
      case 'arrive':
        return 'you have arrived';
      case 'roundabout':
      case 'rotary':
        return 'enter the roundabout';
      case 'merge':
        return 'merge';
      case 'fork':
        return step.modifier.contains('left') ? 'keep left' : 'keep right';
      case 'on ramp':
        return 'take the ramp';
      case 'off ramp':
      case 'exit':
        return 'take the exit';
      case 'turn':
        if (step.modifier.contains('left')) return 'turn left';
        if (step.modifier.contains('right')) return 'turn right';
        if (step.modifier.contains('uturn')) return 'make a U-turn';
        return 'turn';
      default:
        return 'continue';
    }
  }

  String _maneuverNl(NavStep step) {
    switch (step.type) {
      case 'arrive':
        return 'je bent er';
      case 'roundabout':
      case 'rotary':
        return 'rij de rotonde op';
      case 'merge':
        return 'voeg in';
      case 'fork':
        return step.modifier.contains('left')
            ? 'houd links aan'
            : 'houd rechts aan';
      case 'on ramp':
        return 'neem de oprit';
      case 'off ramp':
      case 'exit':
        return 'neem de afrit';
      case 'turn':
        if (step.modifier.contains('left')) return 'linksaf';
        if (step.modifier.contains('right')) return 'rechtsaf';
        if (step.modifier.contains('uturn')) return 'keer om';
        return 'afslaan';
      default:
        return 'rechtdoor';
    }
  }

  String _t({required String it, required String nl, required String en}) {
    switch (_lang) {
      case 'nl':
        return nl;
      case 'en':
        return en;
      default:
        return it;
    }
  }

  Future<void> preview() {
    final sample = _gender == NavVoiceGender.female
        ? _t(
            it: 'Voce femminile. Gira a destra tra 200 metri',
            nl: 'Vrouwelijke stem. Over 200 meter rechtsaf',
            en: 'Female voice. Turn right in 200 meters',
          )
        : _t(
            it: 'Voce maschile. Gira a destra tra 200 metri',
            nl: 'Mannelijke stem. Over 200 meter rechtsaf',
            en: 'Male voice. Turn right in 200 meters',
          );
    return _tts.speak(
      sample,
      languageCode: _lang,
      gender: _gender,
      critical: true,
    );
  }

  Future<void> _speak(
    String key,
    String text, {
    bool critical = false,
    bool skipCooldown = false,
  }) async {
    if (text.trim().isEmpty) return;
    if (_spoken.contains(key)) return;
    final now = DateTime.now();
    if (!critical &&
        !skipCooldown &&
        _lastSpeakAt != null &&
        now.difference(_lastSpeakAt!) < const Duration(seconds: 5)) {
      return;
    }
    _spoken.add(key);
    if (_spoken.length > 100) {
      _spoken.remove(_spoken.first);
    }
    _lastSpeakAt = now;
    await _tts.speak(
      text,
      languageCode: _lang,
      gender: _gender,
      critical: critical,
    );
  }
}
