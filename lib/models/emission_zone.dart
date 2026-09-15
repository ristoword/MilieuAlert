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
      minimumEuroLevel: json['minimumEuroLevel'] as int?,
      restrictions: json['restrictions']?.toString(),
      officialSource: json['officialSource']?.toString(),
    );
  }

  bool get isCurrentlyActive {
    final now = DateTime.now();
    if (activeFrom != null && now.isBefore(activeFrom!)) return false;
    if (activeTo != null && now.isAfter(activeTo!)) return false;
    return true;
  }
}
