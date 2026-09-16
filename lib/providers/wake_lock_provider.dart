import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/wake_lock.dart';
import 'location_provider.dart';
import 'navigation_provider.dart';

/// Keeps the phone screen awake while navigating or walking with follow-on.
final screenWakeLockProvider = Provider<void>((ref) {
  var held = false;
  var disposed = false;
  Timer? retry;

  Future<void> sync() async {
    if (disposed) return;
    final nav = ref.read(navigationProvider);
    final loc = ref.read(locationProvider);
    final want = nav.navigating || (loc.follow && loc.tracking);
    if (want) {
      if (held) return;
      final ok = await acquireScreenWakeLock();
      if (disposed) return;
      held = ok;
      retry?.cancel();
      if (!ok) {
        retry = Timer(const Duration(seconds: 8), sync);
      }
      return;
    }
    retry?.cancel();
    retry = null;
    if (!held) return;
    held = false;
    await releaseScreenWakeLock();
  }

  ref.listen<NavigationState>(navigationProvider, (_, __) {
    sync();
  });
  ref.listen<LocationState>(locationProvider, (_, __) {
    sync();
  });
  ref.onDispose(() {
    disposed = true;
    retry?.cancel();
    held = false;
    releaseScreenWakeLock();
  });
  sync();
});
