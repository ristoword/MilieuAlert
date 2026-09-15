import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // Zone colors – neon theme
  static const Color zoneSafe = Color(0x4400E676);
  static const Color zoneApproaching = Color(0x44FF6D00);
  static const Color zoneInside = Color(0x44FF1744);
  static const Color zoneSafeBorder = Color(0xFF00E676);
  static const Color zoneApproachingBorder = Color(0xFFFF6D00);
  static const Color zoneInsideBorder = Color(0xFFFF1744);

  // Default alert distances in meters
  static const List<int> alertDistances = [100, 300, 500, 1000, 2000];
  static const int defaultAlertDistance = 500;

  // Map style
  static const String osmStyleUrl =
      'https://demotiles.maplibre.org/style.json';
  // Carto basemaps (OSM data). Do not use tile.openstreetmap.org in apps.
  static const String osmTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
  static const String osmTileUrlLight =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';

  // API endpoints
  static const String ndwApiUrl =
      'https://data.ndw.nu/api/rest/static-road-data/emission-zones/v1/map';
  static const String antwerpenApiUrl =
      'https://geodata.antwerpen.be/arcgissql/rest/services/P_Portal/portal_publiek4/MapServer/283/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&f=geojson';
  static const String brusselsApiUrl =
      'https://gis.brussels.be/geoserver/bm_network/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=bm_network:lez_zone&outputFormat=application/json&srsName=EPSG:4326';

  // Sync interval
  static const Duration syncInterval = Duration(hours: 24);

  // Initial camera position (Netherlands center)
  static const double initialLat = 52.3676;
  static const double initialLng = 4.9041;
  static const double initialZoom = 7.0;

  // Backend API (Railway)
  static const String apiBaseUrl =
      'https://milieualert-production.up.railway.app';

  // OpenAI config (used by backend, not directly in app)
  static const String aiModel = 'gpt-4o-mini';
}
