enum TravelMode { car, foot, transit }

TravelMode parseTravelMode(String? raw) {
  switch (raw) {
    case 'foot':
    case 'walk':
    case 'walking':
      return TravelMode.foot;
    case 'transit':
    case 'mezzi':
      return TravelMode.transit;
    default:
      return TravelMode.car;
  }
}

extension TravelModeApi on TravelMode {
  String get apiValue => name;

  bool get isCar => this == TravelMode.car;
  bool get isFoot => this == TravelMode.foot;
  bool get isTransit => this == TravelMode.transit;
}

class PlaceHit {
  final String label;
  final double lat;
  final double lon;
  final String? category;
  final double? distanceMeters;
  final bool inLez;
  final String? zoneName;

  const PlaceHit({
    required this.label,
    required this.lat,
    required this.lon,
    this.category,
    this.distanceMeters,
    this.inLez = false,
    this.zoneName,
  });

  PlaceHit copyWith({
    String? label,
    double? lat,
    double? lon,
    String? category,
    double? distanceMeters,
    bool? inLez,
    String? zoneName,
  }) {
    return PlaceHit(
      label: label ?? this.label,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      category: category ?? this.category,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      inLez: inLez ?? this.inLez,
      zoneName: zoneName ?? this.zoneName,
    );
  }

  factory PlaceHit.fromJson(Map<String, dynamic> json) {
    return PlaceHit(
      label: json['label']?.toString() ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      category: json['category']?.toString(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      inLez: json['inLez'] == true,
      zoneName: json['zoneName']?.toString(),
    );
  }
}

class SpeedCamera {
  final String id;
  final double lat;
  final double lon;
  final String? maxspeed;
  final String source;
  final String? type;
  final String? reportId;

  const SpeedCamera({
    required this.id,
    required this.lat,
    required this.lon,
    this.maxspeed,
    this.source = 'osm',
    this.type,
    this.reportId,
  });

  bool get isCommunity => source == 'community';

  factory SpeedCamera.fromJson(Map<String, dynamic> json) {
    return SpeedCamera(
      id: json['id']?.toString() ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      maxspeed: json['maxspeed']?.toString(),
      source: json['source']?.toString() ?? 'osm',
      type: json['type']?.toString(),
      reportId: json['reportId']?.toString(),
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

class NavLane {
  final List<String> indications;
  final bool valid;

  const NavLane({this.indications = const [], this.valid = false});

  factory NavLane.fromJson(Map<String, dynamic> json) {
    final raw = json['indications'];
    final indications = raw is List
        ? raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : const <String>[];
    return NavLane(
      indications: indications,
      valid: json['valid'] == true,
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
  final List<NavLane> lanes;
  final String? fromStop;
  final String? alightStop;

  const NavStep({
    required this.type,
    required this.modifier,
    required this.name,
    required this.distanceMeters,
    this.lat,
    this.lon,
    this.lanes = const [],
    this.fromStop,
    this.alightStop,
  });

  factory NavStep.fromJson(Map<String, dynamic> json) {
    final rawLanes = json['lanes'];
    return NavStep(
      type: json['type']?.toString() ?? 'continue',
      modifier: json['modifier']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      lanes: rawLanes is List
          ? rawLanes
              .whereType<Map>()
              .map((e) => NavLane.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      fromStop: json['fromStop']?.toString(),
      alightStop: json['alightStop']?.toString(),
    );
  }

  bool get isTransitVehicle {
    switch (type) {
      case 'tram':
      case 'bus':
      case 'subway':
      case 'rail':
      case 'ferry':
      case 'transit':
        return true;
      default:
        return false;
    }
  }

  bool get isWalkAction => type == 'walk';

  /// True for a spoken/HUD turn. Continue/depart keep the previous instruction
  /// unless OSRM attached real lane data (keep-left vs exit).
  bool get isManeuver {
    switch (type) {
      case 'depart':
      case 'continue':
      case 'new name':
      case 'notification':
        return lanes.isNotEmpty;
      default:
        return true;
    }
  }

  String get _transitVehicleIt {
    switch (type) {
      case 'tram':
        return 'Tram';
      case 'bus':
        return 'Bus';
      case 'subway':
        return 'Metro';
      case 'rail':
        return 'Treno';
      case 'ferry':
        return 'Traghetto';
      default:
        return 'Mezzo';
    }
  }

  String get transitActionIt {
    final line = name.trim();
    final vehicle = line.isEmpty ? _transitVehicleIt : '$_transitVehicleIt $line';
    final dir = modifier.trim();
    if (dir.isEmpty) return vehicle;
    return '$vehicle direzione $dir';
  }

  String get walkActionIt {
    final stop = name.trim();
    if (stop.isEmpty) return 'Cammina verso destinazione';
    return 'Cammina verso fermata $stop';
  }

  String get alightActionIt {
    final stop = (alightStop ?? name).trim();
    if (stop.isEmpty) return 'Scendi';
    return 'Scendi a $stop';
  }

  /// Turn action only, so the HUD can show the full street name on its own line.
  String get maneuverIt {
    switch (type) {
      case 'depart':
        return 'Partenza';
      case 'arrive':
        return 'Sei arrivato';
      case 'walk':
        return walkActionIt;
      case 'tram':
      case 'bus':
      case 'subway':
      case 'rail':
      case 'ferry':
      case 'transit':
        return transitActionIt;
      case 'roundabout':
      case 'rotary':
        return 'Immettersi in rotonda';
      case 'merge':
        return 'Immettersi';
      case 'fork':
        return modifier.contains('left')
            ? 'Tenersi a sinistra'
            : 'Tenersi a destra';
      case 'on ramp':
        return 'Prendere la rampa';
      case 'off ramp':
      case 'exit':
        return 'Uscire';
      case 'use lane':
        return laneKeepPhrase;
      case 'turn':
        if (modifier.contains('sharp left')) return 'Svolta secca a sinistra';
        if (modifier.contains('sharp right')) return 'Svolta secca a destra';
        if (modifier.contains('slight left')) return 'Tieni la sinistra';
        if (modifier.contains('slight right')) return 'Tieni la destra';
        if (modifier.contains('left')) return 'Gira a sinistra';
        if (modifier.contains('right')) return 'Gira a destra';
        if (modifier.contains('uturn')) return 'Inverti marcia';
        return 'Svolta';
      case 'new name':
      case 'continue':
      default:
        if (lanes.isNotEmpty) return laneKeepPhrase;
        return name.trim().isEmpty ? 'Prosegui dritto' : 'Prosegui';
    }
  }

  String get instructionIt {
    if (isWalkAction) return walkActionIt;
    if (isTransitVehicle) return transitActionIt;
    final road = name.trim().isEmpty ? '' : ' su $name';
    switch (type) {
      case 'arrive':
        return maneuverIt;
      case 'new name':
      case 'continue':
        return name.trim().isEmpty ? 'Prosegui dritto' : 'Prosegui su $name';
      default:
        return '$maneuverIt$road';
    }
  }

  String hudSubtitle({double? metersToManeuver}) {
    if (isTransitVehicle) {
      if (metersToManeuver != null && metersToManeuver <= 80) {
        return alightActionIt;
      }
      final stop = (alightStop ?? '').trim();
      return stop.isEmpty ? '' : 'Scendi a $stop';
    }
    if (isWalkAction) return '';
    return name.trim();
  }

  /// Which side of the carriageway OSRM marked valid. Empty if unknown.
  String get laneKeepPhrase {
    if (lanes.isEmpty) return 'Prosegui';
    final n = lanes.length;
    final validIdx = [
      for (var i = 0; i < n; i++)
        if (lanes[i].valid) i,
    ];
    if (validIdx.isEmpty || validIdx.length == n) return 'Prosegui';
    final lastLeft = (n - 1) / 2;
    if (validIdx.every((i) => i <= lastLeft)) return 'Tieni la sinistra';
    if (validIdx.every((i) => i >= n / 2)) return 'Tieni la destra';
    return 'Prosegui';
  }
}

class TransitLeg {
  final String kind;
  final String mode;
  final String? line;
  final String? headsign;
  final String fromStop;
  final String toStop;
  final double? fromLat;
  final double? fromLon;
  final double? toLat;
  final double? toLon;
  final double distanceMeters;
  final double durationSeconds;
  final DateTime? startTime;
  final DateTime? endTime;

  const TransitLeg({
    required this.kind,
    required this.mode,
    this.line,
    this.headsign,
    this.fromStop = '',
    this.toStop = '',
    this.fromLat,
    this.fromLon,
    this.toLat,
    this.toLon,
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.startTime,
    this.endTime,
  });

  bool get isWalk =>
      kind == 'walk' || mode.toUpperCase() == 'WALK';

  String get vehicleIt {
    switch (mode.toUpperCase()) {
      case 'TRAM':
        return 'Tram';
      case 'BUS':
      case 'COACH':
        return 'Bus';
      case 'SUBWAY':
      case 'METRO':
        return 'Metro';
      case 'RAIL':
      case 'HIGHSPEED_RAIL':
      case 'LONG_DISTANCE':
      case 'NIGHT_RAIL':
      case 'REGIONAL_RAIL':
      case 'REGIONAL_FAST_RAIL':
      case 'SUBURBAN':
        return 'Treno';
      case 'FERRY':
        return 'Traghetto';
      default:
        return 'Mezzo';
    }
  }

  String get actionIt {
    if (isWalk) {
      final stop = toStop.trim();
      if (stop.isEmpty) return 'Cammina verso destinazione';
      return 'Cammina verso fermata $stop';
    }
    final lineBit = (line ?? '').trim();
    final vehicle = lineBit.isEmpty ? vehicleIt : '$vehicleIt $lineBit';
    final dest = (headsign ?? '').trim();
    if (dest.isEmpty) return vehicle;
    return '$vehicle direzione $dest';
  }

  String get boardIt {
    final stop = fromStop.trim();
    if (stop.isEmpty) return actionIt;
    return 'Sali a $stop · $actionIt';
  }

  String get alightIt {
    final stop = toStop.trim();
    if (stop.isEmpty) return 'Scendi';
    return 'Scendi a $stop';
  }

  factory TransitLeg.fromJson(Map<String, dynamic> json) {
    return TransitLeg(
      kind: json['kind']?.toString() ?? 'walk',
      mode: json['mode']?.toString() ?? 'WALK',
      line: json['line']?.toString(),
      headsign: json['headsign']?.toString(),
      fromStop: json['fromStop']?.toString() ?? '',
      toStop: json['toStop']?.toString() ?? '',
      fromLat: (json['fromLat'] as num?)?.toDouble(),
      fromLon: (json['fromLon'] as num?)?.toDouble(),
      toLat: (json['toLat'] as num?)?.toDouble(),
      toLon: (json['toLon'] as num?)?.toDouble(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble() ?? 0,
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? ''),
      endTime: DateTime.tryParse(json['endTime']?.toString() ?? ''),
    );
  }
}

class TransitItinerary {
  final DateTime? startTime;
  final DateTime? endTime;
  final int transfers;
  final List<TransitLeg> legs;

  const TransitItinerary({
    this.startTime,
    this.endTime,
    this.transfers = 0,
    this.legs = const [],
  });

  factory TransitItinerary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransitItinerary();
    }
    final rawLegs = json['legs'];
    return TransitItinerary(
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? ''),
      endTime: DateTime.tryParse(json['endTime']?.toString() ?? ''),
      transfers: (json['transfers'] as num?)?.toInt() ?? 0,
      legs: rawLegs is List
          ? rawLegs
              .whereType<Map>()
              .map((e) => TransitLeg.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class RoutePlan {
  final TravelMode mode;
  final List<List<double>> points;
  final List<NavStep> steps;
  final List<double> speeds;
  final double distanceMeters;
  final double durationSeconds;
  final TransitItinerary? itinerary;

  const RoutePlan({
    this.mode = TravelMode.car,
    required this.points,
    required this.steps,
    required this.speeds,
    required this.distanceMeters,
    required this.durationSeconds,
    this.itinerary,
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
    final rawIt = data['itinerary'];
    return RoutePlan(
      mode: parseTravelMode(data['mode']?.toString()),
      points: points,
      steps: steps,
      speeds: speeds,
      distanceMeters: (data['distanceMeters'] as num?)?.toDouble() ?? 0,
      durationSeconds: (data['durationSeconds'] as num?)?.toDouble() ?? 0,
      itinerary: rawIt is Map
          ? TransitItinerary.fromJson(Map<String, dynamic>.from(rawIt))
          : null,
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
