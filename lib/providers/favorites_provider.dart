import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/navigation_models.dart';
import '../models/saved_places.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

const _placesKey = 'saved_places_v1';
const _itinerariesKey = 'favorite_itineraries_v1';
const kMaxFavoriteItineraries = 12;

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.watch(sharedPrefsProvider));
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static FavoritesState _load(SharedPreferences prefs) {
    return FavoritesState(
      places: _decodeList(prefs.getString(_placesKey), SavedPlace.fromJson),
      itineraries: _sortTrips(
        _decodeList(prefs.getString(_itinerariesKey), FavoriteItinerary.fromJson),
      ),
    );
  }

  static List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static List<FavoriteItinerary> _sortTrips(List<FavoriteItinerary> trips) {
    final copy = [...trips];
    copy.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.lastUsedMs.compareTo(a.lastUsedMs);
    });
    return copy;
  }

  static String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  Future<void> _persist() async {
    await _prefs.setString(
      _placesKey,
      jsonEncode(state.places.map((e) => e.toJson()).toList()),
    );
    await _prefs.setString(
      _itinerariesKey,
      jsonEncode(state.itineraries.map((e) => e.toJson()).toList()),
    );
  }

  Future<SavedPlace> upsertPlace({
    String? id,
    required String label,
    required String address,
    required double lat,
    required double lon,
  }) async {
    final trimmedLabel = label.trim();
    final trimmedAddress = address.trim();
    final existingIndex = id == null
        ? -1
        : state.places.indexWhere((p) => p.id == id);
    final place = SavedPlace(
      id: existingIndex >= 0 ? state.places[existingIndex].id : (id ?? _newId()),
      label: trimmedLabel,
      address: trimmedAddress,
      lat: lat,
      lon: lon,
    );
    final places = [...state.places];
    if (existingIndex >= 0) {
      places[existingIndex] = place;
    } else {
      final sameLabel = places.indexWhere(
        (p) => p.label.trim().toLowerCase() == trimmedLabel.toLowerCase(),
      );
      if (sameLabel >= 0) {
        places[sameLabel] = SavedPlace(
          id: places[sameLabel].id,
          label: trimmedLabel,
          address: trimmedAddress,
          lat: lat,
          lon: lon,
        );
        state = state.copyWith(places: places);
        await _persist();
        return places[sameLabel];
      }
      places.add(place);
    }
    state = state.copyWith(places: places);
    await _persist();
    return place;
  }

  Future<void> deletePlace(String id) async {
    state = state.copyWith(
      places: state.places.where((p) => p.id != id).toList(),
    );
    await _persist();
  }

  Future<void> rememberSuccessfulTrip({
    required PlaceHit? origin,
    required bool originIsMyLocation,
    required PlaceHit destination,
    required LocationState location,
  }) async {
    double? oLat;
    double? oLon;
    var oLabel = origin?.label.trim() ?? '';
    if (originIsMyLocation) {
      oLabel = oLabel.isEmpty ? 'La mia posizione' : oLabel;
      oLat = origin?.lat ?? location.latitude;
      oLon = origin?.lon ?? location.longitude;
    } else if (origin != null) {
      oLat = origin.lat;
      oLon = origin.lon;
      if (oLabel.isEmpty) oLabel = destination.label;
    }
    if (oLat == null || oLon == null) return;

    final dLabel = destination.label.trim().isEmpty
        ? 'Destinazione'
        : destination.label.trim();

    final samePoint = (oLat - destination.lat).abs() < 0.00015 &&
        (oLon - destination.lon).abs() < 0.00015;
    if (samePoint) return;

    final incoming = FavoriteItinerary(
      id: _newId(),
      originLabel: oLabel.isEmpty ? 'Partenza' : oLabel,
      originLat: oLat,
      originLon: oLon,
      originIsMyLocation: originIsMyLocation,
      destLabel: dLabel,
      destLat: destination.lat,
      destLon: destination.lon,
      lastUsedMs: DateTime.now().millisecondsSinceEpoch,
    );

    final trips = [...state.itineraries];
    final existing = trips.indexWhere((t) => t.dedupeKey == incoming.dedupeKey);
    if (existing >= 0) {
      trips[existing] = trips[existing].copyWith(
        originLabel: incoming.originLabel,
        destLabel: incoming.destLabel,
        lastUsedMs: incoming.lastUsedMs,
      );
    } else {
      trips.add(incoming);
    }

    var sorted = _sortTrips(trips);
    if (sorted.length > kMaxFavoriteItineraries) {
      final pinned = sorted.where((t) => t.pinned).toList();
      final rest = sorted.where((t) => !t.pinned).toList();
      final keepRest = kMaxFavoriteItineraries - pinned.length;
      sorted = [
        ...pinned,
        ...rest.take(keepRest < 0 ? 0 : keepRest),
      ];
      sorted = _sortTrips(sorted);
    }

    state = state.copyWith(itineraries: sorted);
    await _persist();
  }

  Future<void> togglePin(String id) async {
    final trips = [
      for (final trip in state.itineraries)
        if (trip.id == id) trip.copyWith(pinned: !trip.pinned) else trip,
    ];
    state = state.copyWith(itineraries: _sortTrips(trips));
    await _persist();
  }

  Future<void> deleteItinerary(String id) async {
    state = state.copyWith(
      itineraries: state.itineraries.where((t) => t.id != id).toList(),
    );
    await _persist();
  }

  Future<void> touchItinerary(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final trips = [
      for (final trip in state.itineraries)
        if (trip.id == id) trip.copyWith(lastUsedMs: now) else trip,
    ];
    state = state.copyWith(itineraries: _sortTrips(trips));
    await _persist();
  }
}
