// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MilieuAlert';

  @override
  String alertApproaching(int distance, String zoneName) {
    return 'Warning: in $distance metres you will enter the $zoneName.';
  }

  @override
  String alertEntering(String zoneName) {
    return 'You are entering the $zoneName.';
  }

  @override
  String alertNotAuthorized(String euroClass, String fuelType) {
    return 'Your vehicle $euroClass $fuelType may not be authorized to drive in this zone.';
  }

  @override
  String get alertAuthorized =>
      'Your vehicle is authorized to drive in this zone.';

  @override
  String get alertLeaving => 'Low emission zone ended.';

  @override
  String get onboardingLanguageTitle => 'Select Language';

  @override
  String get onboardingVehicleTitle => 'Vehicle Setup';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get fuelType => 'Fuel Type';

  @override
  String get euroClass => 'Euro Class';

  @override
  String get licensePlate => 'License Plate (optional)';

  @override
  String get country => 'Country of Registration';

  @override
  String get next => 'Next';

  @override
  String get save => 'Save';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get settings => 'Settings';

  @override
  String get navMap => 'Map';

  @override
  String get navNavigation => 'Navigation';

  @override
  String get alertDistance => 'Alert Distance';

  @override
  String get language => 'Language';

  @override
  String get vehicleInfo => 'Vehicle Information';

  @override
  String get editVehicle => 'Edit Vehicle';

  @override
  String get noVehicleConfigured => 'No vehicle configured';

  @override
  String get vehicleDescription => 'Tell us about your vehicle';

  @override
  String get vehicleDescriptionSubtext =>
      'This information helps determine if your vehicle is allowed in emission zones.';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get zoneDetails => 'Zone Details';

  @override
  String get zoneName => 'Zone Name';

  @override
  String get zoneCity => 'City';

  @override
  String get zoneCountry => 'Country';

  @override
  String get zoneType => 'Zone Type';

  @override
  String get zoneInformation => 'Zone Information';

  @override
  String get zoneNotFound => 'Zone not found';

  @override
  String get activeFrom => 'Active From';

  @override
  String get activeTo => 'Active To';

  @override
  String get activeDays => 'Active Days';

  @override
  String get minimumEuro => 'Minimum Euro Class';

  @override
  String get allowedFuelTypes => 'Allowed Fuel Types';

  @override
  String get allowedVehicleTypes => 'Allowed Vehicle Types';

  @override
  String get restrictions => 'Restrictions';

  @override
  String get officialSource => 'Official Source';

  @override
  String get lastVerified => 'Last Verified';

  @override
  String get disclaimer =>
      'Informational result. Always verify official regulations.';

  @override
  String get car => 'Car';

  @override
  String get van => 'Van';

  @override
  String get truck => 'Truck';

  @override
  String get camper => 'Camper';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get diesel => 'Diesel';

  @override
  String get petrol => 'Petrol';

  @override
  String get lpg => 'LPG';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get electric => 'Electric';

  @override
  String get speed => 'Speed';

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
  String get environmentalZone => 'Environmental Zone';

  @override
  String get zeroEmissionZone => 'Zero Emission Zone';

  @override
  String get noZonesNearby => 'No zones nearby';

  @override
  String get syncingZones => 'Syncing zone data...';

  @override
  String get syncComplete => 'Zone data updated';

  @override
  String get syncError => 'Failed to update zone data';

  @override
  String approachingZone(String zoneName, int distance) {
    return 'Approaching $zoneName - ${distance}m';
  }

  @override
  String insideZoneAuthorized(String zoneName) {
    return 'Inside $zoneName - Vehicle authorized';
  }

  @override
  String insideZoneNotAuthorized(String zoneName) {
    return '⚠ Vehicle NOT authorized in $zoneName';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String appVersion(String version) {
    return 'MilieuAlert v$version';
  }

  @override
  String get licensePlateHint => 'e.g. AB-123-CD';

  @override
  String get locationPermissionRequired =>
      'Location permission is required for zone alerts';

  @override
  String get notificationPermissionRequired =>
      'Notification permission is required for zone alerts';

  @override
  String get backgroundLocationRequired =>
      'Background location is needed to alert you while driving';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String euro(int level) {
    return 'Euro $level';
  }
}
