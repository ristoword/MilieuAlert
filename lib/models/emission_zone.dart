class EmissionZone {
  final String id;
  final String country;
  final String city;
  final String name;
  final String zoneType;
  final List<List<List<double>>> polygonCoordinates;
  final DateTime? activeFrom;
  final DateTime? activeTo;
  final String? activeDays;
  final int? minimumEuroLevel;
  final List<String>? allowedFuelTypes;
  final List<String>? allowedVehicleTypes;
  final String? restrictions;
  final String? officialSource;
  final DateTime? lastVerifiedAt;

  const EmissionZone({
    required this.id,
    required this.country,
    required this.city,
    required this.name,
    required this.zoneType,
    required this.polygonCoordinates,
    this.activeFrom,
    this.activeTo,
    this.activeDays,
    this.minimumEuroLevel,
    this.allowedFuelTypes,
    this.allowedVehicleTypes,
    this.restrictions,
    this.officialSource,
    this.lastVerifiedAt,
  });

  factory EmissionZone.fromJson(Map<String, dynamic> json) {
    final rawPoly = json['polygonCoordinates'] as List? ?? const [];
    final polygon = rawPoly
        .map((ring) => (ring as List)
            .map((pt) => (pt as List)
                .map((n) => (n as num).toDouble())
                .toList())
            .toList())
        .toList();

    return EmissionZone(
      id: json['id']?.toString() ?? 'zone',
      country: json['country']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      zoneType: json['zoneType']?.toString() ?? 'ENVIRONMENTAL_ZONE',
      polygonCoordinates: polygon,
      activeFrom: _parseDate(json['activeFrom'] ?? json['startTime'] ?? json['validFrom']),
      activeTo: _parseDate(json['activeTo'] ?? json['endTime'] ?? json['validTo']),
      activeDays: json['activeDays']?.toString() ?? json['daysOfWeek']?.toString(),
      minimumEuroLevel: json['minimumEuroLevel'] as int?,
      restrictions: json['restrictions']?.toString(),
      officialSource: json['officialSource']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  bool get isCurrentlyActive => isActiveAt(DateTime.now());

  bool isActiveAt(DateTime when) {
    final local = when.toLocal();
    if (activeFrom != null && local.isBefore(activeFrom!.toLocal())) {
      return false;
    }
    if (activeTo != null && local.isAfter(activeTo!.toLocal())) {
      return false;
    }
    if (!_matchesActiveDays(local)) return false;
    final hours = _hoursFromRestrictions();
    if (hours != null) {
      final minutes = local.hour * 60 + local.minute;
      if (hours.start <= hours.end) {
        if (minutes < hours.start || minutes > hours.end) return false;
      } else if (minutes < hours.start && minutes > hours.end) {
        return false;
      }
    }
    return true;
  }

  bool _matchesActiveDays(DateTime when) {
    final raw = activeDays?.toLowerCase().trim();
    if (raw == null || raw.isEmpty) return true;
    const names = {
      1: ['mon', 'lun', 'ma'],
      2: ['tue', 'mar', 'di'],
      3: ['wed', 'mer', 'wo'],
      4: ['thu', 'gio', 'do'],
      5: ['fri', 'ven', 'vr'],
      6: ['sat', 'sab', 'za'],
      7: ['sun', 'dom', 'zo'],
    };
    final tokens = names[when.weekday] ?? const <String>[];
    return tokens.any(raw.contains) || raw.contains(when.weekday.toString());
  }

  ({int start, int end})? _hoursFromRestrictions() {
    final raw = restrictions;
    if (raw == null || raw.isEmpty) return null;
    final match = RegExp(
      r'(\d{1,2})[:.](\d{2})\s*[-–]\s*(\d{1,2})[:.](\d{2})',
    ).firstMatch(raw);
    if (match == null) return null;
    final start = int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
    final end = int.parse(match.group(3)!) * 60 + int.parse(match.group(4)!);
    return (start: start, end: end);
  }
}
