class SavedPlace {
  final String id;
  final String label;
  final String address;
  final double lat;
  final double lon;

  const SavedPlace({
    required this.id,
    required this.label,
    required this.address,
    required this.lat,
    required this.lon,
  });

  SavedPlace copyWith({
    String? label,
    String? address,
    double? lat,
    double? lon,
  }) {
    return SavedPlace(
      id: id,
      label: label ?? this.label,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'lat': lat,
        'lon': lon,
      };

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
    );
  }
}

class FavoriteItinerary {
  final String id;
  final String originLabel;
  final double originLat;
  final double originLon;
  final bool originIsMyLocation;
  final String destLabel;
  final double destLat;
  final double destLon;
  final bool pinned;
  final int lastUsedMs;

  const FavoriteItinerary({
    required this.id,
    required this.originLabel,
    required this.originLat,
    required this.originLon,
    required this.originIsMyLocation,
    required this.destLabel,
    required this.destLat,
    required this.destLon,
    this.pinned = false,
    required this.lastUsedMs,
  });

  String get dedupeKey {
    String r(double v) => v.toStringAsFixed(4);
    final from = originIsMyLocation
        ? 'myloc'
        : '${r(originLat)},${r(originLon)}';
    return '$from->${r(destLat)},${r(destLon)}';
  }

  FavoriteItinerary copyWith({
    String? originLabel,
    String? destLabel,
    bool? pinned,
    int? lastUsedMs,
  }) {
    return FavoriteItinerary(
      id: id,
      originLabel: originLabel ?? this.originLabel,
      originLat: originLat,
      originLon: originLon,
      originIsMyLocation: originIsMyLocation,
      destLabel: destLabel ?? this.destLabel,
      destLat: destLat,
      destLon: destLon,
      pinned: pinned ?? this.pinned,
      lastUsedMs: lastUsedMs ?? this.lastUsedMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'originLabel': originLabel,
        'originLat': originLat,
        'originLon': originLon,
        'originIsMyLocation': originIsMyLocation,
        'destLabel': destLabel,
        'destLat': destLat,
        'destLon': destLon,
        'pinned': pinned,
        'lastUsedMs': lastUsedMs,
      };

  factory FavoriteItinerary.fromJson(Map<String, dynamic> json) {
    return FavoriteItinerary(
      id: json['id']?.toString() ?? '',
      originLabel: json['originLabel']?.toString() ?? '',
      originLat: (json['originLat'] as num?)?.toDouble() ?? 0,
      originLon: (json['originLon'] as num?)?.toDouble() ?? 0,
      originIsMyLocation: json['originIsMyLocation'] == true,
      destLabel: json['destLabel']?.toString() ?? '',
      destLat: (json['destLat'] as num?)?.toDouble() ?? 0,
      destLon: (json['destLon'] as num?)?.toDouble() ?? 0,
      pinned: json['pinned'] == true,
      lastUsedMs: (json['lastUsedMs'] as num?)?.toInt() ?? 0,
    );
  }
}

class FavoritesState {
  final List<SavedPlace> places;
  final List<FavoriteItinerary> itineraries;

  const FavoritesState({
    this.places = const [],
    this.itineraries = const [],
  });

  SavedPlace? placeByLabel(String label) {
    final key = label.trim().toLowerCase();
    for (final place in places) {
      if (place.label.trim().toLowerCase() == key) return place;
    }
    return null;
  }

  FavoritesState copyWith({
    List<SavedPlace>? places,
    List<FavoriteItinerary>? itineraries,
  }) {
    return FavoritesState(
      places: places ?? this.places,
      itineraries: itineraries ?? this.itineraries,
    );
  }
}

const kSuggestedPlaceLabels = ['Casa', 'Lavoro'];
