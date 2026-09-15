import 'dart:js_interop';

import 'pwa_install.dart';

@JS('milieuPwaCanInstall')
external bool _canInstall();

@JS('milieuPwaIsStandalone')
external bool _isStandalone();

@JS('milieuPwaPromptInstall')
external JSPromise<JSString> _promptInstall();

@JS('milieuPwaDownloadShortcut')
external void _downloadShortcut();

@JS('milieuPwaDownloadLauncher')
external void _downloadLauncher();

Future<PwaInstallResult> promptPwaInstallImpl() async {
  try {
    if (!_canInstall()) return PwaInstallResult.unavailable;
    final outcome = (await _promptInstall().toDart).toDart;
    if (outcome == 'accepted') return PwaInstallResult.accepted;
    return PwaInstallResult.dismissed;
  } catch (_) {
    return PwaInstallResult.unavailable;
  }
}

bool pwaIsStandaloneImpl() {
  try {
    return _isStandalone();
  } catch (_) {
    return false;
  }
}

void downloadPwaShortcutImpl() {
  try {
    _downloadShortcut();
  } catch (_) {}
}

void downloadPwaLauncherImpl() {
  try {
    _downloadLauncher();
  } catch (_) {}
}
