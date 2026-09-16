import 'wake_lock_stub.dart'
    if (dart.library.js_interop) 'wake_lock_web.dart' as impl;

Future<void> acquireScreenWakeLock() => impl.acquireScreenWakeLockImpl();

Future<void> releaseScreenWakeLock() => impl.releaseScreenWakeLockImpl();
