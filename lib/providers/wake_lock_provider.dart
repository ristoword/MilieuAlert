import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/wake_lock.dart';
import 'location_provider.dart';
import 'navigation_provider.dart';

/// Keeps the phone screen awake while navigating or walking with follow-on.
final screenWakeLockProvider = Provider<void>((ref) {
  var held = false;

  Future<void> sync() async {
    final nav = ref.read(navigationProvider);
    final loc = ref.read(locationProvider);
    final want = nav.navigating || (loc.follow && loc.tracking);
    if (want == held) return;
    held = want;
    if (want) {
      await acquireScreenWakeLock();
    } else {
      await releaseScreenWakeLock();
    }
  }

  ref.listen<NavigationState>(navigationProvider, (_, __) {
    sync();
  });
  ref.listen<LocationState>(locationProvider, (_, __) {
    sync();
  });
  ref.onDispose(() {
    held = false;
    releaseScreenWakeLock();
  });
  sync();
});
