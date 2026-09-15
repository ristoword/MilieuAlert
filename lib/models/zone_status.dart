enum ZoneStatus {
  safe,
  approaching,
  inside,
}

class ZoneProximity {
  final String zoneId;
  final String zoneName;
  final String zoneType;
  final ZoneStatus status;
  final double? distanceMeters;
  final bool? isVehicleAllowed;

  const ZoneProximity({
    required this.zoneId,
    required this.zoneName,
    required this.zoneType,
    required this.status,
    this.distanceMeters,
    this.isVehicleAllowed,
  });
}

String formatZoneType(String raw) {
  final value = raw.toLowerCase();
  if (value.contains('zero')) return 'Zero Emission Zone';
  if (value.contains('ultra')) return 'Ultra Low Emission';
  if (value.contains('lez') || value.contains('environmental') || value.contains('milieu')) {
    return 'Milieuzone / LEZ';
  }
  if (raw.trim().isEmpty) return 'Emission zone';
  return raw.replaceAll('_', ' ');
}

String formatDistance(double? meters) {
  if (meters == null || meters.isInfinite) return '—';
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

