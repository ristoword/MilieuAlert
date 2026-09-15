import 'dart:async';
import 'package:tracelet/tracelet.dart' as tl;
import '../models/emission_zone.dart';
import '../models/zone_status.dart';

class GeofenceService {
  final _proximityController = StreamController<ZoneProximity>.broadcast();
  final Map<String, EmissionZone> _zoneMap = {};
  bool _initialized = false;
  StreamSubscription? _geofenceSub;

  Stream<ZoneProximity> get proximityStream => _proximityController.stream;

  Future<void> init() async {
    if (_initialized) return;

    await tl.Tracelet.ready(const tl.Config(
      geofence: tl.GeofenceConfig(
        geofenceModeHighAccuracy: true,
      ),
    ));

    _geofenceSub = tl.Tracelet.onGeofence(_handleGeofenceEvent);
    _initialized = true;
  }

  Future<void> addZones(List<EmissionZone> zones) async {
    for (final id in _zoneMap.keys) {
      try {
        await tl.Tracelet.removeGeofence(id);
      } catch (_) {}
    }
    _zoneMap.clear();

    for (final zone in zones) {
      if (zone.polygonCoordinates.isEmpty ||
          zone.polygonCoordinates[0].isEmpty) {
        continue;
      }

      _zoneMap[zone.id] = zone;

      try {
        // GeoJSON is [lng, lat]; Tracelet vertices expect [lat, lng]
        final vertices = zone.polygonCoordinates[0]
            .map((c) => [c[1], c[0]])
            .toList();

        // Compute centroid for required lat/lng
        double latSum = 0, lngSum = 0;
        for (final v in vertices) {
          latSum += v[0];
          lngSum += v[1];
        }
        final centroidLat = latSum / vertices.length;
        final centroidLng = lngSum / vertices.length;

        await tl.Tracelet.addGeofence(tl.Geofence(
          identifier: zone.id,
          latitude: centroidLat,
          longitude: centroidLng,
          radius: 0,
          vertices: vertices,
          notifyOnEntry: true,
          notifyOnExit: true,
          notifyOnDwell: true,
        ));
      } catch (e) {
        // Skip zones that fail to register
      }
    }
  }

  void _handleGeofenceEvent(tl.GeofenceEvent event) {
    final zone = _zoneMap[event.identifier];
    if (zone == null) return;

    ZoneStatus status;
    switch (event.action) {
      case tl.GeofenceAction.enter:
        status = ZoneStatus.inside;
        break;
      case tl.GeofenceAction.exit:
        status = ZoneStatus.safe;
        break;
      case tl.GeofenceAction.dwell:
        status = ZoneStatus.inside;
        break;
    }

    _proximityController.add(ZoneProximity(
      zoneId: zone.id,
      zoneName: zone.name,
      zoneType: zone.zoneType,
      status: status,
    ));
  }

  void dispose() {
    _geofenceSub?.cancel();
    _proximityController.close();
  }
}
