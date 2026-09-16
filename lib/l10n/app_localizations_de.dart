// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MilieuAlert';

  @override
  String alertApproaching(int distance, String zoneName) {
    return 'Achtung: In $distance Metern erreichen Sie die $zoneName.';
  }

  @override
  String alertEntering(String zoneName) {
    return 'Sie betreten die $zoneName.';
  }

  @override
  String alertNotAuthorized(String euroClass, String fuelType) {
    return 'Ihr Fahrzeug $euroClass $fuelType ist moeglicherweise nicht berechtigt, in dieser Zone zu fahren.';
  }

  @override
  String get alertAuthorized => 'Ihr Fahrzeug ist in dieser Zone zugelassen.';

  @override
  String get alertLeaving => 'Umweltzone verlassen.';

  @override
  String get onboardingLanguageTitle => 'Sprache Auswaehlen';

  @override
  String get onboardingVehicleTitle => 'Fahrzeug Einrichten';

  @override
  String get vehicleType => 'Fahrzeugtyp';

  @override
  String get fuelType => 'Kraftstoffart';

  @override
  String get euroClass => 'Euro-Klasse';

  @override
  String get licensePlate => 'Kennzeichen (optional)';

  @override
  String get country => 'Zulassungsland';

  @override
  String get next => 'Weiter';

  @override
  String get save => 'Speichern';

  @override
  String get saveAndContinue => 'Speichern & Weiter';

  @override
  String get settings => 'Einstellungen';

  @override
  String get navMap => 'Karte';

  @override
  String get navNavigation => 'Navigation';

  @override
  String get alertDistance => 'Warnabstand';

  @override
  String get language => 'Sprache';

  @override
  String get vehicleInfo => 'Fahrzeuginformationen';

  @override
  String get editVehicle => 'Fahrzeug bearbeiten';

  @override
  String get noVehicleConfigured => 'Kein Fahrzeug konfiguriert';

  @override
  String get vehicleDescription => 'Erzaehlen Sie uns von Ihrem Fahrzeug';

  @override
  String get vehicleDescriptionSubtext =>
      'Diese Informationen helfen festzustellen, ob Ihr Fahrzeug in Umweltzonen zugelassen ist.';

  @override
  String get chooseLanguage => 'Waehlen Sie Ihre bevorzugte Sprache';

  @override
  String get zoneDetails => 'Zonendetails';

  @override
  String get zoneName => 'Zonenname';

  @override
  String get zoneCity => 'Stadt';

  @override
  String get zoneCountry => 'Land';

  @override
  String get zoneType => 'Zonentyp';

  @override
  String get zoneInformation => 'Zoneninformationen';

  @override
  String get zoneNotFound => 'Zone nicht gefunden';

  @override
  String get activeFrom => 'Aktiv Ab';

  @override
  String get activeTo => 'Aktiv Bis';

  @override
  String get activeDays => 'Aktive Tage';

  @override
  String get minimumEuro => 'Mindest-Euroklasse';

  @override
  String get allowedFuelTypes => 'Zugelassene Kraftstoffarten';

  @override
  String get allowedVehicleTypes => 'Zugelassene Fahrzeugtypen';

  @override
  String get restrictions => 'Einschraenkungen';

  @override
  String get officialSource => 'Offizielle Quelle';

  @override
  String get lastVerified => 'Zuletzt Ueberprueft';

  @override
  String get disclaimer =>
      'Informatives Ergebnis. Ueberpruefen Sie immer die offiziellen Vorschriften.';

  @override
  String get car => 'PKW';

  @override
  String get van => 'Transporter';

  @override
  String get truck => 'LKW';

  @override
  String get camper => 'Wohnmobil';

  @override
  String get motorcycle => 'Motorrad';

  @override
  String get diesel => 'Diesel';

  @override
  String get petrol => 'Benzin';

  @override
  String get lpg => 'LPG';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get electric => 'Elektrisch';

  @override
  String get speed => 'Geschwindigkeit';

  @override
  String get kmh => 'km/h';

  @override
  String meters(int count) {
    return '$count m';
  }

  @override
  String kilometers(int count) {
    return '$count km';
  }

  @override
  String get environmentalZone => 'Umweltzone';

  @override
  String get zeroEmissionZone => 'Null-Emissionszone';

  @override
  String get noZonesNearby => 'Keine Zonen in der Naehe';

  @override
  String get syncingZones => 'Zonendaten werden synchronisiert...';

  @override
  String get syncComplete => 'Zonendaten aktualisiert';

  @override
  String get syncError => 'Zonendaten konnten nicht aktualisiert werden';

  @override
  String approachingZone(String zoneName, int distance) {
    return '$zoneName naehert sich - ${distance}m';
  }

  @override
  String insideZoneAuthorized(String zoneName) {
    return 'In $zoneName - Fahrzeug zugelassen';
  }

  @override
  String insideZoneNotAuthorized(String zoneName) {
    return '⚠ Fahrzeug NICHT zugelassen in $zoneName';
  }

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Fehler';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String appVersion(String version) {
    return 'MilieuAlert v$version';
  }

  @override
  String get licensePlateHint => 'z.B. AB-123-CD';

  @override
  String get locationPermissionRequired =>
      'Standortberechtigung ist fuer Zonenwarnungen erforderlich';

  @override
  String get notificationPermissionRequired =>
      'Benachrichtigungsberechtigung ist fuer Zonenwarnungen erforderlich';

  @override
  String get backgroundLocationRequired =>
      'Hintergrundstandort wird benoetigt, um Sie waehrend der Fahrt zu warnen';

  @override
  String get grantPermission => 'Berechtigung erteilen';

  @override
  String euro(int level) {
    return 'Euro $level';
  }
}
