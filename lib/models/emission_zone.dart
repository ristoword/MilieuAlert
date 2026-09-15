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

  bool get isCurrentlyActive {
    final now = DateTime.now();
    if (activeFrom != null && now.isBefore(activeFrom!)) return false;
    if (activeTo != null && now.isAfter(activeTo!)) return false;
    return true;
  }
}
