import 'pwa_install.dart';

Future<PwaInstallResult> promptPwaInstallImpl() async {
  return PwaInstallResult.unavailable;
}

bool pwaIsStandaloneImpl() => false;

void downloadPwaShortcutImpl() {}

void downloadPwaLauncherImpl() {}
