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
      'Informatives Ergebnis. Verifizieren Sie immer die offiziellen Vorschriften.';

  @override
  String get notGovernmentDisclaimer =>
      'MilieuAlert ist keine Behörde und weder mit einer Regierung noch mit einer Gemeinde verbunden oder von diesen autorisiert. Milieuzone-/LEZ-Informationen sind Zusammenfassungen aus öffentlichen Quellen; prüfen Sie immer die Website der zuständigen Behörde.';

  @override
  String get aboutSection => 'Info';

  @override
  String get officialSourcesSection => 'Offizielle Quellen';

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
  String get locationDisclosureTitle => 'Standort';

  @override
  String get locationDisclosureBody =>
      'MilieuAlert verwendet Ihren Standort zur Navigation und um Sie vor Umweltzonen (Milieuzones) zu warnen, auch im Hintergrund oder wenn die App nicht verwendet wird. Sie können ablehnen.';

  @override
  String get locationDisclosureContinue => 'Weiter';

  @override
  String get locationDisclosureDeny => 'Ablehnen';

  @override
  String get paywallExpiredTitle => '15 Tage abgelaufen';

  @override
  String get paywallExpiredBody =>
      '1,99 € pro Monat schaltet alles frei: Milieuzone, Blitzer, EcoEntry. Basis-Navigator bleibt (Karte, A-B, Heading-up, Meter).';

  @override
  String get paywallUnlock => 'Alles freischalten — 1,99 €/Monat';

  @override
  String get paywallTrialTitle => '15 Tage voller Test';

  @override
  String paywallTrialDays(int days) {
    return 'Test: noch $days Tage';
  }

  @override
  String get paywallTrialHint =>
      'Danach 1,99 €/Monat für Milieuzone, Blitzer und EcoEntry.';

  @override
  String get paywallRedeem => 'Ich habe einen Code / GS-Lizenz';

  @override
  String euro(int level) {
    return 'Euro $level';
  }

  @override
  String get searchPlace => 'Ort suchen';

  @override
  String get searchPlaceOrAddress => 'Ort oder Adresse suchen';

  @override
  String get fromMyLocation => 'Von: Mein Standort';

  @override
  String get myLocation => 'Mein Standort';

  @override
  String get useMyLocation => 'Meinen Standort verwenden';

  @override
  String get swapOriginDestination => 'A und B tauschen';

  @override
  String get go => 'LOS';

  @override
  String get calculating => 'Berechnung…';

  @override
  String get goHint => 'LOS tippen zum Starten';

  @override
  String get goHintLez => 'Milieuzone auf der Route — LOS tippen';

  @override
  String get travelCar => 'Auto';

  @override
  String get travelFoot => 'Zu Fuss';

  @override
  String get travelTransit => 'ÖPNV';

  @override
  String get noResultsNearby => 'Keine Ergebnisse in der Nähe';

  @override
  String get noZones => 'Keine Zonen';

  @override
  String zonesOnRouteCount(int count) {
    return '$count Milieuzone';
  }

  @override
  String get noSpeedCameras => 'Keine Blitzer';

  @override
  String speedCamerasCount(int count) {
    return '$count Blitzer';
  }

  @override
  String get lezOnRoute => 'Milieuzone auf der Route';

  @override
  String get lezOnChosenRoute => 'Umweltzone auf der gewählten Strecke';

  @override
  String get dropoffRecommended => 'Empfohlen: parken und zu Fuss';

  @override
  String get places => 'Orte';

  @override
  String get recents => 'Zuletzt';

  @override
  String get itineraries => 'Routen';

  @override
  String fromOrigin(String origin) {
    return 'Von $origin';
  }

  @override
  String get environmentalZoneShort => 'Umweltzone';

  @override
  String get centered => 'Zentriert';

  @override
  String get recenter => 'Zentrieren';

  @override
  String get overview => 'Übersicht';

  @override
  String get endNav => 'Ende';

  @override
  String get noLezOnRoute => 'Keine Milieuzone auf der Route';

  @override
  String get routeAvoidsLez => 'Die Route meidet markierte LEZ';

  @override
  String zonesCountEnvironmental(int count) {
    return '$count Umweltzone(n)';
  }

  @override
  String get walkLeg => 'Fussweg';

  @override
  String walkTowards(String dest) {
    return 'Zu Fuss nach $dest';
  }

  @override
  String walkAfterStop(String distance) {
    return '$distance zu Fuss nach dem Halt';
  }

  @override
  String get destinationGeneric => 'Ziel';

  @override
  String get vehicleNotAuthorized => 'Fahrzeug nicht zugelassen';

  @override
  String get vehicleAuthorized => 'Fahrzeug zugelassen';

  @override
  String get nearbyEnvironmentalZone => 'Umweltzone in der Nähe';

  @override
  String speedCameraIn(String distance) {
    return 'Blitzer in $distance';
  }

  @override
  String speedLimitKmh(String limit) {
    return 'Limit $limit km/h';
  }

  @override
  String get speedCheckOnRoute =>
      'Geschwindigkeitskontrolle auf der Reststrecke';

  @override
  String camerasOnRoute(int count) {
    return '$count Blitzer auf der Route';
  }

  @override
  String get camerasAsPins => 'Als Pins auf der Karte';

  @override
  String get transitNoTransfers => 'ÖPNV · ohne Umstieg';

  @override
  String transitTransfers(int count) {
    return 'ÖPNV · $count Umstieg/e';
  }

  @override
  String approachingZoneMeters(int distance) {
    return 'Umweltzone in $distance m';
  }

  @override
  String vehicleNotAuthorizedInZone(String zoneName) {
    return '$zoneName · Fahrzeug nicht zugelassen';
  }

  @override
  String insideZoneName(String zoneName) {
    return 'In $zoneName';
  }

  @override
  String get askAi => 'KI fragen';

  @override
  String get close => 'Schliessen';

  @override
  String get speedCheckApproaching => 'Geschwindigkeitskontrolle voraus';

  @override
  String get cameraCommunity =>
      'Nicht auf der offiziellen Karte · von Fahrern gemeldet';

  @override
  String cameraCommunityLimit(String limit) {
    return 'Limit $limit km/h · von Fahrern gemeldet';
  }

  @override
  String routeZonesCount(int count, String names) {
    return '$count Zone(n): $names';
  }

  @override
  String get recalculatingRoute => 'Route neu berechnen';

  @override
  String stopThenWalk(String distance) {
    return 'Halten, dann $distance zu Fuss';
  }

  @override
  String get walkTowardsDestination => 'Zu Fuss zum Ziel';

  @override
  String towardsDestination(String dest) {
    return 'Richtung $dest';
  }

  @override
  String get routeReady => 'Route bereit';

  @override
  String get noRoute => 'Keine Route';

  @override
  String thenWalk(String distance) {
    return 'Dann $distance zu Fuss';
  }

  @override
  String get premiumActive => 'Premium aktiv';

  @override
  String get complimentaryAccount => 'Gratis-Konto — voller Zugriff';

  @override
  String get premiumUnlockedFeatures =>
      'Milieuzone, Blitzer und EcoEntry freigeschaltet';

  @override
  String get paywallFeatureAlerts => 'Warnungen Milieuzone / LEZ / ZTL';

  @override
  String get paywallFeatureCameras => 'Blitzer, Autovelox und Community';

  @override
  String get paywallFeatureEcoentry => 'EcoEntry, Drop-off, KI, Favoriten, POI';

  @override
  String playBillingLine(String productId, String price) {
    return 'Google Play: $productId · $price €/Monat';
  }

  @override
  String get paywallTrialHintShort =>
      '1,99 €/Monat: Milieuzone, Blitzer, EcoEntry.';

  @override
  String get personalData => 'Persönliche Daten';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Namen eingeben';

  @override
  String get email => 'E-Mail';

  @override
  String get enterValidEmail => 'Gültige E-Mail eingeben';

  @override
  String get newPasswordOptional => 'Neues Passwort (optional)';

  @override
  String get leaveBlankPassword =>
      'Leer lassen, um das aktuelle Passwort zu behalten';

  @override
  String get show => 'Zeigen';

  @override
  String get hide => 'Verbergen';

  @override
  String get atLeast8Chars => 'Mindestens 8 Zeichen';

  @override
  String get navVoice => 'Navigationsstimme';

  @override
  String get voiceMale => 'Männlich';

  @override
  String get voiceFemale => 'Weiblich';

  @override
  String get yourCar => 'Ihr Fahrzeug';

  @override
  String get type => 'Typ';

  @override
  String get fuel => 'Kraftstoff';

  @override
  String get saving => 'Speichern…';

  @override
  String get savePersonalData => 'Persönliche Daten speichern';

  @override
  String get personalDataSaved => 'Persönliche Daten gespeichert';

  @override
  String get savedLocallyServerFailed =>
      'Lokal gespeichert. Server-Update fehlgeschlagen.';

  @override
  String get aiAssistant => 'KI-Assistent';

  @override
  String get aiAssistantSubtitle => 'Fragen zu Zonen, Blitzern und der Route';

  @override
  String get installOnPc => 'Auf diesem PC installieren';

  @override
  String get installOnPcBody =>
      'MilieuAlert als App auf dem Desktop — kein Store oder SDK nötig.';

  @override
  String get signOut => 'Abmelden';

  @override
  String get poiRestaurants => 'Restaurants';

  @override
  String get poiFuel => 'Tankstellen';

  @override
  String get poiTobacco => 'Tabak';

  @override
  String get poiParking => 'Parken';

  @override
  String get poiSupermarket => 'Supermärkte';

  @override
  String get poiCafe => 'Cafés';

  @override
  String get poiPharmacy => 'Apotheken';

  @override
  String get placeHome => 'Zuhause';

  @override
  String get placeWork => 'Arbeit';
}
