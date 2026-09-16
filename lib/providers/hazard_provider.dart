import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/hazard_report.dart';
import '../models/navigation_models.dart';
import '../services/geo_utils.dart';
import '../services/hazard_service.dart';
import 'auth_provider.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

class HazardState {
  final List<HazardReport> reports;
  final List<SpeedCamera> cameras;
  final List<HazardReport> incoming;
  final bool sending;
  final String? error;
  final DateTime? lastFetchedAt;

  const HazardState({
    this.reports = const [],
    this.cameras = const [],
    this.incoming = const [],
    this.sending = false,
    this.error,
    this.lastFetchedAt,
  });

  HazardState copyWith({
    List<HazardReport>? reports,
    List<SpeedCamera>? cameras,
    List<HazardReport>? incoming,
    bool? sending,
    String? error,
    DateTime? lastFetchedAt,
    bool clearError = false,
  }) {
    return HazardState(
      reports: reports ?? this.reports,
      cameras: cameras ?? this.cameras,
      incoming: incoming ?? this.incoming,
      sending: sending ?? this.sending,
      error: clearError ? null : (error ?? this.error),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }
}

final hazardServiceProvider = Provider<HazardService>((ref) {
  return HazardService();
});

final hazardProvider =
    StateNotifierProvider<HazardNotifier, HazardState>((ref) {
  return HazardNotifier(ref, ref.watch(sharedPrefsProvider));
});

class HazardNotifier extends StateNotifier<HazardState> {
  HazardNotifier(this._ref, this._prefs) : super(const HazardState()) {
    _deviceId = _prefs.getString('device_id') ?? '';
    if (_deviceId.length < 8) {
      _deviceId = _newDeviceId();
      unawaited(_prefs.setString('device_id', _deviceId));
    }
  }

  final Ref _ref;
  final SharedPreferences _prefs;
  final HazardService _service = HazardService();
  Timer? _poll;
  DateTime? _lastOsmAt;
  final Set<String> _seenIds = {};
  late String _deviceId;
  double? _lat;
  double? _lon;

  String get deviceId => _deviceId;
  String? get _token => _ref.read(authProvider).token;

  void start({double? lat, double? lon}) {
    if (lat != null && lon != null) {
      _lat = lat;
      _lon = lon;
    }
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(refresh());
    });
    unawaited(refresh());
  }

  void stop() {
    _poll?.cancel();
    _poll = null;
  }

  void updateAnchor(double lat, double lon) {
    _lat = lat;
    _lon = lon;
  }

  Future<void> refresh() async {
    final loc = _ref.read(locationProvider);
    final lat = _lat ?? loc.latitude;
    final lon = _lon ?? loc.longitude;
    if (lat == null || lon == null) return;
    try {
      final reports = await _service.nearby(
        lat: lat,
        lon: lon,
        radius: 5000,
        token: _token,
        deviceId: _deviceId,
      );
      final incoming = <HazardReport>[];
      if (_seenIds.isEmpty) {
        for (final r in reports) {
          _seenIds.add(r.id);
        }
      } else {
        for (final r in reports) {
          if (_seenIds.add(r.id) &&
              (r.distanceMeters ?? 99999) <= 1200) {
            incoming.add(r);
          }
        }
      }
      var cameras = state.cameras;
      final osmStale = _lastOsmAt == null ||
          DateTime.now().difference(_lastOsmAt!) > const Duration(seconds: 50);
      if (osmStale) {
        try {
          cameras = await _service.osmAndCommunityCameras(
            minLat: lat - 0.04,
            minLon: lon - 0.04,
            maxLat: lat + 0.04,
            maxLon: lon + 0.04,
          );
          _lastOsmAt = DateTime.now();
        } catch (_) {}
      }
      if (!mounted) return;
      state = state.copyWith(
        reports: reports.where((r) => !r.hiddenByVotes && !r.isExpired).toList(),
        cameras: cameras,
        incoming: [...incoming, ...state.incoming]
            .where((r) => !r.hiddenByVotes)
            .take(4)
            .toList(),
        lastFetchedAt: DateTime.now(),
        clearError: true,
      );
    } catch (_) {
      if (!mounted) return;
    }
  }

  void dismissIncoming(String id) {
    state = state.copyWith(
      incoming: state.incoming.where((r) => r.id != id).toList(),
    );
  }

  HazardReport? upcoming({
    required double lat,
    required double lon,
    double? heading,
  }) {
    HazardReport? best;
    double bestD = 1200;
    for (final r in state.reports) {
      final d = r.distanceMeters ??
          haversineMeters(lat, lon, r.lat, r.lon);
      if (d > bestD) continue;
      if (r.hiddenByVotes || r.isExpired) continue;
      if (heading != null &&
          heading >= 0 &&
          !isAheadOfHeading(
            lat: lat,
            lon: lon,
            heading: heading,
            targetLat: r.lat,
            targetLon: r.lon,
          )) {
        continue;
      }
      best = r;
      bestD = d;
    }
    return best;
  }

  Future<HazardReport?> submit({
    required HazardType type,
    required double lat,
    required double lon,
    double? heading,
    String? note,
  }) async {
    state = state.copyWith(sending: true, clearError: true);
    try {
      final report = await _service.report(
        type: type,
        lat: lat,
        lon: lon,
        heading: heading,
        note: note,
        token: _token,
        deviceId: _deviceId,
      );
      _seenIds.add(report.id);
      if (!mounted) return report;
      final reports = [report, ...state.reports.where((r) => r.id != report.id)];
      state = state.copyWith(sending: false, reports: reports);
      unawaited(refresh());
      return report;
    } catch (e) {
      if (!mounted) return null;
      state = state.copyWith(sending: false, error: e.toString());
      return null;
    }
  }

  Future<void> vote(String id, String vote) async {
    try {
      final updated = await _service.vote(
        id: id,
        vote: vote,
        token: _token,
        deviceId: _deviceId,
      );
      if (!mounted) return;
      final gone = updated.hiddenByVotes || updated.isExpired;
      state = state.copyWith(
        reports: [
          for (final r in state.reports)
            if (r.id != id) r else if (!gone) updated,
        ],
        incoming: [
          for (final r in state.incoming)
            if (!(gone && r.id == id)) r,
        ],
        cameras: [
          for (final c in state.cameras)
            if (!(gone && (c.reportId == id || c.id == 'c-$id'))) c,
        ],
      );
    } catch (_) {}
  }

  Future<List<HazardComment>> comments(String id) {
    return _service.comments(id: id, token: _token, deviceId: _deviceId);
  }

  Future<HazardComment?> addComment(String id, String text) async {
    try {
      return await _service.addComment(
        id: id,
        text: text,
        token: _token,
        deviceId: _deviceId,
      );
    } catch (_) {
      return null;
    }
  }

  String _newDeviceId() {
    final r = Random();
    const hex = '0123456789abcdef';
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final s = bytes.map((b) => '${hex[b >> 4]}${hex[b & 0x0f]}').join();
    return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-'
        '${s.substring(16, 20)}-${s.substring(20)}';
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}
