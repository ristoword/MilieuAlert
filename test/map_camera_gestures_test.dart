import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/screens/map/map_screen.dart';

void main() {
  test('GPS and controller camera moves are not treated as user pans', () {
    expect(isUserMapCameraGesture(MapEventSource.mapController), isFalse);
    expect(isUserMapCameraGesture(MapEventSource.fitCamera), isFalse);
    expect(isUserMapCameraGesture(MapEventSource.nonRotatedSizeChange), isFalse);
    expect(isUserMapCameraGesture(MapEventSource.scrollWheel), isFalse);
  });

  test('pan and two-finger rotate pause heading-up follow', () {
    expect(isUserMapCameraGesture(MapEventSource.onDrag), isTrue);
    expect(isUserMapCameraGesture(MapEventSource.dragEnd), isTrue);
    expect(isUserMapCameraGesture(MapEventSource.onMultiFinger), isTrue);
    expect(isUserMapCameraGesture(MapEventSource.cursorKeyboardRotation), isTrue);
    expect(isUserMapCameraGesture(MapEventSource.flingAnimationController), isTrue);
  });
}
