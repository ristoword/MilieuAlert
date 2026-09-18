import 'package:flutter/widgets.dart';

import '../models/poi_category.dart';
import '../models/vehicle.dart';
import 'app_localizations.dart';

AppLocalizations l10nOf(BuildContext context) =>
    AppLocalizations.of(context) ?? lookupAppLocalizations(const Locale('it'));

bool isMyLocationText(String raw, AppLocalizations l10n) {
  final t = raw.trim().toLowerCase();
  const known = {
    'la mia posizione',
    'my location',
    'mijn locatie',
    'mein standort',
    'ma position',
  };
  return t == l10n.myLocation.toLowerCase() || known.contains(t);
}

String suggestedPlaceLabel(String stored, AppLocalizations l10n) {
  switch (stored.toLowerCase()) {
    case 'casa':
      return l10n.placeHome;
    case 'lavoro':
      return l10n.placeWork;
    default:
      return stored;
  }
}

String localizedPoiLabel(AppLocalizations l10n, PoiCategory cat) {
  switch (cat.id) {
    case 'restaurants':
      return l10n.poiRestaurants;
    case 'fuel':
      return l10n.poiFuel;
    case 'tobacco':
      return l10n.poiTobacco;
    case 'parking':
      return l10n.poiParking;
    case 'supermarket':
      return l10n.poiSupermarket;
    case 'cafe':
      return l10n.poiCafe;
    case 'pharmacy':
      return l10n.poiPharmacy;
    default:
      return cat.label;
  }
}

String localizedVehicleType(AppLocalizations l10n, VehicleType type) {
  switch (type) {
    case VehicleType.car:
      return l10n.car;
    case VehicleType.van:
      return l10n.van;
    case VehicleType.truck:
      return l10n.truck;
    case VehicleType.camper:
      return l10n.camper;
    case VehicleType.motorcycle:
      return l10n.motorcycle;
  }
}

String localizedFuelType(AppLocalizations l10n, FuelType type) {
  switch (type) {
    case FuelType.diesel:
      return l10n.diesel;
    case FuelType.petrol:
      return l10n.petrol;
    case FuelType.lpg:
      return l10n.lpg;
    case FuelType.hybrid:
      return l10n.hybrid;
    case FuelType.electric:
      return l10n.electric;
  }
}
