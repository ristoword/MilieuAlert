import 'dart:js_interop';

@JS('milieuWakeLockAcquire')
external JSPromise<JSBoolean> _acquire();

@JS('milieuWakeLockRelease')
external JSPromise<JSAny?> _release();

Future<void> acquireScreenWakeLockImpl() async {
  try {
    await _acquire().toDart;
  } catch (_) {}
}

Future<void> releaseScreenWakeLockImpl() async {
  try {
    await _release().toDart;
  } catch (_) {}
}
