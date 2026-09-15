import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone_status.dart';

class LocationState {
  final double? latitude;
  final double? longitude;
  final double? speed;
  final double? heading;
  final ZoneProximity? nearestZone;

  const LocationState({
    this.latitude,
    this.longitude,
    this.speed,
    this.heading,
    this.nearestZone,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    double? speed,
    double? heading,
    ZoneProximity? nearestZone,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      nearestZone: nearestZone ?? this.nearestZone,
    );
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  void updateLocation({
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  }) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      heading: heading,
    );
  }

  void updateNearestZone(ZoneProximity? proximity) {
    state = LocationState(
      latitude: state.latitude,
      longitude: state.longitude,
      speed: state.speed,
      heading: state.heading,
      nearestZone: proximity,
    );
  }
}
