// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MilieuAlert';

  @override
  String alertApproaching(int distance, String zoneName) {
    return 'Attention : dans $distance metres vous entrerez dans la $zoneName.';
  }

  @override
  String alertEntering(String zoneName) {
    return 'Vous entrez dans la $zoneName.';
  }

  @override
  String alertNotAuthorized(String euroClass, String fuelType) {
    return 'Votre vehicule $euroClass $fuelType pourrait ne pas etre autorise a circuler dans cette zone.';
  }

  @override
  String get alertAuthorized =>
      'Votre vehicule est autorise a circuler dans cette zone.';

  @override
  String get alertLeaving => 'Zone a faibles emissions terminee.';

  @override
  String get onboardingLanguageTitle => 'Choisir la Langue';

  @override
  String get onboardingVehicleTitle => 'Configuration du Vehicule';

  @override
  String get vehicleType => 'Type de Vehicule';

  @override
  String get fuelType => 'Type de Carburant';

  @override
  String get euroClass => 'Classe Euro';

  @override
  String get licensePlate => 'Plaque d\'Immatriculation (optionnel)';

  @override
  String get country => 'Pays d\'Immatriculation';

  @override
  String get next => 'Suivant';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveAndContinue => 'Enregistrer et Continuer';

  @override
  String get settings => 'Parametres';

  @override
  String get navMap => 'Carte';

  @override
  String get navNavigation => 'Navigation';

  @override
  String get alertDistance => 'Distance d\'Alerte';

  @override
  String get language => 'Langue';

  @override
  String get vehicleInfo => 'Informations du Vehicule';

  @override
  String get editVehicle => 'Modifier le Vehicule';

  @override
  String get noVehicleConfigured => 'Aucun vehicule configure';

  @override
  String get vehicleDescription => 'Parlez-nous de votre vehicule';

  @override
  String get vehicleDescriptionSubtext =>
      'Ces informations aident a determiner si votre vehicule est autorise dans les zones environnementales.';

  @override
  String get chooseLanguage => 'Choisissez votre langue preferee';

  @override
  String get zoneDetails => 'Details de la Zone';

  @override
  String get zoneName => 'Nom de la Zone';

  @override
  String get zoneCity => 'Ville';

  @override
  String get zoneCountry => 'Pays';

  @override
  String get zoneType => 'Type de Zone';

  @override
  String get zoneInformation => 'Informations de la Zone';

  @override
  String get zoneNotFound => 'Zone introuvable';

  @override
  String get activeFrom => 'Active Depuis';

  @override
  String get activeTo => 'Active Jusqu\'au';

  @override
  String get activeDays => 'Jours actifs';

  @override
  String get minimumEuro => 'Classe Euro Minimale';

  @override
  String get allowedFuelTypes => 'Types de carburant autorises';

  @override
  String get allowedVehicleTypes => 'Types de vehicule autorises';

  @override
  String get restrictions => 'Restrictions';

  @override
  String get officialSource => 'Source Officielle';

  @override
  String get lastVerified => 'Derniere Verification';

  @override
  String get disclaimer =>
      'Resultat informatif. Verifiez toujours les reglementations officielles.';

  @override
  String get car => 'Voiture';

  @override
  String get van => 'Fourgon';

  @override
  String get truck => 'Camion';

  @override
  String get camper => 'Camping-car';

  @override
  String get motorcycle => 'Moto';

  @override
  String get diesel => 'Diesel';

  @override
  String get petrol => 'Essence';

  @override
  String get lpg => 'GPL';

  @override
  String get hybrid => 'Hybride';

  @override
  String get electric => 'Electrique';

  @override
  String get speed => 'Vitesse';

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
  String get environmentalZone => 'Zone Environnementale';

  @override
  String get zeroEmissionZone => 'Zone Zero Emission';

  @override
  String get noZonesNearby => 'Aucune zone a proximite';

  @override
  String get syncingZones => 'Synchronisation des donnees de zone...';

  @override
  String get syncComplete => 'Donnees de zone mises a jour';

  @override
  String get syncError => 'Echec de la synchronisation';

  @override
  String approachingZone(String zoneName, int distance) {
    return 'Approche de $zoneName - ${distance}m';
  }

  @override
  String insideZoneAuthorized(String zoneName) {
    return 'Dans $zoneName - Vehicule autorise';
  }

  @override
  String insideZoneNotAuthorized(String zoneName) {
    return '⚠ Vehicule NON autorise dans $zoneName';
  }

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Reessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'OK';

  @override
  String appVersion(String version) {
    return 'MilieuAlert v$version';
  }

  @override
  String get licensePlateHint => 'ex. AB-123-CD';

  @override
  String get locationPermissionRequired =>
      'L\'autorisation de localisation est requise pour les alertes de zone';

  @override
  String get notificationPermissionRequired =>
      'L\'autorisation de notification est requise pour les alertes de zone';

  @override
  String get backgroundLocationRequired =>
      'La localisation en arriere-plan est necessaire pour vous alerter pendant la conduite';

  @override
  String get grantPermission => 'Accorder l\'autorisation';

  @override
  String euro(int level) {
    return 'Euro $level';
  }
}
