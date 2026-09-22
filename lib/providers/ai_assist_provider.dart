import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/navigation_models.dart';
import '../models/saved_places.dart';
import '../models/zone_status.dart';
import '../services/ai_assist_service.dart';
import '../services/ai_fallback.dart';
import 'auth_provider.dart';
import 'favorites_provider.dart';
import 'location_provider.dart';
import 'navigation_provider.dart';
import 'settings_provider.dart';
import 'vehicle_provider.dart';
import 'voice_guidance_provider.dart';

class AiAssistState {
  final List<AiChatMessage> messages;
  final bool loading;
  final AiHint? hint;
  final String? error;

  const AiAssistState({
    this.messages = const [],
    this.loading = false,
    this.hint,
    this.error,
  });

  AiAssistState copyWith({
    List<AiChatMessage>? messages,
    bool? loading,
    AiHint? hint,
    String? error,
    bool clearHint = false,
    bool clearError = false,
  }) {
    return AiAssistState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      hint: clearHint ? null : (hint ?? this.hint),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final aiAssistProvider =
    StateNotifierProvider<AiAssistNotifier, AiAssistState>((ref) {
  final notifier = AiAssistNotifier(ref, AiAssistService());
  ref.listen<NavigationState>(navigationProvider, (prev, next) {
    notifier.onNavAlerts(prev?.alerts ?? const [], next.alerts);
  });
  ref.listen<LocationState>(locationProvider, (prev, next) {
    notifier.onProximity(prev?.nearestZone, next.nearestZone);
  });
  return notifier;
});

class AiAssistNotifier extends StateNotifier<AiAssistState> {
  AiAssistNotifier(this._ref, this._service) : super(const AiAssistState());

  final Ref _ref;
  final AiAssistService _service;
  final List<String> _hinted = [];
  DateTime? _lastHintAt;
  int _seq = 0;

  String get _lang => _ref.read(localeProvider).languageCode;

  Future<void> ensureWelcome() async {
    if (state.messages.isNotEmpty) return;
    final lang = _lang;
    final text = lang == 'nl'
        ? 'Hoi, ik ben de MilieuAlert-assistent. Vraag me naar zones, flitsers of de route.'
        : lang == 'en'
            ? 'Hi, I am the MilieuAlert copilot. Ask me about LEZs, cameras or your route.'
            : 'Ciao, sono l’assistente MilieuAlert. Chiedimi del percorso, delle zone o degli avvisi.';
    state = state.copyWith(messages: [
      AiChatMessage(
        id: 'welcome',
        fromUser: false,
        text: text,
        at: DateTime.now(),
      ),
    ]);
  }

  void dismissHint() {
    state = state.copyWith(clearHint: true);
  }

  Future<void> askAboutAlert(RouteChangeAlert alert) async {
    await send(
      alert.message,
      intent: 'alert_hint',
      extraAlerts: [alert],
    );
  }

  Future<void> askAboutProximity() async {
    final zone = _ref.read(locationProvider).nearestZone;
    if (zone == null) {
      await send('Ci sono zone vicino?', intent: 'nav_briefing');
      return;
    }
    await send(
      zone.status == ZoneStatus.inside
          ? 'Sono dentro ${zone.zoneName}'
          : 'Mi sto avvicinando a ${zone.zoneName}',
      intent: 'alert_hint',
    );
  }

  void onNavAlerts(List<RouteChangeAlert> prev, List<RouteChangeAlert> next) {
    final seen = {for (final a in prev) a.id};
    for (final alert in next) {
      if (seen.contains(alert.id)) continue;
      _emitHint(
        id: 'nav-${alert.id}',
        intent: 'alert_hint',
        message: alert.message,
        extraAlerts: [alert],
        speak: false,
      );
    }
  }

  void onProximity(ZoneProximity? prev, ZoneProximity? next) {
    if (next == null || next.status == ZoneStatus.safe) return;
    final key =
        'prox-${next.zoneId}-${next.status.name}-${next.isVehicleAllowed}';
    if (prev != null &&
        prev.zoneId == next.zoneId &&
        prev.status == next.status &&
        prev.isVehicleAllowed == next.isVehicleAllowed) {
      return;
    }
    final msg = next.status == ZoneStatus.inside
        ? (next.isVehicleAllowed == false
            ? 'Sei dentro ${next.zoneName}, veicolo non autorizzato'
            : 'Sei dentro ${next.zoneName}')
        : 'Ti stai avvicinando a ${next.zoneName}';
    _emitHint(id: key, intent: 'alert_hint', message: msg, speak: false);
  }

  Future<void> send(
    String raw, {
    String intent = 'chat',
    List<RouteChangeAlert> extraAlerts = const [],
  }) async {
    final message = raw.trim();
    if (message.isEmpty) return;
    await ensureWelcome();
    final userMsg = AiChatMessage(
      id: 'u-${++_seq}',
      fromUser: true,
      text: message,
      at: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      loading: true,
      clearError: true,
    );

    await _tryLocalNavCommand(message);

    try {
      final result = await _request(
        message: message,
        intent: intent,
        extraAlerts: extraAlerts,
      );
      final bot = AiChatMessage(
        id: 'a-$_seq',
        fromUser: false,
        text: result.reply,
        at: DateTime.now(),
      );
      if (!mounted) return;
      state = state.copyWith(
        messages: [...state.messages, bot],
        loading: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: 'Assistente non disponibile');
    }
  }

  void _emitHint({
    required String id,
    required String intent,
    required String message,
    List<RouteChangeAlert> extraAlerts = const [],
    bool speak = false,
  }) {
    if (_hinted.contains(id)) return;
    final now = DateTime.now();
    if (_lastHintAt != null &&
        now.difference(_lastHintAt!) < const Duration(seconds: 18)) {
      return;
    }
    _hinted.add(id);
    if (_hinted.length > 80) {
      _hinted.removeAt(0);
    }
    _lastHintAt = now;
    Future.microtask(() async {
      final result = await _request(
        message: message,
        intent: intent,
        extraAlerts: extraAlerts,
      );
      if (!mounted) return;
      final text = result.hint.isEmpty ? result.reply : result.hint;
      if (text.isEmpty) return;
      state = state.copyWith(hint: AiHint(id: id, text: text));
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        if (state.hint?.id == id) dismissHint();
      });
      if (speak) {
        await _speak(text);
      }
    });
  }

  Future<AiAssistResult> _request({
    required String message,
    required String intent,
    List<RouteChangeAlert> extraAlerts = const [],
  }) {
    final context = buildDrivingContext(_ref, extraAlerts: extraAlerts);
    final token = _ref.read(authProvider).token;
    return _service.assist(
      message: message,
      intent: intent,
      language: _lang,
      context: context,
      token: token,
    );
  }

  Future<void> _tryLocalNavCommand(String message) async {
    final q = message.toLowerCase();
    final nav = _ref.read(navigationProvider.notifier);
    final fav = _ref.read(favoritesProvider);
    if (_has(q, const ['casa', 'home', 'thuis', 'a casa', 'portami a casa'])) {
      final place = fav.placeByLabel('Casa');
      if (place != null) {
        await _goToPlace(place);
      }
      return;
    }
    if (_has(q, const ['lavoro', 'work', 'werk', 'portami al lavoro'])) {
      final place = fav.placeByLabel('Lavoro');
      if (place != null) {
        await _goToPlace(place);
      }
      return;
    }
    if (_has(q, const ['alternativ', 'altro percorso', 'altro itinerario'])) {
      final stateNav = _ref.read(navigationProvider);
      if (stateNav.alternatives.length > 1) {
        final next = (stateNav.selectedRoute + 1) % stateNav.alternatives.length;
        await nav.selectAlternative(next);
      }
      return;
    }
    if (_has(q, const ['stop', 'ferma navigazione', 'annulla percorso'])) {
      nav.stopNavigation();
    }
  }

  Future<void> _goToPlace(SavedPlace place) async {
    final nav = _ref.read(navigationProvider.notifier);
    nav.useMyLocationAsOrigin();
    nav.setEndpoint(
      PlaceHit(
        label: place.address.trim().isEmpty ? place.label : place.address,
        lat: place.lat,
        lon: place.lon,
      ),
      SearchField.destination,
    );
    await nav.planRoute(startFollowing: true);
  }

  Future<void> _speak(String text) async {
    try {
      await _ref.read(ttsServiceProvider).speak(
            text,
            languageCode: _lang,
          );
    } catch (_) {}
  }

  bool _has(String q, List<String> words) => words.any(q.contains);
}

Map<String, dynamic> buildDrivingContext(
  Ref ref, {
  List<RouteChangeAlert> extraAlerts = const [],
}) {
  final loc = ref.read(locationProvider);
  final nav = ref.read(navigationProvider);
  final vehicle = ref.read(vehicleProvider).valueOrNull;
  final fav = ref.read(favoritesProvider);
  LiveNavInfo? live;
  if (loc.latitude != null && loc.longitude != null) {
    live = ref
        .read(navigationProvider.notifier)
        .liveInfo(loc.latitude!, loc.longitude!);
  }
  final alerts = [
    ...extraAlerts.map(_alertJson),
    ...nav.alerts.map(_alertJson),
  ];
  return {
    'gps': {
      'lat': loc.latitude,
      'lon': loc.longitude,
      'speedKmh': loc.speed == null ? null : (loc.speed! * 3.6).round(),
    },
    'route': {
      'originLabel': nav.originIsMyLocation
          ? 'La mia posizione'
          : nav.origin?.label,
      'destLabel': nav.destination?.label,
      'remainingMeters': live?.remainingMeters ?? nav.routeDistanceMeters,
      'durationSeconds': nav.routeDurationSeconds,
      'navigating': nav.navigating,
      'hasRoute': nav.hasRoute,
      'alternativeCount': nav.alternatives.isEmpty
          ? (nav.hasRoute ? 1 : 0)
          : nav.alternatives.length,
      'selectedRoute': nav.selectedRoute,
      'dropOffWalkMeters': nav.walkMeters,
      'usingDropOff': nav.usingDropOff,
      'dropOffMessage': nav.dropOffMessage,
    },
    'zonesOnRoute': nav.zonesOnRoute
        .take(6)
        .map((z) => {
              'id': z.id,
              'name': z.name,
              'city': z.city,
              'country': z.country,
              'active': z.isCurrentlyActive,
              'restrictions': z.restrictions,
              'minimumEuroLevel': z.minimumEuroLevel,
            })
        .toList(),
    'nearestAlert': loc.nearestZone == null
        ? null
        : {
            'zoneName': loc.nearestZone!.zoneName,
            'status': loc.nearestZone!.status.name,
            'distanceMeters': loc.nearestZone!.distanceMeters,
            'vehicleAllowed': loc.nearestZone!.isVehicleAllowed,
          },
    'nextCamera': live?.nextCamera == null
        ? null
        : {
            'distanceMeters': live!.nextCameraMeters,
            'maxspeed': live.nextCamera!.maxspeed,
          },
    'alerts': alerts.take(4).toList(),
    'vehicle': vehicle == null
        ? null
        : {
            'type': vehicle.type.name,
            'fuel': vehicle.fuelType.name,
            'euroClass': vehicle.euroClass.label,
            'euroLevel': vehicle.euroClass.level,
          },
    'savedPlaces': fav.places.map((p) => p.label).toList(),
  };
}

Map<String, dynamic> _alertJson(RouteChangeAlert alert) => {
      'id': alert.id,
      'kind': alert.kind.name,
      'title': alert.title,
      'message': alert.message,
    };
