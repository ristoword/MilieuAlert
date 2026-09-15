import 'pwa_install_stub.dart'
    if (dart.library.js_interop) 'pwa_install_web.dart';

enum PwaInstallResult { accepted, dismissed, unavailable }

Future<PwaInstallResult> promptPwaInstall() => promptPwaInstallImpl();

bool pwaIsStandalone() => pwaIsStandaloneImpl();

void downloadPwaShortcut() => downloadPwaShortcutImpl();

void downloadPwaLauncher() => downloadPwaLauncherImpl();
