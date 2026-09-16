import 'dart:js_interop';

@JS('milieuWakeLockAcquire')
external JSPromise<JSBoolean> _acquire();

@JS('milieuWakeLockRelease')
external JSPromise<JSAny?> _release();

Future<bool> acquireScreenWakeLockImpl() async {
  try {
    final result = await _acquire().toDart;
    return result.toDart;
  } catch (_) {
    return false;
  }
}

Future<void> releaseScreenWakeLockImpl() async {
  try {
    await _release().toDart;
  } catch (_) {}
}
