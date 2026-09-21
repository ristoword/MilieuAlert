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
  String get notGovernmentDisclaimer =>
      'MilieuAlert n\'est pas une entité gouvernementale et n\'est ni affiliée ni autorisée par un gouvernement ou une commune. Les infos milieuzone/ZTL/LEZ sont des résumés de sources publiques ; vérifiez toujours sur le site de l\'autorité compétente.';

  @override
  String get aboutSection => 'À propos';

  @override
  String get officialSourcesSection => 'Sources officielles';

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
  String get locationDisclosureTitle => 'Position';

  @override
  String get locationDisclosureBody =>
      'MilieuAlert utilise votre position pour naviguer et vous avertir des milieuzones, y compris en arrière-plan ou lorsque l\'application n\'est pas utilisée. Vous pouvez refuser.';

  @override
  String get locationDisclosureContinue => 'Continuer';

  @override
  String get locationDisclosureDeny => 'Refuser';

  @override
  String get paywallExpiredTitle => '15 jours expirés';

  @override
  String get paywallExpiredBody =>
      '2,99 € par mois pour tout débloquer : milieuzone, autovelox, EcoEntry. Le navigateur de base reste (carte, A-B, heading-up, mètres).';

  @override
  String get paywallUnlock => 'Tout débloquer — 2,99 €/mois';

  @override
  String get paywallTrialTitle => 'Essai 15 jours';

  @override
  String paywallTrialDays(int days) {
    return 'Essai : $days jours restants';
  }

  @override
  String get paywallTrialHint =>
      'Puis 2,99 €/mois pour milieuzone, autovelox et EcoEntry.';

  @override
  String get paywallRedeem => 'J’ai un code / licence GS';

  @override
  String euro(int level) {
    return 'Euro $level';
  }

  @override
  String get searchPlace => 'Rechercher un lieu';

  @override
  String get searchPlaceOrAddress => 'Rechercher un lieu ou une adresse';

  @override
  String get fromMyLocation => 'De : Ma position';

  @override
  String get myLocation => 'Ma position';

  @override
  String get useMyLocation => 'Utiliser ma position';

  @override
  String get swapOriginDestination => 'Inverser A et B';

  @override
  String get go => 'GO';

  @override
  String get calculating => 'Calcul…';

  @override
  String get goHint => 'Touchez GO pour partir';

  @override
  String get goHintLez => 'Milieuzone sur l’itinéraire — touchez GO';

  @override
  String get travelCar => 'Voiture';

  @override
  String get travelFoot => 'À pied';

  @override
  String get travelTransit => 'Transports';

  @override
  String get noResultsNearby => 'Aucun résultat à proximité';

  @override
  String get noZones => 'Aucune zone';

  @override
  String zonesOnRouteCount(int count) {
    return '$count milieuzone';
  }

  @override
  String get noSpeedCameras => 'Aucun radar';

  @override
  String speedCamerasCount(int count) {
    return '$count radars';
  }

  @override
  String get lezOnRoute => 'Milieuzone sur l’itinéraire';

  @override
  String get lezOnChosenRoute => 'Zone environnementale sur le trajet choisi';

  @override
  String get dropoffRecommended => 'Conseillé : stationner puis marcher';

  @override
  String get places => 'Lieux';

  @override
  String get recents => 'Récents';

  @override
  String get itineraries => 'Itinéraires';

  @override
  String fromOrigin(String origin) {
    return 'De $origin';
  }

  @override
  String get environmentalZoneShort => 'Zone environnementale';

  @override
  String get centered => 'Centré';

  @override
  String get recenter => 'Recentrer';

  @override
  String get overview => 'Aperçu';

  @override
  String get endNav => 'Fin';

  @override
  String get noLezOnRoute => 'Aucune milieuzone sur l’itinéraire';

  @override
  String get routeAvoidsLez => 'L’itinéraire évite les LEZ signalées';

  @override
  String zonesCountEnvironmental(int count) {
    return '$count zone(s) environnementale(s)';
  }

  @override
  String get walkLeg => 'Tronçon à pied';

  @override
  String walkTowards(String dest) {
    return 'Marcher vers $dest';
  }

  @override
  String walkAfterStop(String distance) {
    return '$distance à pied après l’arrêt';
  }

  @override
  String get destinationGeneric => 'destination';

  @override
  String get vehicleNotAuthorized => 'Véhicule non autorisé';

  @override
  String get vehicleAuthorized => 'Véhicule autorisé';

  @override
  String get nearbyEnvironmentalZone => 'Zone environnementale proche';

  @override
  String speedCameraIn(String distance) {
    return 'Radar dans $distance';
  }

  @override
  String speedLimitKmh(String limit) {
    return 'Limite $limit km/h';
  }

  @override
  String get speedCheckOnRoute => 'Contrôle de vitesse sur le trajet restant';

  @override
  String camerasOnRoute(int count) {
    return '$count radars sur l’itinéraire';
  }

  @override
  String get camerasAsPins => 'Affichés comme épingles sur la carte';

  @override
  String get transitNoTransfers => 'Transports · sans correspondance';

  @override
  String transitTransfers(int count) {
    return 'Transports · $count correspondance(s)';
  }

  @override
  String approachingZoneMeters(int distance) {
    return 'Zone environnementale dans $distance m';
  }

  @override
  String vehicleNotAuthorizedInZone(String zoneName) {
    return '$zoneName · véhicule non autorisé';
  }

  @override
  String insideZoneName(String zoneName) {
    return 'Dans $zoneName';
  }

  @override
  String get askAi => 'Demander à l’IA';

  @override
  String get close => 'Fermer';

  @override
  String get speedCheckApproaching => 'Contrôle de vitesse en approche';

  @override
  String get cameraCommunity =>
      'Hors carte officielle · signalé par un conducteur';

  @override
  String cameraCommunityLimit(String limit) {
    return 'Limite $limit km/h · signalé par un conducteur';
  }

  @override
  String routeZonesCount(int count, String names) {
    return '$count zone(s) : $names';
  }

  @override
  String get recalculatingRoute => 'Recalcul de l’itinéraire';

  @override
  String stopThenWalk(String distance) {
    return 'Arrêt, puis $distance à pied';
  }

  @override
  String get walkTowardsDestination => 'Marcher vers la destination';

  @override
  String towardsDestination(String dest) {
    return 'Vers $dest';
  }

  @override
  String get routeReady => 'Itinéraire prêt';

  @override
  String get noRoute => 'Aucun itinéraire';

  @override
  String thenWalk(String distance) {
    return 'Puis $distance à pied';
  }

  @override
  String get premiumActive => 'Premium actif';

  @override
  String get complimentaryAccount => 'Compte offert — accès complet';

  @override
  String get premiumUnlockedFeatures =>
      'Milieuzone, autovelox et EcoEntry débloqués';

  @override
  String get paywallFeatureAlerts => 'Alertes milieuzone / LEZ / ZTL';

  @override
  String get paywallFeatureCameras => 'Autovelox, flitsers et communauté';

  @override
  String get paywallFeatureEcoentry => 'EcoEntry, drop-off, IA, favoris, POI';

  @override
  String playBillingLine(String productId, String price) {
    return 'Google Play : $productId · $price €/mois';
  }

  @override
  String get paywallTrialHintShort =>
      '2,99 €/mois : milieuzone, autovelox, EcoEntry.';

  @override
  String get personalData => 'Données personnelles';

  @override
  String get name => 'Nom';

  @override
  String get enterName => 'Saisissez votre nom';

  @override
  String get email => 'E-mail';

  @override
  String get enterValidEmail => 'Saisissez un e-mail valide';

  @override
  String get newPasswordOptional => 'Nouveau mot de passe (facultatif)';

  @override
  String get leaveBlankPassword =>
      'Laisser vide pour conserver le mot de passe actuel';

  @override
  String get show => 'Afficher';

  @override
  String get hide => 'Masquer';

  @override
  String get atLeast8Chars => 'Au moins 8 caractères';

  @override
  String get navVoice => 'Voix de navigation';

  @override
  String get voiceMale => 'Masculine';

  @override
  String get voiceFemale => 'Féminine';

  @override
  String get yourCar => 'Votre véhicule';

  @override
  String get type => 'Type';

  @override
  String get fuel => 'Carburant';

  @override
  String get saving => 'Enregistrement…';

  @override
  String get savePersonalData => 'Enregistrer les données personnelles';

  @override
  String get personalDataSaved => 'Données personnelles enregistrées';

  @override
  String get savedLocallyServerFailed =>
      'Enregistré en local. Impossible de mettre à jour le serveur.';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get aiAssistantSubtitle =>
      'Questions sur les zones, radars et l’itinéraire';

  @override
  String get installOnPc => 'Installer sur ce PC';

  @override
  String get installOnPcBody =>
      'Ajoutez MilieuAlert comme application bureau — aucun store ni SDK.';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get poiRestaurants => 'Restaurants';

  @override
  String get poiFuel => 'Stations-service';

  @override
  String get poiTobacco => 'Tabacs';

  @override
  String get poiParking => 'Parkings';

  @override
  String get poiSupermarket => 'Supermarchés';

  @override
  String get poiCafe => 'Cafés';

  @override
  String get poiPharmacy => 'Pharmacies';

  @override
  String get placeHome => 'Maison';

  @override
  String get placeWork => 'Travail';
}
