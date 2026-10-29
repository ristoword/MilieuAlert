import 'package:url_launcher/url_launcher.dart';

/// EasyPark app on Google Play. The store page shows "Open" when it is
/// already installed, otherwise "Install". MilieuAlert never handles the
/// parking payment itself: the user pays inside the official EasyPark app.
const String kEasyParkPlayUrl =
    'https://play.google.com/store/apps/details?id=net.easypark.android';

/// Web fallback for devices without Google Play.
const String kEasyParkWebUrl = 'https://easypark.com';

/// Drivers are prompted to pay for parking within this distance of arrival.
const double kParkingPromptMeters = 350;

bool shouldPromptParking({
  required bool navigating,
  required bool isCar,
  required double? remainingMeters,
}) {
  if (!navigating || !isCar || remainingMeters == null) return false;
  return remainingMeters <= kParkingPromptMeters;
}

/// Opens EasyPark. Returns false when neither link could be launched.
Future<bool> openEasyPark() async {
  for (final url in [kEasyParkPlayUrl, kEasyParkWebUrl]) {
    try {
      if (await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        return true;
      }
    } catch (_) {}
  }
  return false;
}
