import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:milieu_alert/models/navigation_models.dart';
import 'package:milieu_alert/services/geo_utils.dart';
import 'package:milieu_alert/services/navigation_guidance.dart';

List<LatLng> _northLine({int segments = 20, double stepMeters = 50}) {
  const startLat = 52.0;
  const lon = 4.32;
  const mPerDeg = 111320.0;
  return [
    for (var i = 0; i <= segments; i++)
      LatLng(startLat + (i * stepMeters) / mPerDeg, lon),
  ];
}

void main() {
  const lon = 4.32;
  const startLat = 52.0;
  const mPerDeg = 111320.0;

  final route = _northLine();
  final turnLat = startLat + 457 / mPerDeg;
  final end = route.last;
  final steps = [
    NavStep(
      type: 'depart',
      modifier: '',
      name: '',
      distanceMeters: 457,
      lat: startLat,
      lon: lon,
    ),
    NavStep(
      type: 'turn',
      modifier: 'right',
      name: 'Via Roma',
      distanceMeters: 400,
      lat: turnLat,
      lon: lon,
    ),
    NavStep(
      type: 'arrive',
      modifier: '',
      name: 'Destinazione',
      distanceMeters: 143,
      lat: end.latitude,
      lon: lon,
    ),
  ];

  test('meters to the next turn tick down along the polyline', () {
    final start = computeGuidance(
      lat: startLat,
      lon: lon,
      route: route,
      steps: steps,
    );
    expect(start.currentStep?.type, 'turn');
    expect(start.metersToManeuver, closeTo(457, 25));

    final midLat = startLat + 100 / mPerDeg;
    final mid = computeGuidance(
      lat: midLat,
      lon: lon,
      route: route,
      steps: steps,
    );
    expect(mid.currentStep?.type, 'turn');
    expect(mid.metersToManeuver, lessThan(start.metersToManeuver - 70));
    expect(mid.metersToManeuver, closeTo(357, 25));
  });

  test('advances to the next step after passing the maneuver', () {
    final pastLat = startLat + (457 + 40) / mPerDeg;
    final past = computeGuidance(
      lat: pastLat,
      lon: lon,
      route: route,
      steps: steps,
    );
    expect(past.currentStep?.type, 'arrive');
    expect(past.metersToManeuver, lessThan(520));
  });

  test('flags off-route when GPS is ~100m beside the polyline', () {
    final onRoute = computeGuidance(
      lat: startLat + 200 / mPerDeg,
      lon: lon,
      route: route,
      steps: steps,
    );
    expect(onRoute.offRoute, isFalse);

    final off = computeGuidance(
      lat: startLat + 200 / mPerDeg,
      lon: lon + 0.002,
      route: route,
      steps: steps,
    );
    expect(off.offRouteMeters, greaterThan(80));
    expect(off.offRoute, isTrue);
  });

  test('parses real OSRM lanes and never invents extras', () {
    final step = NavStep.fromJson({
      'type': 'continue',
      'modifier': '',
      'name': 'A4',
      'distanceMeters': 320,
      'lanes': [
        {'indications': ['straight'], 'valid': true},
        {'indications': ['straight'], 'valid': true},
        {
          'indications': ['straight', 'slight right'],
          'valid': false,
        },
        {'indications': ['slight right'], 'valid': false},
      ],
    });
    expect(step.lanes, hasLength(4));
    expect(step.lanes.where((l) => l.valid), hasLength(2));
    expect(step.isManeuver, isTrue);
    expect(step.laneKeepPhrase, 'Tieni la sinistra');

    final empty = NavStep.fromJson({
      'type': 'turn',
      'modifier': 'right',
      'name': 'Via',
      'distanceMeters': 80,
    });
    expect(empty.lanes, isEmpty);
    expect(empty.isManeuver, isTrue);
  });

  test('uses the last OSM maxspeed passed on the polyline', () {
    final cum = cumulativeDistances(route);
    final limits = [
      SpeedLimitPoint(lat: startLat, lon: lon, maxspeed: 50),
      SpeedLimitPoint(
        lat: startLat + 400 / mPerDeg,
        lon: lon,
        maxspeed: 70,
      ),
    ];
    final at200 = currentSpeedLimitKmh(
      alongMeters: 200,
      route: route,
      cum: cum,
      limits: limits,
    );
    expect(at200, 50);
    final at430 = currentSpeedLimitKmh(
      alongMeters: 430,
      route: route,
      cum: cum,
      limits: limits,
    );
    expect(at430, 70);
  });

  test('gpsSpeedKmh converts m/s and ignores invalid fixes', () {
    expect(gpsSpeedKmh(13.9), 50);
    expect(gpsSpeedKmh(0), 0);
    expect(gpsSpeedKmh(-1), isNull);
    expect(gpsSpeedKmh(null), isNull);
  });

  test('resolveTravelSpeedMps uses displacement when GPS reports 0', () {
    final now = DateTime.utc(2026, 1, 1, 12, 0, 2);
    final prev = DateTime.utc(2026, 1, 1, 12, 0, 0);
    final lat = startLat + 28 / mPerDeg;
    final speed = resolveTravelSpeedMps(
      reported: 0,
      previousLat: startLat,
      previousLon: lon,
      previousAt: prev,
      lat: lat,
      lon: lon,
      at: now,
    );
    expect(speed, closeTo(14, 1.5));
  });

  test('destinationPoint moves about 100m north', () {
    final dest = destinationPoint(startLat, lon, 0, 100);
    expect(
      haversineMeters(startLat, lon, dest.lat, dest.lon),
      closeTo(100, 2),
    );
  });

  test('OSRM annotation speed is only a legal-limit fallback', () {
    final cum = cumulativeDistances(route);
    final fromOsrm = currentSpeedLimitKmh(
      alongMeters: 100,
      route: route,
      cum: cum,
      limits: const [],
      annotationSpeeds: [13.9],
      segmentIndex: 0,
    );
    expect(fromOsrm, 50);
    final none = currentSpeedLimitKmh(
      alongMeters: 100,
      route: route,
      cum: cum,
      limits: const [],
    );
    expect(none, isNull);
  });
}
