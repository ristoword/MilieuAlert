// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'MilieuAlert';

  @override
  String alertApproaching(int distance, String zoneName) {
    return 'Waarschuwing: over $distance meter komt u in de $zoneName.';
  }

  @override
  String alertEntering(String zoneName) {
    return 'U betreedt de $zoneName.';
  }

  @override
  String alertNotAuthorized(String euroClass, String fuelType) {
    return 'Uw voertuig $euroClass $fuelType is mogelijk niet toegestaan in deze zone.';
  }

  @override
  String get alertAuthorized => 'Uw voertuig is toegestaan in deze zone.';

  @override
  String get alertLeaving => 'Milieuzone verlaten.';

  @override
  String get onboardingLanguageTitle => 'Taal selecteren';

  @override
  String get onboardingVehicleTitle => 'Voertuig instellen';

  @override
  String get vehicleType => 'Voertuigtype';

  @override
  String get fuelType => 'Brandstoftype';

  @override
  String get euroClass => 'Euroklasse';

  @override
  String get licensePlate => 'Kenteken (optioneel)';

  @override
  String get country => 'Land van registratie';

  @override
  String get next => 'Volgende';

  @override
  String get save => 'Opslaan';

  @override
  String get saveAndContinue => 'Opslaan & Doorgaan';

  @override
  String get settings => 'Instellingen';

  @override
  String get alertDistance => 'Waarschuwingsafstand';

  @override
  String get language => 'Taal';

  @override
  String get vehicleInfo => 'Voertuiginformatie';

  @override
  String get editVehicle => 'Voertuig bewerken';

  @override
  String get noVehicleConfigured => 'Geen voertuig ingesteld';

  @override
  String get vehicleDescription => 'Vertel ons over uw voertuig';

  @override
  String get vehicleDescriptionSubtext =>
      'Deze informatie helpt te bepalen of uw voertuig is toegestaan in milieuzones.';

  @override
  String get chooseLanguage => 'Kies uw voorkeurstaal';

  @override
  String get zoneDetails => 'Zonedetails';

  @override
  String get zoneName => 'Zonenaam';

  @override
  String get zoneCity => 'Stad';

  @override
  String get zoneCountry => 'Land';

  @override
  String get zoneType => 'Zonetype';

  @override
  String get zoneInformation => 'Zone-informatie';

  @override
  String get zoneNotFound => 'Zone niet gevonden';

  @override
  String get activeFrom => 'Actief vanaf';

  @override
  String get activeTo => 'Actief tot';

  @override
  String get activeDays => 'Actieve dagen';

  @override
  String get minimumEuro => 'Minimale Euroklasse';

  @override
  String get allowedFuelTypes => 'Toegestane brandstoftypes';

  @override
  String get allowedVehicleTypes => 'Toegestane voertuigtypes';

  @override
  String get restrictions => 'Beperkingen';

  @override
  String get officialSource => 'Officiële bron';

  @override
  String get lastVerified => 'Laatst geverifieerd';

  @override
  String get disclaimer =>
      'Informatief resultaat. Controleer altijd de officiële regelgeving.';

  @override
  String get car => 'Personenauto';

  @override
  String get van => 'Bestelwagen';

  @override
  String get truck => 'Vrachtwagen';

  @override
  String get camper => 'Camper';

  @override
  String get motorcycle => 'Motorfiets';

  @override
  String get diesel => 'Diesel';

  @override
  String get petrol => 'Benzine';

  @override
  String get lpg => 'LPG';

  @override
  String get hybrid => 'Hybride';

  @override
  String get electric => 'Elektrisch';

  @override
  String get speed => 'Snelheid';

  @override
  String get kmh => 'km/u';

  @override
  String meters(int count) {
    return '$count m';
  }

  @override
  String kilometers(int count) {
    return '$count km';
  }

  @override
  String get environmentalZone => 'Milieuzone';

  @override
  String get zeroEmissionZone => 'Nul-emissiezone';

  @override
  String get noZonesNearby => 'Geen zones in de buurt';

  @override
  String get syncingZones => 'Zonegegevens synchroniseren...';

  @override
  String get syncComplete => 'Zonegegevens bijgewerkt';

  @override
  String get syncError => 'Synchronisatie mislukt';

  @override
  String approachingZone(String zoneName, int distance) {
    return '$zoneName nadert - ${distance}m';
  }

  @override
  String insideZoneAuthorized(String zoneName) {
    return 'In $zoneName - Voertuig toegestaan';
  }

  @override
  String insideZoneNotAuthorized(String zoneName) {
    return '⚠ Voertuig NIET toegestaan in $zoneName';
  }

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Fout';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get ok => 'OK';

  @override
  String appVersion(String version) {
    return 'MilieuAlert v$version';
  }

  @override
  String get licensePlateHint => 'bijv. AB-123-CD';

  @override
  String get locationPermissionRequired =>
      'Locatietoestemming is vereist voor zone-waarschuwingen';

  @override
  String get notificationPermissionRequired =>
      'Meldingstoestemming is vereist voor zone-waarschuwingen';

  @override
  String get backgroundLocationRequired =>
      'Achtergrondlocatie is nodig om u te waarschuwen tijdens het rijden';

  @override
  String get grantPermission => 'Toestemming verlenen';

  @override
  String euro(int level) {
    return 'Euro $level';
  }
}
