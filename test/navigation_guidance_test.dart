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

  test('lateral 25m with matching heading stays on-route', () {
    final mPerDegLon = mPerDeg * 0.6157;
    final beside = computeGuidance(
      lat: startLat + 200 / mPerDeg,
      lon: lon + 25 / mPerDegLon,
      heading: 0,
      route: route,
      steps: steps,
    );
    expect(beside.offRouteMeters, lessThan(40));
    expect(beside.offRoute, isFalse);
  });

  test('fires off-route near 50m beside the polyline', () {
    final mPerDegLon = mPerDeg * 0.6157;
    final off = computeGuidance(
      lat: startLat + 200 / mPerDeg,
      lon: lon + 55 / mPerDegLon,
      heading: 0,
      route: route,
      steps: steps,
    );
    expect(off.offRouteMeters, greaterThan(50));
    expect(off.offRoute, isTrue);
  });

  test('heading >50° off plus ~30m offset is off-route', () {
    final mPerDegLon = mPerDeg * 0.6157;
    final off = computeGuidance(
      lat: startLat + 200 / mPerDeg,
      lon: lon + 30 / mPerDegLon,
      heading: 90,
      route: route,
      steps: steps,
    );
    expect(off.headingDiverged, isTrue);
    expect(off.offRouteMeters, greaterThan(28));
    expect(off.offRoute, isTrue);
  });

  test('heading off plus growing offset fires before 50m', () {
    final mPerDegLon = mPerDeg * 0.6157;
    final growing = computeGuidance(
      lat: startLat + 200 / mPerDeg,
      lon: lon + 16 / mPerDegLon,
      heading: 90,
      route: route,
      steps: steps,
      previousOffset: 10,
    );
    expect(growing.headingDiverged, isTrue);
    expect(growing.offRouteMeters, lessThan(50));
    expect(growing.offRoute, isTrue);
  });

  test('going straight past a right turn flags off-route within ~40m', () {
    final mPerDegLon = mPerDeg * 0.6157;
    final cornerLat = startLat + 500 / mPerDeg;
    final bent = [
      LatLng(startLat, lon),
      LatLng(cornerLat, lon),
      LatLng(cornerLat, lon + 400 / mPerDegLon),
    ];
    final turnSteps = [
      NavStep(
        type: 'depart',
        modifier: '',
        name: '',
        distanceMeters: 500,
        lat: startLat,
        lon: lon,
      ),
      NavStep(
        type: 'turn',
        modifier: 'right',
        name: 'Via Roma',
        distanceMeters: 400,
        lat: cornerLat,
        lon: lon,
      ),
      NavStep(
        type: 'arrive',
        modifier: '',
        name: 'Destinazione',
        distanceMeters: 0,
        lat: cornerLat,
        lon: lon + 400 / mPerDegLon,
      ),
    ];
    final missed = computeGuidance(
      lat: cornerLat + 40 / mPerDeg,
      lon: lon,
      heading: 0,
      route: bent,
      steps: turnSteps,
    );
    expect(missed.offRouteMeters, lessThan(90));
    expect(missed.offRoute, isTrue);

    final onOutgoing = computeGuidance(
      lat: cornerLat,
      lon: lon + 40 / mPerDegLon,
      heading: 90,
      route: bent,
      steps: turnSteps,
    );
    expect(onOutgoing.offRoute, isFalse);
  });

  test('snap behind a passed maneuver is off-route', () {
    final mPerDegLon = mPerDeg * 0.6157;
    final cornerLat = startLat + 500 / mPerDeg;
    final bent = [
      LatLng(startLat, lon),
      LatLng(cornerLat, lon),
      LatLng(cornerLat, lon + 400 / mPerDegLon),
    ];
    final turnSteps = [
      NavStep(
        type: 'depart',
        modifier: '',
        name: '',
        distanceMeters: 500,
        lat: startLat,
        lon: lon,
      ),
      NavStep(
        type: 'turn',
        modifier: 'right',
        name: 'Via Roma',
        distanceMeters: 400,
        lat: cornerLat,
        lon: lon,
      ),
      NavStep(
        type: 'arrive',
        modifier: '',
        name: 'Destinazione',
        distanceMeters: 0,
        lat: cornerLat,
        lon: lon + 400 / mPerDegLon,
      ),
    ];
    final behind = computeGuidance(
      lat: startLat + 200 / mPerDeg,
      lon: lon,
      heading: 0,
      route: bent,
      steps: turnSteps,
      progressAlong: 530,
    );
    expect(behind.offRoute, isTrue);
  });

  test('noisy accuracy does not block off-route but blocks false arrival', () {
    expect(
      shouldAnnounceArrival(offRoute: false, crowToTarget: 25, accuracy: 20),
      isTrue,
    );
    expect(
      shouldAnnounceArrival(offRoute: false, crowToTarget: 60, accuracy: 65),
      isFalse,
    );
    expect(
      shouldAnnounceArrival(offRoute: true, crowToTarget: 20, accuracy: 15),
      isFalse,
    );
  });

  test('does not treat a missed turn near the destination as arrival', () {
    final end = route.last;
    final besideEnd = computeGuidance(
      lat: end.latitude,
      lon: lon + 0.003,
      route: route,
      steps: steps,
    );
    expect(besideEnd.offRoute, isTrue);
    final crow = haversineMeters(end.latitude, lon + 0.003, end.latitude, lon);
    expect(crow, greaterThan(80));
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

  test('course-up bearing follows the polyline segment ahead of the puck', () {
    expect(
      courseUpBearing(lat: startLat, lon: lon, route: route),
      closeTo(0, 6),
    );

    final northEnd = startLat + 200 / mPerDeg;
    final eastLon = lon + 200 / (mPerDeg * 0.615);
    final bent = [
      LatLng(startLat, lon),
      LatLng(northEnd, lon),
      LatLng(northEnd, eastLon),
    ];
    expect(
      courseUpBearing(lat: startLat + 40 / mPerDeg, lon: lon, route: bent),
      closeTo(0, 8),
    );
    expect(
      courseUpBearing(lat: northEnd, lon: lon + 0.0004, route: bent),
      closeTo(90, 15),
    );
    expect(
      courseUpBearing(
        lat: startLat,
        lon: lon + 0.02,
        gpsHeading: 180,
        speedMps: 3,
        route: bent,
      ),
      closeTo(180, 1),
    );
    expect(
      courseUpBearing(
        lat: startLat + 40 / mPerDeg,
        lon: lon,
        gpsHeading: 270,
        speedMps: 0,
        route: bent,
      ),
      closeTo(0, 8),
    );
    expect(
      courseUpBearing(
        lat: startLat,
        lon: lon,
        gpsHeading: 270,
        route: const [],
      ),
      270,
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
