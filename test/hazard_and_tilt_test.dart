import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/models/hazard_report.dart';
import 'package:milieu_alert/screens/map/widgets/driver_map_frame.dart';

void main() {
  group('HazardReport', () {
    test('parses community payload without identity fields', () {
      final report = HazardReport.fromJson({
        'id': 'abc',
        'type': 'camera_mobile',
        'lat': 45.46,
        'lon': 9.19,
        'note': 'dietro il cartello',
        'createdAt': '2026-01-01T10:00:00.000Z',
        'expiresAt': '2026-01-01T12:00:00.000Z',
        'confirmCount': 2,
        'denyCount': 0,
        'author': 'un conducente',
        'source': 'community',
        'distanceMeters': 400,
      });
      expect(report.type, HazardType.cameraMobile);
      expect(report.type.isCamera, isTrue);
      expect(report.author, 'un conducente');
      expect(report.source, 'community');
      expect(report.distanceMeters, 400);
    });
  });

  test('driver tilt matrix uses perspective', () {
    final m = driverTiltMatrix();
    expect(m.storage[11] != 0, isTrue);
    expect(m.storage[0] > 1, isTrue);
  });
}
