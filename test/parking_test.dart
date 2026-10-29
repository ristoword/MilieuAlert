import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/services/parking_launcher.dart';

void main() {
  test('parking prompt appears only near the destination while driving', () {
    expect(
      shouldPromptParking(navigating: true, isCar: true, remainingMeters: 200),
      isTrue,
    );
    expect(
      shouldPromptParking(
        navigating: true,
        isCar: true,
        remainingMeters: kParkingPromptMeters,
      ),
      isTrue,
    );
    expect(
      shouldPromptParking(navigating: true, isCar: true, remainingMeters: 2000),
      isFalse,
    );
    expect(
      shouldPromptParking(navigating: false, isCar: true, remainingMeters: 100),
      isFalse,
    );
    expect(
      shouldPromptParking(navigating: true, isCar: false, remainingMeters: 100),
      isFalse,
    );
    expect(
      shouldPromptParking(navigating: true, isCar: true, remainingMeters: null),
      isFalse,
    );
  });

  test('EasyPark links point to the official app and site', () {
    expect(kEasyParkPlayUrl, contains('id=net.easypark.android'));
    expect(Uri.parse(kEasyParkWebUrl).host, 'easypark.com');
  });
}
