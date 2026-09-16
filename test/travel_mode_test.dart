import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/models/navigation_models.dart';

void main() {
  test('travel mode defaults to car', () {
    expect(parseTravelMode(null), TravelMode.car);
    expect(parseTravelMode('auto'), TravelMode.car);
    expect(parseTravelMode('foot'), TravelMode.foot);
    expect(parseTravelMode('transit'), TravelMode.transit);
    expect(TravelMode.car.apiValue, 'car');
  });

  test('walk HUD says Cammina verso fermata', () {
    const step = NavStep(
      type: 'walk',
      modifier: '',
      name: 'Dam',
      distanceMeters: 220,
    );
    expect(step.walkActionIt, 'Cammina verso fermata Dam');
    expect(step.maneuverIt, 'Cammina verso fermata Dam');
  });

  test('tram HUD says line and headsign, then alight stop', () {
    const step = NavStep(
      type: 'tram',
      modifier: 'Nachtwachtlaan',
      name: '9',
      distanceMeters: 2100,
      fromStop: 'Dam',
      alightStop: 'Leidseplein',
    );
    expect(step.transitActionIt, 'Tram 9 direzione Nachtwachtlaan');
    expect(step.alightActionIt, 'Scendi a Leidseplein');
    expect(step.hudSubtitle(), 'Scendi a Leidseplein');
    expect(step.hudSubtitle(metersToManeuver: 40), 'Scendi a Leidseplein');
  });

  test('TransitLeg Apple-style board / alight copy', () {
    const walk = TransitLeg(
      kind: 'walk',
      mode: 'WALK',
      toStop: 'Dam',
      distanceMeters: 180,
    );
    const tram = TransitLeg(
      kind: 'transit',
      mode: 'TRAM',
      line: '9',
      headsign: 'Nachtwachtlaan',
      fromStop: 'Dam',
      toStop: 'Leidseplein',
    );
    expect(walk.actionIt, 'Cammina verso fermata Dam');
    expect(tram.actionIt, 'Tram 9 direzione Nachtwachtlaan');
    expect(tram.boardIt, contains('Sali a Dam'));
    expect(tram.alightIt, 'Scendi a Leidseplein');
  });

  test('RoutePlan keeps car as default and parses transit itinerary', () {
    final car = RoutePlan.fromJson({
      'points': [
        {'lon': 4.89, 'lat': 52.37},
        {'lon': 4.90, 'lat': 52.38},
      ],
      'steps': [],
      'speeds': [30],
      'distanceMeters': 100,
      'durationSeconds': 20,
    });
    expect(car.mode, TravelMode.car);

    final transit = RoutePlan.fromJson({
      'mode': 'transit',
      'points': [
        {'lon': 4.89, 'lat': 52.37},
        {'lon': 4.88, 'lat': 52.36},
      ],
      'steps': [
        {
          'type': 'tram',
          'modifier': 'Nachtwachtlaan',
          'name': '9',
          'distanceMeters': 900,
          'alightStop': 'Leidseplein',
        },
      ],
      'speeds': [],
      'distanceMeters': 900,
      'durationSeconds': 480,
      'itinerary': {
        'transfers': 0,
        'legs': [
          {
            'kind': 'transit',
            'mode': 'TRAM',
            'line': '9',
            'headsign': 'Nachtwachtlaan',
            'fromStop': 'Dam',
            'toStop': 'Leidseplein',
          },
        ],
      },
    });
    expect(transit.mode, TravelMode.transit);
    expect(transit.itinerary?.legs.single.actionIt,
        'Tram 9 direzione Nachtwachtlaan');
  });
}
