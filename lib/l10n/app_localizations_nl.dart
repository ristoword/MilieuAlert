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
    return 'U rijdt de $zoneName in.';
  }

  @override
  String alertNotAuthorized(String euroClass, String fuelType) {
    return 'Uw voertuig $euroClass $fuelType is mogelijk niet toegestaan in deze milieuzone.';
  }

  @override
  String get alertAuthorized => 'Uw voertuig is toegestaan in deze milieuzone.';

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
  String get saveAndContinue => 'Opslaan en doorgaan';

  @override
  String get settings => 'Instellingen';

  @override
  String get navMap => 'Kaart';

  @override
  String get navNavigation => 'Navigatie';

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
      'Hiermee controleren we of uw voertuig is toegestaan in milieuzones.';

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
  String get lastVerified => 'Laatst gecontroleerd';

  @override
  String get disclaimer =>
      'Alleen ter informatie. Controleer altijd de officiële regels.';

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
  String get syncingZones => 'Zonegegevens synchroniseren…';

  @override
  String get syncComplete => 'Zonegegevens bijgewerkt';

  @override
  String get syncError => 'Synchronisatie mislukt';

  @override
  String approachingZone(String zoneName, int distance) {
    return '$zoneName nadert — ${distance}m';
  }

  @override
  String insideZoneAuthorized(String zoneName) {
    return 'In $zoneName — voertuig toegestaan';
  }

  @override
  String insideZoneNotAuthorized(String zoneName) {
    return '⚠ Voertuig NIET toegestaan in $zoneName';
  }

  @override
  String get loading => 'Laden…';

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
      'Achtergrondlocatie is nodig om u tijdens het rijden te waarschuwen';

  @override
  String get grantPermission => 'Toestemming geven';

  @override
  String get paywallExpiredTitle => '15 dagen verlopen';

  @override
  String get paywallExpiredBody =>
      '€2,99 per maand ontgrendelt alles: milieuzone, flitsers, EcoEntry. Basisnavigator blijft (kaart, A–B, heading-up, meters).';

  @override
  String get paywallUnlock => 'Alles ontgrendelen — €2,99/maand';

  @override
  String get paywallTrialTitle => '15 dagen volledige proef';

  @override
  String paywallTrialDays(int days) {
    return 'Proef: nog $days dagen';
  }

  @override
  String get paywallTrialHint =>
      'Daarna €2,99/maand voor milieuzone, flitsers en EcoEntry.';

  @override
  String get paywallRedeem => 'Ik heb een code / GS-licentie';

  @override
  String euro(int level) {
    return 'Euro $level';
  }

  @override
  String get searchPlace => 'Zoek een plaats';

  @override
  String get searchPlaceOrAddress => 'Zoek een plaats of adres';

  @override
  String get fromMyLocation => 'Van: Mijn locatie';

  @override
  String get myLocation => 'Mijn locatie';

  @override
  String get useMyLocation => 'Gebruik mijn locatie';

  @override
  String get swapOriginDestination => 'Wissel A en B';

  @override
  String get go => 'GA';

  @override
  String get calculating => 'Berekenen…';

  @override
  String get goHint => 'Tik op GA om te vertrekken';

  @override
  String get goHintLez => 'Milieuzone op de route — tik op GA';

  @override
  String get travelCar => 'Auto';

  @override
  String get travelFoot => 'Te voet';

  @override
  String get travelTransit => 'OV';

  @override
  String get noResultsNearby => 'Geen resultaten in de buurt';

  @override
  String get noZones => 'Geen zones';

  @override
  String zonesOnRouteCount(int count) {
    return '$count milieuzone';
  }

  @override
  String get noSpeedCameras => 'Geen flitsers';

  @override
  String speedCamerasCount(int count) {
    return '$count flitsers';
  }

  @override
  String get lezOnRoute => 'Milieuzone op de route';

  @override
  String get lezOnChosenRoute => 'Milieuzone op de gekozen route';

  @override
  String get dropoffRecommended => 'Aanbevolen: parkeren en lopen';

  @override
  String get places => 'Plaatsen';

  @override
  String get recents => 'Recent';

  @override
  String get itineraries => 'Routes';

  @override
  String fromOrigin(String origin) {
    return 'Van $origin';
  }

  @override
  String get environmentalZoneShort => 'Milieuzone';

  @override
  String get centered => 'Gecentreerd';

  @override
  String get recenter => 'Opnieuw centreren';

  @override
  String get overview => 'Overzicht';

  @override
  String get endNav => 'Stop';

  @override
  String get noLezOnRoute => 'Geen milieuzone op de route';

  @override
  String get routeAvoidsLez => 'Deze route mijdt de gemarkeerde LEZ';

  @override
  String zonesCountEnvironmental(int count) {
    return '$count milieuzone(s)';
  }

  @override
  String get walkLeg => 'Traject te voet';

  @override
  String walkTowards(String dest) {
    return 'Loop naar $dest';
  }

  @override
  String walkAfterStop(String distance) {
    return '$distance te voet na de stop';
  }

  @override
  String get destinationGeneric => 'bestemming';

  @override
  String get vehicleNotAuthorized => 'Voertuig niet toegestaan';

  @override
  String get vehicleAuthorized => 'Voertuig toegestaan';

  @override
  String get nearbyEnvironmentalZone => 'Milieuzone in de buurt';

  @override
  String speedCameraIn(String distance) {
    return 'Flitser over $distance';
  }

  @override
  String speedLimitKmh(String limit) {
    return 'Limiet $limit km/u';
  }

  @override
  String get speedCheckOnRoute => 'Snelheidscontrole op de resterende route';

  @override
  String camerasOnRoute(int count) {
    return '$count flitsers op de route';
  }

  @override
  String get camerasAsPins => 'Als pin op de kaart';

  @override
  String get transitNoTransfers => 'OV · zonder overstappen';

  @override
  String transitTransfers(int count) {
    return 'OV · $count overstap/stappen';
  }

  @override
  String approachingZoneMeters(int distance) {
    return 'Milieuzone over $distance m';
  }

  @override
  String vehicleNotAuthorizedInZone(String zoneName) {
    return '$zoneName · voertuig niet toegestaan';
  }

  @override
  String insideZoneName(String zoneName) {
    return 'In $zoneName';
  }

  @override
  String get askAi => 'Vraag de AI';

  @override
  String get close => 'Sluiten';

  @override
  String get speedCheckApproaching => 'Snelheidscontrole nadert';

  @override
  String get cameraCommunity =>
      'Niet op de officiële kaart · gemeld door een bestuurder';

  @override
  String cameraCommunityLimit(String limit) {
    return 'Limiet $limit km/u · gemeld door een bestuurder';
  }

  @override
  String routeZonesCount(int count, String names) {
    return '$count zone(s): $names';
  }

  @override
  String get recalculatingRoute => 'Route opnieuw berekenen';

  @override
  String stopThenWalk(String distance) {
    return 'Stoppen, daarna $distance te voet';
  }

  @override
  String get walkTowardsDestination => 'Loop naar de bestemming';

  @override
  String towardsDestination(String dest) {
    return 'Naar $dest';
  }

  @override
  String get routeReady => 'Route klaar';

  @override
  String get noRoute => 'Geen route';

  @override
  String thenWalk(String distance) {
    return 'Daarna $distance te voet';
  }

  @override
  String get premiumActive => 'Premium actief';

  @override
  String get complimentaryAccount => 'Gratis account — volledige toegang';

  @override
  String get premiumUnlockedFeatures =>
      'Milieuzone, flitsers en EcoEntry ontgrendeld';

  @override
  String get paywallFeatureAlerts => 'Meldingen milieuzone / LEZ / ZTL';

  @override
  String get paywallFeatureCameras => 'Flitsers, autovelox en community';

  @override
  String get paywallFeatureEcoentry =>
      'EcoEntry, drop-off, AI, favorieten, POI';

  @override
  String playBillingLine(String productId, String price) {
    return 'Google Play: $productId · €$price/maand';
  }

  @override
  String get paywallTrialHintShort =>
      '€2,99/maand: milieuzone, flitsers, EcoEntry.';

  @override
  String get personalData => 'Persoonsgegevens';

  @override
  String get name => 'Naam';

  @override
  String get enterName => 'Voer uw naam in';

  @override
  String get email => 'E-mail';

  @override
  String get enterValidEmail => 'Voer een geldig e-mailadres in';

  @override
  String get newPasswordOptional => 'Nieuw wachtwoord (optioneel)';

  @override
  String get leaveBlankPassword =>
      'Leeg laten om het huidige wachtwoord te houden';

  @override
  String get show => 'Tonen';

  @override
  String get hide => 'Verbergen';

  @override
  String get atLeast8Chars => 'Minimaal 8 tekens';

  @override
  String get navVoice => 'Navigatiestem';

  @override
  String get voiceMale => 'Mannelijk';

  @override
  String get voiceFemale => 'Vrouwelijk';

  @override
  String get yourCar => 'Uw voertuig';

  @override
  String get type => 'Type';

  @override
  String get fuel => 'Brandstof';

  @override
  String get saving => 'Opslaan…';

  @override
  String get savePersonalData => 'Persoonsgegevens opslaan';

  @override
  String get personalDataSaved => 'Persoonsgegevens opgeslagen';

  @override
  String get savedLocallyServerFailed =>
      'Lokaal opgeslagen. Server bijwerken mislukt.';

  @override
  String get aiAssistant => 'AI-assistent';

  @override
  String get aiAssistantSubtitle => 'Vraag naar zones, flitsers en de route';

  @override
  String get installOnPc => 'Installeren op deze pc';

  @override
  String get installOnPcBody =>
      'Voeg MilieuAlert toe als app op het bureaublad — geen store of SDK nodig.';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get poiRestaurants => 'Restaurants';

  @override
  String get poiFuel => 'Tankstations';

  @override
  String get poiTobacco => 'Tabakszaken';

  @override
  String get poiParking => 'Parkeren';

  @override
  String get poiSupermarket => 'Supermarkten';

  @override
  String get poiCafe => 'Cafés';

  @override
  String get poiPharmacy => 'Apotheken';

  @override
  String get placeHome => 'Thuis';

  @override
  String get placeWork => 'Werk';
}
