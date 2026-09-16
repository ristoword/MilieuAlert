enum HazardType {
  cameraFixed,
  cameraMobile,
  accident,
  jam,
  police,
  roadClosed,
  lezExtra,
}

extension HazardTypeApi on HazardType {
  String get apiValue {
    switch (this) {
      case HazardType.cameraFixed:
        return 'camera_fixed';
      case HazardType.cameraMobile:
        return 'camera_mobile';
      case HazardType.accident:
        return 'accident';
      case HazardType.jam:
        return 'jam';
      case HazardType.police:
        return 'police';
      case HazardType.roadClosed:
        return 'road_closed';
      case HazardType.lezExtra:
        return 'lez_extra';
    }
  }

  bool get isCamera =>
      this == HazardType.cameraFixed || this == HazardType.cameraMobile;

  static HazardType? fromApi(String? raw) {
    switch (raw) {
      case 'camera_fixed':
        return HazardType.cameraFixed;
      case 'camera_mobile':
        return HazardType.cameraMobile;
      case 'accident':
        return HazardType.accident;
      case 'jam':
        return HazardType.jam;
      case 'police':
        return HazardType.police;
      case 'road_closed':
        return HazardType.roadClosed;
      case 'lez_extra':
        return HazardType.lezExtra;
      default:
        return null;
    }
  }
}

class HazardReport {
  final String id;
  final HazardType type;
  final double lat;
  final double lon;
  final double? heading;
  final String? note;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int confirmCount;
  final int denyCount;
  final String author;
  final String source;
  final double? distanceMeters;

  const HazardReport({
    required this.id,
    required this.type,
    required this.lat,
    required this.lon,
    this.heading,
    this.note,
    required this.createdAt,
    required this.expiresAt,
    this.confirmCount = 0,
    this.denyCount = 0,
    this.author = 'un conducente',
    this.source = 'community',
    this.distanceMeters,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory HazardReport.fromJson(Map<String, dynamic> json) {
    final type = HazardTypeApi.fromApi(json['type']?.toString()) ??
        HazardType.accident;
    return HazardReport(
      id: json['id']?.toString() ?? '',
      type: type,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      confirmCount: (json['confirmCount'] as num?)?.toInt() ?? 0,
      denyCount: (json['denyCount'] as num?)?.toInt() ?? 0,
      author: json['author']?.toString() ?? 'un conducente',
      source: json['source']?.toString() ?? 'community',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
    );
  }
}

class HazardComment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String author;

  const HazardComment({
    required this.id,
    required this.text,
    required this.createdAt,
    this.author = 'un conducente',
  });

  factory HazardComment.fromJson(Map<String, dynamic> json) {
    return HazardComment(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? json['body']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      author: json['author']?.toString() ?? 'un conducente',
    );
  }
}
