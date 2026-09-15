enum ZoneStatus {
  safe,
  approaching,
  inside,
}

class ZoneProximity {
  final String zoneId;
  final String zoneName;
  final ZoneStatus status;
  final double? distanceMeters;
  final bool? isVehicleAllowed;

  const ZoneProximity({
    required this.zoneId,
    required this.zoneName,
    required this.status,
    this.distanceMeters,
    this.isVehicleAllowed,
  });
}
