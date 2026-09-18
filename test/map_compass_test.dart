import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/screens/map/widgets/map_compass.dart';

void main() {
  test('wind rose counter-rotates so N stays on true north', () {
    expect(windRoseAngleRad(0), 0);
    expect(windRoseAngleRad(90), closeTo(-90 * 3.141592653589793 / 180, 1e-9));
    expect(windRoseAngleRad(-45), closeTo(45 * 3.141592653589793 / 180, 1e-9));
  });

  test('wind rose painter repaints when heading-up changes', () {
    final on = WindRosePainter(headingUp: true);
    final off = WindRosePainter(headingUp: false);
    expect(on.shouldRepaint(off), isTrue);
    expect(on.shouldRepaint(WindRosePainter(headingUp: true)), isFalse);
  });

  test('north-up peek is brief then course-up resumes', () {
    expect(kNorthUpPeekDuration, const Duration(seconds: 6));
    expect(kWindRoseSize, inInclusiveRange(48, 56));
  });

  testWidgets('stella dei venti is a 52px CustomPaint control', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapCompassButton(
            controller: MapController(),
            headingUp: true,
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    final size = tester.getSize(find.byKey(const ValueKey('map-wind-rose')));
    expect(size.width, kWindRoseSize);
    expect(size.height, kWindRoseSize);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
