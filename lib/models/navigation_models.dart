class PlaceHit {
  final String label;
  final double lat;
  final double lon;

  const PlaceHit({
    required this.label,
    required this.lat,
    required this.lon,
  });

  factory PlaceHit.fromJson(Map<String, dynamic> json) {
    return PlaceHit(
      label: json['label']?.toString() ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}

class SpeedCamera {
  final String id;
  final double lat;
  final double lon;
  final String? maxspeed;

  const SpeedCamera({
    required this.id,
    required this.lat,
    required this.lon,
    this.maxspeed,
  });

  factory SpeedCamera.fromJson(Map<String, dynamic> json) {
    return SpeedCamera(
      id: json['id']?.toString() ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      maxspeed: json['maxspeed']?.toString(),
    );
  }
}

class SpeedLimitPoint {
  final double lat;
  final double lon;
  final int maxspeed;

  const SpeedLimitPoint({
    required this.lat,
    required this.lon,
    required this.maxspeed,
  });

  factory SpeedLimitPoint.fromJson(Map<String, dynamic> json) {
    return SpeedLimitPoint(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      maxspeed: (json['maxspeed'] as num).toInt(),
    );
  }
}

class NavStep {
  final String type;
  final String modifier;
  final String name;
  final double distanceMeters;
  final double? lat;
  final double? lon;

  const NavStep({
    required this.type,
    required this.modifier,
    required this.name,
    required this.distanceMeters,
    this.lat,
    this.lon,
  });

  factory NavStep.fromJson(Map<String, dynamic> json) {
    return NavStep(
      type: json['type']?.toString() ?? 'continue',
      modifier: json['modifier']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
    );
  }

  String get instructionIt {
    final road = name.trim().isEmpty ? '' : ' su $name';
    switch (type) {
      case 'depart':
        return 'Partenza$road';
      case 'arrive':
        return 'Sei arrivato';
      case 'roundabout':
      case 'rotary':
        return 'Immettersi in rotonda$road';
      case 'merge':
        return 'Immettersi$road';
      case 'fork':
        return modifier.contains('left')
            ? 'Tenersi a sinistra$road'
            : 'Tenersi a destra$road';
      case 'on ramp':
        return 'Prendere la rampa$road';
      case 'off ramp':
      case 'exit':
        return 'Uscire$road';
      case 'turn':
        if (modifier.contains('sharp left')) return 'Svolta secca a sinistra$road';
        if (modifier.contains('sharp right')) return 'Svolta secca a destra$road';
        if (modifier.contains('slight left')) return 'Tieni la sinistra$road';
        if (modifier.contains('slight right')) return 'Tieni la destra$road';
        if (modifier.contains('left')) return 'Gira a sinistra$road';
        if (modifier.contains('right')) return 'Gira a destra$road';
        if (modifier.contains('uturn')) return 'Inverti marcia$road';
        return 'Svolta$road';
      case 'new name':
      case 'continue':
      default:
        return name.trim().isEmpty ? 'Prosegui dritto' : 'Prosegui su $name';
    }
  }
}

class RoutePlan {
  final List<List<double>> points;
  final List<NavStep> steps;
  final List<double> speeds;
  final double distanceMeters;
  final double durationSeconds;

  const RoutePlan({
    required this.points,
    required this.steps,
    required this.speeds,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  factory RoutePlan.fromJson(Map<String, dynamic> data) {
    final points = ((data['points'] as List?) ?? const [])
        .map((p) {
          final m = Map<String, dynamic>.from(p as Map);
          return <double>[
            (m['lon'] as num).toDouble(),
            (m['lat'] as num).toDouble(),
          ];
        })
        .toList();
    final steps = ((data['steps'] as List?) ?? const [])
        .map((s) => NavStep.fromJson(Map<String, dynamic>.from(s as Map)))
        .toList();
    final speeds = ((data['speeds'] as List?) ?? const [])
        .map((n) => (n as num).toDouble())
        .toList();
    return RoutePlan(
      points: points,
      steps: steps,
      speeds: speeds,
      distanceMeters: (data['distanceMeters'] as num?)?.toDouble() ?? 0,
      durationSeconds: (data['durationSeconds'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RouteBundle {
  final List<RoutePlan> alternatives;

  const RouteBundle({required this.alternatives});

  RoutePlan? get primary => alternatives.isEmpty ? null : alternatives.first;
}

class HazardSet {
  final List<SpeedCamera> cameras;
  final List<SpeedLimitPoint> limits;

  const HazardSet({required this.cameras, required this.limits});
}

enum RouteAlertKind {
  delay,
  faster,
  detour,
  newCamera,
  newZone,
  zoneActivating,
  zoneExpiring,
}

class RouteChangeAlert {
  final String id;
  final RouteAlertKind kind;
  final String title;
  final String message;
  final DateTime at;
  final bool critical;

  const RouteChangeAlert({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.at,
    this.critical = false,
  });
}
