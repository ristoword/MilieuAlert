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
  String euro(int level) {
    return 'Euro $level';
  }
}
