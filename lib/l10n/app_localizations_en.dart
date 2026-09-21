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
    return 'Your vehicle $euroClass $fuelType may not be allowed in this low emission zone.';
  }

  @override
  String get alertAuthorized =>
      'Your vehicle is allowed in this low emission zone.';

  @override
  String get alertLeaving => 'Low emission zone ended.';

  @override
  String get onboardingLanguageTitle => 'Select language';

  @override
  String get onboardingVehicleTitle => 'Vehicle setup';

  @override
  String get vehicleType => 'Vehicle type';

  @override
  String get fuelType => 'Fuel type';

  @override
  String get euroClass => 'Euro class';

  @override
  String get licensePlate => 'Number plate (optional)';

  @override
  String get country => 'Country of registration';

  @override
  String get next => 'Next';

  @override
  String get save => 'Save';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get settings => 'Settings';

  @override
  String get navMap => 'Map';

  @override
  String get navNavigation => 'Navigation';

  @override
  String get alertDistance => 'Alert distance';

  @override
  String get language => 'Language';

  @override
  String get vehicleInfo => 'Vehicle information';

  @override
  String get editVehicle => 'Edit vehicle';

  @override
  String get noVehicleConfigured => 'No vehicle configured';

  @override
  String get vehicleDescription => 'Tell us about your vehicle';

  @override
  String get vehicleDescriptionSubtext =>
      'This is used to check whether your vehicle is allowed in low emission zones (milieuzone).';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get zoneDetails => 'Zone details';

  @override
  String get zoneName => 'Zone name';

  @override
  String get zoneCity => 'City';

  @override
  String get zoneCountry => 'Country';

  @override
  String get zoneType => 'Zone type';

  @override
  String get zoneInformation => 'Zone information';

  @override
  String get zoneNotFound => 'Zone not found';

  @override
  String get activeFrom => 'Active from';

  @override
  String get activeTo => 'Active until';

  @override
  String get activeDays => 'Active days';

  @override
  String get minimumEuro => 'Minimum Euro class';

  @override
  String get allowedFuelTypes => 'Allowed fuel types';

  @override
  String get allowedVehicleTypes => 'Allowed vehicle types';

  @override
  String get restrictions => 'Restrictions';

  @override
  String get officialSource => 'Official source';

  @override
  String get lastVerified => 'Last verified';

  @override
  String get disclaimer => 'Informational only. Always check official rules.';

  @override
  String get notGovernmentDisclaimer =>
      'MilieuAlert is not a government entity and is not affiliated with or authorized by any government or municipality. Milieuzone/ZTL/LEZ information is summarized from public sources; always verify on the website of the competent authority.';

  @override
  String get aboutSection => 'About';

  @override
  String get officialSourcesSection => 'Official sources';

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
  String get environmentalZone => 'Low emission zone';

  @override
  String get zeroEmissionZone => 'Zero emission zone';

  @override
  String get noZonesNearby => 'No zones nearby';

  @override
  String get syncingZones => 'Updating zone data…';

  @override
  String get syncComplete => 'Zone data updated';

  @override
  String get syncError => 'Zone update failed';

  @override
  String approachingZone(String zoneName, int distance) {
    return 'Approaching $zoneName — ${distance}m';
  }

  @override
  String insideZoneAuthorized(String zoneName) {
    return 'Inside $zoneName — vehicle allowed';
  }

  @override
  String insideZoneNotAuthorized(String zoneName) {
    return '⚠ Vehicle NOT allowed in $zoneName';
  }

  @override
  String get loading => 'Loading…';

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
  String get grantPermission => 'Grant permission';

  @override
  String get locationDisclosureTitle => 'Location';

  @override
  String get locationDisclosureBody =>
      'MilieuAlert uses your location to navigate and warn you about milieuzones, including in the background or when the app is not in use. You can deny.';

  @override
  String get locationDisclosureContinue => 'Continue';

  @override
  String get locationDisclosureDeny => 'Deny';

  @override
  String get paywallExpiredTitle => '15-day trial ended';

  @override
  String get paywallExpiredBody =>
      '€2.99 per month unlocks everything: milieuzone alerts, speed cameras, EcoEntry. Basic navigator stays free (map, A–B route, heading-up, metres).';

  @override
  String get paywallUnlock => 'Unlock all — €2.99/month';

  @override
  String get paywallTrialTitle => '15-day full trial';

  @override
  String paywallTrialDays(int days) {
    return 'Trial: $days days left';
  }

  @override
  String get paywallTrialHint =>
      'Then €2.99/month for milieuzone, speed cameras and EcoEntry.';

  @override
  String get paywallRedeem => 'I have a code / GS licence';

  @override
  String euro(int level) {
    return 'Euro $level';
  }

  @override
  String get searchPlace => 'Search a place';

  @override
  String get searchPlaceOrAddress => 'Search a place or address';

  @override
  String get fromMyLocation => 'From: My location';

  @override
  String get myLocation => 'My location';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get swapOriginDestination => 'Swap A and B';

  @override
  String get go => 'GO';

  @override
  String get calculating => 'Calculating…';

  @override
  String get goHint => 'Tap GO to start';

  @override
  String get goHintLez => 'Milieuzone on the route — tap GO';

  @override
  String get travelCar => 'Car';

  @override
  String get travelFoot => 'Walk';

  @override
  String get travelTransit => 'Transit';

  @override
  String get noResultsNearby => 'No results nearby';

  @override
  String get noZones => 'No zones';

  @override
  String zonesOnRouteCount(int count) {
    return '$count milieuzone';
  }

  @override
  String get noSpeedCameras => 'No speed cameras';

  @override
  String speedCamerasCount(int count) {
    return '$count speed cameras';
  }

  @override
  String get lezOnRoute => 'Milieuzone on the route';

  @override
  String get lezOnChosenRoute => 'Low emission zone on the chosen route';

  @override
  String get dropoffRecommended => 'Recommended: park and walk';

  @override
  String get places => 'Places';

  @override
  String get recents => 'Recent';

  @override
  String get itineraries => 'Routes';

  @override
  String fromOrigin(String origin) {
    return 'From $origin';
  }

  @override
  String get environmentalZoneShort => 'Low emission zone';

  @override
  String get centered => 'Centred';

  @override
  String get recenter => 'Recentre';

  @override
  String get overview => 'Overview';

  @override
  String get endNav => 'End';

  @override
  String get noLezOnRoute => 'No milieuzone on the route';

  @override
  String get routeAvoidsLez => 'This route avoids highlighted LEZs';

  @override
  String zonesCountEnvironmental(int count) {
    return '$count low emission zone(s)';
  }

  @override
  String get walkLeg => 'Walking leg';

  @override
  String walkTowards(String dest) {
    return 'Walk towards $dest';
  }

  @override
  String walkAfterStop(String distance) {
    return '$distance on foot after the drop-off';
  }

  @override
  String get destinationGeneric => 'destination';

  @override
  String get vehicleNotAuthorized => 'Vehicle not allowed';

  @override
  String get vehicleAuthorized => 'Vehicle allowed';

  @override
  String get nearbyEnvironmentalZone => 'Low emission zone nearby';

  @override
  String speedCameraIn(String distance) {
    return 'Speed camera in $distance';
  }

  @override
  String speedLimitKmh(String limit) {
    return 'Limit $limit km/h';
  }

  @override
  String get speedCheckOnRoute => 'Speed check on the remaining route';

  @override
  String camerasOnRoute(int count) {
    return '$count speed cameras on the route';
  }

  @override
  String get camerasAsPins => 'Shown as pins on the map';

  @override
  String get transitNoTransfers => 'Transit · no changes';

  @override
  String transitTransfers(int count) {
    return 'Transit · $count change(s)';
  }

  @override
  String approachingZoneMeters(int distance) {
    return 'Low emission zone in $distance m';
  }

  @override
  String vehicleNotAuthorizedInZone(String zoneName) {
    return '$zoneName · vehicle not allowed';
  }

  @override
  String insideZoneName(String zoneName) {
    return 'Inside $zoneName';
  }

  @override
  String get askAi => 'Ask AI';

  @override
  String get close => 'Close';

  @override
  String get speedCheckApproaching => 'Speed check ahead';

  @override
  String get cameraCommunity =>
      'Not on the official map · reported by a driver';

  @override
  String cameraCommunityLimit(String limit) {
    return 'Limit $limit km/h · reported by a driver';
  }

  @override
  String routeZonesCount(int count, String names) {
    return '$count zone(s): $names';
  }

  @override
  String get recalculatingRoute => 'Recalculating route';

  @override
  String stopThenWalk(String distance) {
    return 'Stop, then $distance on foot';
  }

  @override
  String get walkTowardsDestination => 'Walk towards destination';

  @override
  String towardsDestination(String dest) {
    return 'Towards $dest';
  }

  @override
  String get routeReady => 'Route ready';

  @override
  String get noRoute => 'No route';

  @override
  String thenWalk(String distance) {
    return 'Then $distance on foot';
  }

  @override
  String get premiumActive => 'Premium active';

  @override
  String get complimentaryAccount => 'Complimentary account — full access';

  @override
  String get premiumUnlockedFeatures =>
      'Milieuzone, speed cameras and EcoEntry unlocked';

  @override
  String get paywallFeatureAlerts => 'Milieuzone / LEZ / ZTL alerts';

  @override
  String get paywallFeatureCameras =>
      'Speed cameras, flitsers and community reports';

  @override
  String get paywallFeatureEcoentry =>
      'EcoEntry, drop-off, AI, favourites, POI';

  @override
  String playBillingLine(String productId, String price) {
    return 'Google Play: $productId · €$price/month';
  }

  @override
  String get paywallTrialHintShort =>
      '€2.99/month: milieuzone, speed cameras, EcoEntry.';

  @override
  String get personalData => 'Personal data';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get email => 'Email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get newPasswordOptional => 'New password (optional)';

  @override
  String get leaveBlankPassword => 'Leave blank to keep the current password';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get atLeast8Chars => 'At least 8 characters';

  @override
  String get navVoice => 'Navigation voice';

  @override
  String get voiceMale => 'Male';

  @override
  String get voiceFemale => 'Female';

  @override
  String get yourCar => 'Your vehicle';

  @override
  String get type => 'Type';

  @override
  String get fuel => 'Fuel';

  @override
  String get saving => 'Saving…';

  @override
  String get savePersonalData => 'Save personal data';

  @override
  String get personalDataSaved => 'Personal data saved';

  @override
  String get savedLocallyServerFailed =>
      'Saved locally. Could not update the server.';

  @override
  String get aiAssistant => 'AI assistant';

  @override
  String get aiAssistantSubtitle => 'Ask about zones, cameras and the route';

  @override
  String get installOnPc => 'Install on this PC';

  @override
  String get installOnPcBody =>
      'Add MilieuAlert as a desktop app — no store or SDK required.';

  @override
  String get signOut => 'Sign out';

  @override
  String get poiRestaurants => 'Restaurants';

  @override
  String get poiFuel => 'Petrol stations';

  @override
  String get poiTobacco => 'Tobacconists';

  @override
  String get poiParking => 'Parking';

  @override
  String get poiSupermarket => 'Supermarkets';

  @override
  String get poiCafe => 'Cafés';

  @override
  String get poiPharmacy => 'Pharmacies';

  @override
  String get placeHome => 'Home';

  @override
  String get placeWork => 'Work';
}
