// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'MilieuAlert';

  @override
  String alertApproaching(int distance, String zoneName) {
    return 'Attenzione: tra $distance metri entrerai nella $zoneName.';
  }

  @override
  String alertEntering(String zoneName) {
    return 'Stai entrando nella $zoneName.';
  }

  @override
  String alertNotAuthorized(String euroClass, String fuelType) {
    return 'Il tuo veicolo $euroClass $fuelType potrebbe non essere autorizzato a circolare in questa zona.';
  }

  @override
  String get alertAuthorized =>
      'Il tuo veicolo è autorizzato a circolare in questa zona.';

  @override
  String get alertLeaving => 'Zona a basse emissioni terminata.';

  @override
  String get onboardingLanguageTitle => 'Seleziona Lingua';

  @override
  String get onboardingVehicleTitle => 'Configurazione Veicolo';

  @override
  String get vehicleType => 'Tipo di Veicolo';

  @override
  String get fuelType => 'Tipo di Alimentazione';

  @override
  String get euroClass => 'Classe Euro';

  @override
  String get licensePlate => 'Targa (opzionale)';

  @override
  String get country => 'Paese di Immatricolazione';

  @override
  String get next => 'Avanti';

  @override
  String get save => 'Salva';

  @override
  String get saveAndContinue => 'Salva e Continua';

  @override
  String get settings => 'Impostazioni';

  @override
  String get navMap => 'Mappa';

  @override
  String get navNavigation => 'Navigazione';

  @override
  String get alertDistance => 'Distanza di Avviso';

  @override
  String get language => 'Lingua';

  @override
  String get vehicleInfo => 'Informazioni Veicolo';

  @override
  String get editVehicle => 'Modifica Veicolo';

  @override
  String get noVehicleConfigured => 'Nessun veicolo configurato';

  @override
  String get vehicleDescription => 'Parlaci del tuo veicolo';

  @override
  String get vehicleDescriptionSubtext =>
      'Queste informazioni aiutano a determinare se il tuo veicolo è autorizzato nelle zone ambientali.';

  @override
  String get chooseLanguage => 'Scegli la tua lingua preferita';

  @override
  String get zoneDetails => 'Dettagli Zona';

  @override
  String get zoneName => 'Nome Zona';

  @override
  String get zoneCity => 'Città';

  @override
  String get zoneCountry => 'Paese';

  @override
  String get zoneType => 'Tipo di Zona';

  @override
  String get zoneInformation => 'Informazioni Zona';

  @override
  String get zoneNotFound => 'Zona non trovata';

  @override
  String get activeFrom => 'Attiva dal';

  @override
  String get activeTo => 'Attiva fino al';

  @override
  String get activeDays => 'Giorni attivi';

  @override
  String get minimumEuro => 'Classe Euro Minima';

  @override
  String get allowedFuelTypes => 'Tipi di alimentazione consentiti';

  @override
  String get allowedVehicleTypes => 'Tipi di veicolo consentiti';

  @override
  String get restrictions => 'Restrizioni';

  @override
  String get officialSource => 'Fonte Ufficiale';

  @override
  String get lastVerified => 'Ultima Verifica';

  @override
  String get disclaimer =>
      'Risultato informativo. Verifica sempre le regole ufficiali.';

  @override
  String get notGovernmentDisclaimer =>
      'MilieuAlert non è un ente governativo e non è affiliata né autorizzata da alcun governo o comune. Le info milieuzone/ZTL/LEZ sono riepiloghi da fonti pubbliche; verifica sempre sul sito dell\'autorità competente.';

  @override
  String get aboutSection => 'Informazioni';

  @override
  String get officialSourcesSection => 'Fonti ufficiali';

  @override
  String get car => 'Automobile';

  @override
  String get van => 'Furgone';

  @override
  String get truck => 'Camion';

  @override
  String get camper => 'Camper';

  @override
  String get motorcycle => 'Motociclo';

  @override
  String get diesel => 'Diesel';

  @override
  String get petrol => 'Benzina';

  @override
  String get lpg => 'GPL';

  @override
  String get hybrid => 'Ibrido';

  @override
  String get electric => 'Elettrico';

  @override
  String get speed => 'Velocità';

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
  String get environmentalZone => 'Zona Ambientale';

  @override
  String get zeroEmissionZone => 'Zona a Zero Emissioni';

  @override
  String get noZonesNearby => 'Nessuna zona nelle vicinanze';

  @override
  String get syncingZones => 'Sincronizzazione dati zone...';

  @override
  String get syncComplete => 'Dati zone aggiornati';

  @override
  String get syncError => 'Sincronizzazione fallita';

  @override
  String approachingZone(String zoneName, int distance) {
    return 'Avvicinamento a $zoneName - ${distance}m';
  }

  @override
  String insideZoneAuthorized(String zoneName) {
    return 'Dentro $zoneName - Veicolo autorizzato';
  }

  @override
  String insideZoneNotAuthorized(String zoneName) {
    return '⚠ Veicolo NON autorizzato in $zoneName';
  }

  @override
  String get loading => 'Caricamento...';

  @override
  String get error => 'Errore';

  @override
  String get retry => 'Riprova';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String appVersion(String version) {
    return 'MilieuAlert v$version';
  }

  @override
  String get licensePlateHint => 'es. AB-123-CD';

  @override
  String get locationPermissionRequired =>
      'Il permesso di localizzazione è necessario per gli avvisi sulle zone';

  @override
  String get notificationPermissionRequired =>
      'Il permesso di notifica è necessario per gli avvisi sulle zone';

  @override
  String get backgroundLocationRequired =>
      'La localizzazione in background è necessaria per avvisarti durante la guida';

  @override
  String get grantPermission => 'Concedi Permesso';

  @override
  String get locationDisclosureTitle => 'Posizione';

  @override
  String get locationDisclosureBody =>
      'MilieuAlert usa la tua posizione per navigare e avvisarti delle milieuzone, anche quando l\'app è in background o non in uso. Puoi rifiutare.';

  @override
  String get locationDisclosureContinue => 'Continua';

  @override
  String get locationDisclosureDeny => 'Nega';

  @override
  String get paywallExpiredTitle => '15 giorni scaduti';

  @override
  String get paywallExpiredBody =>
      '1,99 euro al mese per sbloccare tutto: milieuzone, autovelox, EcoEntry. Resta il navigatore base (mappa, percorso A-B, heading-up, metri).';

  @override
  String get paywallUnlock => 'Sblocca tutto — 1,99 €/mese';

  @override
  String get paywallTrialTitle => 'Prova 15 giorni';

  @override
  String paywallTrialDays(int days) {
    return 'Prova: $days giorni rimasti';
  }

  @override
  String get paywallTrialHint =>
      'Poi 1,99 €/mese per milieuzone, autovelox, EcoEntry.';

  @override
  String get paywallRedeem => 'Ho un codice / licenza GS';

  @override
  String euro(int level) {
    return 'Euro $level';
  }

  @override
  String get searchPlace => 'Cerca un luogo';

  @override
  String get searchPlaceOrAddress => 'Cerca un luogo o un indirizzo';

  @override
  String get fromMyLocation => 'Da: La mia posizione';

  @override
  String get myLocation => 'La mia posizione';

  @override
  String get useMyLocation => 'Usa la mia posizione';

  @override
  String get swapOriginDestination => 'Inverti A e B';

  @override
  String get go => 'VAI';

  @override
  String get calculating => 'Calcolo…';

  @override
  String get goHint => 'Tocca VAI per partire';

  @override
  String get goHintLez => 'Milieuzone sul percorso — tocca VAI';

  @override
  String get travelCar => 'Auto';

  @override
  String get travelFoot => 'A piedi';

  @override
  String get travelTransit => 'Mezzi';

  @override
  String get noResultsNearby => 'Nessun risultato in zona';

  @override
  String get noZones => 'Nessuna zona';

  @override
  String zonesOnRouteCount(int count) {
    return '$count milieuzone';
  }

  @override
  String get noSpeedCameras => 'Nessun autovelox';

  @override
  String speedCamerasCount(int count) {
    return '$count autovelox';
  }

  @override
  String get lezOnRoute => 'Milieuzone sul percorso';

  @override
  String get lezOnChosenRoute => 'Zona ambientale sul tragitto scelto';

  @override
  String get dropoffRecommended => 'Consigliato: sosta e a piedi';

  @override
  String get places => 'Luoghi';

  @override
  String get recents => 'Recenti';

  @override
  String get itineraries => 'Itinerari';

  @override
  String fromOrigin(String origin) {
    return 'Da $origin';
  }

  @override
  String get environmentalZoneShort => 'Zona ambientale';

  @override
  String get centered => 'Centrato';

  @override
  String get recenter => 'Ricentra';

  @override
  String get overview => 'Panoramica';

  @override
  String get endNav => 'Fine';

  @override
  String get noLezOnRoute => 'Nessuna milieuzone sul percorso';

  @override
  String get routeAvoidsLez => 'Il tragitto evita le LEZ evidenziate';

  @override
  String zonesCountEnvironmental(int count) {
    return '$count zona/e ambientali';
  }

  @override
  String get walkLeg => 'Tratto a piedi';

  @override
  String walkTowards(String dest) {
    return 'Cammina verso $dest';
  }

  @override
  String walkAfterStop(String distance) {
    return '$distance a piedi dopo la sosta';
  }

  @override
  String get destinationGeneric => 'destinazione';

  @override
  String get vehicleNotAuthorized => 'Veicolo non autorizzato';

  @override
  String get vehicleAuthorized => 'Veicolo autorizzato';

  @override
  String get nearbyEnvironmentalZone => 'Zona ambientale vicina';

  @override
  String speedCameraIn(String distance) {
    return 'Autovelox tra $distance';
  }

  @override
  String speedLimitKmh(String limit) {
    return 'Limite $limit km/h';
  }

  @override
  String get speedCheckOnRoute => 'Controllo velocità sul percorso';

  @override
  String camerasOnRoute(int count) {
    return '$count autovelox sul percorso';
  }

  @override
  String get camerasAsPins => 'Mostrati come pin sulla mappa';

  @override
  String get transitNoTransfers => 'Mezzi · senza cambi';

  @override
  String transitTransfers(int count) {
    return 'Mezzi · $count cambio/i';
  }

  @override
  String approachingZoneMeters(int distance) {
    return 'Zona ambientale tra $distance m';
  }

  @override
  String vehicleNotAuthorizedInZone(String zoneName) {
    return '$zoneName · veicolo non autorizzato';
  }

  @override
  String insideZoneName(String zoneName) {
    return 'Dentro $zoneName';
  }

  @override
  String get askAi => 'Chiedi all\'AI';

  @override
  String get close => 'Chiudi';

  @override
  String get speedCheckApproaching => 'Controllo velocità in avvicinamento';

  @override
  String get cameraCommunity =>
      'Non in mappa ufficiale · segnalato da un conducente';

  @override
  String cameraCommunityLimit(String limit) {
    return 'Limite $limit km/h · segnalato da un conducente';
  }

  @override
  String routeZonesCount(int count, String names) {
    return '$count zona/e: $names';
  }

  @override
  String get recalculatingRoute => 'Ricalcolo percorso';

  @override
  String stopThenWalk(String distance) {
    return 'Sosta, poi $distance a piedi';
  }

  @override
  String get walkTowardsDestination => 'Cammina verso destinazione';

  @override
  String towardsDestination(String dest) {
    return 'Verso $dest';
  }

  @override
  String get routeReady => 'Percorso pronto';

  @override
  String get noRoute => 'Nessun percorso';

  @override
  String thenWalk(String distance) {
    return 'Poi $distance a piedi';
  }

  @override
  String get premiumActive => 'Premium attivo';

  @override
  String get complimentaryAccount => 'Account omaggio — accesso completo';

  @override
  String get premiumUnlockedFeatures =>
      'Milieuzone, autovelox, EcoEntry sbloccati';

  @override
  String get paywallFeatureAlerts => 'Allerte milieuzone / LEZ / ZTL';

  @override
  String get paywallFeatureCameras => 'Autovelox, flitsers e community';

  @override
  String get paywallFeatureEcoentry => 'EcoEntry, drop-off, AI, preferiti, POI';

  @override
  String playBillingLine(String productId, String price) {
    return 'Google Play: $productId · $price €/mese';
  }

  @override
  String get paywallTrialHintShort =>
      '1,99 €/mese: milieuzone, autovelox, EcoEntry.';

  @override
  String get personalData => 'Dati personali';

  @override
  String get name => 'Nome';

  @override
  String get enterName => 'Inserisci il tuo nome';

  @override
  String get email => 'Email';

  @override
  String get enterValidEmail => 'Inserisci un\'email valida';

  @override
  String get newPasswordOptional => 'Nuova password (facoltativa)';

  @override
  String get leaveBlankPassword => 'Lascia vuoto per mantenere quella attuale';

  @override
  String get show => 'Mostra';

  @override
  String get hide => 'Nascondi';

  @override
  String get atLeast8Chars => 'Almeno 8 caratteri';

  @override
  String get navVoice => 'Voce navigazione';

  @override
  String get voiceMale => 'Maschile';

  @override
  String get voiceFemale => 'Femminile';

  @override
  String get yourCar => 'Il tuo veicolo';

  @override
  String get type => 'Tipo';

  @override
  String get fuel => 'Alimentazione';

  @override
  String get saving => 'Salvataggio…';

  @override
  String get savePersonalData => 'Salva dati personali';

  @override
  String get personalDataSaved => 'Dati personali salvati';

  @override
  String get savedLocallyServerFailed =>
      'Salvato in locale. Impossibile aggiornare il server.';

  @override
  String get aiAssistant => 'Assistente AI';

  @override
  String get aiAssistantSubtitle => 'Chiedi di zone, autovelox e percorso';

  @override
  String get installOnPc => 'Installa su questo PC';

  @override
  String get installOnPcBody =>
      'Aggiungi MilieuAlert come app sul desktop — nessuno store o SDK richiesto.';

  @override
  String get signOut => 'Esci';

  @override
  String get poiRestaurants => 'Ristoranti';

  @override
  String get poiFuel => 'Pompe di benzina';

  @override
  String get poiTobacco => 'Tabacchi';

  @override
  String get poiParking => 'Parcheggi';

  @override
  String get poiSupermarket => 'Supermercati';

  @override
  String get poiCafe => 'Caffè';

  @override
  String get poiPharmacy => 'Farmacie';

  @override
  String get placeHome => 'Casa';

  @override
  String get placeWork => 'Lavoro';
}
