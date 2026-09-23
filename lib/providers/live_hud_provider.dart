import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/zone_status.dart';
import '../services/geo_utils.dart';
import '../services/navigation_guidance.dart';
import 'location_provider.dart';
import 'navigation_provider.dart';

/// Live turn-by-turn + GPS sample. Ticks from interpolated fixes so the
/// HUD can rebuild without MapScreen / FlutterMap.
class LiveHudSnapshot {
  final LiveGpsFix? fix;
  final LiveNavInfo? live;
  final bool follow;
  final ZoneProximity? nearestZone;

  const LiveHudSnapshot({
    this.fix,
    this.live,
    this.follow = true,
    this.nearestZone,
  });

  static const empty = LiveHudSnapshot();
}

class LiveHudController extends ChangeNotifier {
  LiveHudController(this._ref) {
    _fix = _ref.read(locationProvider.notifier).liveFix;
    _fix.addListener(_onFix);
    _ref.listen<NavigationState>(navigationProvider, (_, __) => _onFix());
    _tick = Timer.periodic(const Duration(milliseconds: 120), (_) => _onTick());
    _onFix();
  }

  final Ref _ref;
  late final ValueNotifier<LiveGpsFix?> _fix;
  Timer? _tick;
  LiveHudSnapshot snapshot = LiveHudSnapshot.empty;

  DateTime? _snapAt;
  LiveNavInfo? _snapLive;
  double? _snapMeters;
  double? _snapRemaining;
  double? _snapSeconds;

  void _onFix() {
    final fix = _fix.value;
    final loc = _ref.read(locationProvider);
    LiveNavInfo? live;
    if (fix != null) {
      live = _ref.read(navigationProvider.notifier).liveInfo(
            fix.lat,
            fix.lon,
            heading: fix.heading,
            accuracy: fix.accuracy,
            speedMps: fix.speedMps,
          );
      if (fix.snapped) {
        _snapAt = fix.at;
        _snapLive = live;
        _snapMeters = live.metersToManeuver;
        _snapRemaining = live.remainingMeters;
        _snapSeconds = live.remainingSeconds;
      }
    }
    _publish(fix, live, loc);
  }

  void _onTick() {
    final snapLive = _snapLive;
    final snapAt = _snapAt;
    final fix = _fix.value;
    if (snapLive == null || snapAt == null || fix == null) return;
    if (snapLive.offRoute) return;
    final dt = DateTime.now().difference(snapAt).inMilliseconds / 1000.0;
    if (dt < 0.2 || dt > 3.0) return;
    final speed = fix.speedMps ?? 0;
    if (speed < 0.4) return;
    final decay = speed * dt;
    final predictedMeters = max(0.0, (_snapMeters ?? 0) - decay);
    final current = snapshot.live;
    if (current != null &&
        current.stepIndex == snapLive.stepIndex &&
        current.metersToManeuver <= predictedMeters + 0.8) {
      return;
    }
    final live = snapLive.copyWith(
      metersToManeuver: predictedMeters,
      remainingMeters: max(0.0, (_snapRemaining ?? 0) - decay),
      remainingSeconds: max(0.0, (_snapSeconds ?? 0) - dt),
      speedKmh: gpsSpeedKmh(speed),
    );
    _publish(fix, live, _ref.read(locationProvider));
  }

  void _publish(LiveGpsFix? fix, LiveNavInfo? live, LocationState loc) {
    final prev = snapshot.live;
    final prevFix = snapshot.fix;
    var fixMoved = false;
    if (fix != null && prevFix != null) {
      fixMoved = haversineMeters(
            prevFix.lat,
            prevFix.lon,
            fix.lat,
            fix.lon,
          ) >=
          0.35;
      if (!fixMoved &&
          fix.heading != null &&
          prevFix.heading != null &&
          headingDelta(fix.heading!, prevFix.heading!) >= 1.2) {
        fixMoved = true;
      }
    } else if (fix != null && prevFix == null) {
      fixMoved = true;
    }
    final same = prev != null &&
        live != null &&
        prev.stepIndex == live.stepIndex &&
        prev.speedKmh == live.speedKmh &&
        prev.currentStep?.type == live.currentStep?.type &&
        (prev.metersToManeuver - live.metersToManeuver).abs() < 1 &&
        snapshot.follow == loc.follow;
    if (same && !fixMoved) return;
    snapshot = LiveHudSnapshot(
      fix: fix,
      live: live,
      follow: loc.follow,
      nearestZone: loc.nearestZone,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _fix.removeListener(_onFix);
    super.dispose();
  }
}

final liveHudProvider = ChangeNotifierProvider<LiveHudController>((ref) {
  return LiveHudController(ref);
});
