import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'MilieuAlert'**
  String get appTitle;

  /// No description provided for @alertApproaching.
  ///
  /// In it, this message translates to:
  /// **'Attenzione: tra {distance} metri entrerai nella {zoneName}.'**
  String alertApproaching(int distance, String zoneName);

  /// No description provided for @alertEntering.
  ///
  /// In it, this message translates to:
  /// **'Stai entrando nella {zoneName}.'**
  String alertEntering(String zoneName);

  /// No description provided for @alertNotAuthorized.
  ///
  /// In it, this message translates to:
  /// **'Il tuo veicolo {euroClass} {fuelType} potrebbe non essere autorizzato a circolare in questa zona.'**
  String alertNotAuthorized(String euroClass, String fuelType);

  /// No description provided for @alertAuthorized.
  ///
  /// In it, this message translates to:
  /// **'Il tuo veicolo è autorizzato a circolare in questa zona.'**
  String get alertAuthorized;

  /// No description provided for @alertLeaving.
  ///
  /// In it, this message translates to:
  /// **'Zona a basse emissioni terminata.'**
  String get alertLeaving;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In it, this message translates to:
  /// **'Seleziona Lingua'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingVehicleTitle.
  ///
  /// In it, this message translates to:
  /// **'Configurazione Veicolo'**
  String get onboardingVehicleTitle;

  /// No description provided for @vehicleType.
  ///
  /// In it, this message translates to:
  /// **'Tipo di Veicolo'**
  String get vehicleType;

  /// No description provided for @fuelType.
  ///
  /// In it, this message translates to:
  /// **'Tipo di Alimentazione'**
  String get fuelType;

  /// No description provided for @euroClass.
  ///
  /// In it, this message translates to:
  /// **'Classe Euro'**
  String get euroClass;

  /// No description provided for @licensePlate.
  ///
  /// In it, this message translates to:
  /// **'Targa (opzionale)'**
  String get licensePlate;

  /// No description provided for @country.
  ///
  /// In it, this message translates to:
  /// **'Paese di Immatricolazione'**
  String get country;

  /// No description provided for @next.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get next;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @saveAndContinue.
  ///
  /// In it, this message translates to:
  /// **'Salva e Continua'**
  String get saveAndContinue;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @navMap.
  ///
  /// In it, this message translates to:
  /// **'Mappa'**
  String get navMap;

  /// No description provided for @navNavigation.
  ///
  /// In it, this message translates to:
  /// **'Navigazione'**
  String get navNavigation;

  /// No description provided for @alertDistance.
  ///
  /// In it, this message translates to:
  /// **'Distanza di Avviso'**
  String get alertDistance;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @vehicleInfo.
  ///
  /// In it, this message translates to:
  /// **'Informazioni Veicolo'**
  String get vehicleInfo;

  /// No description provided for @editVehicle.
  ///
  /// In it, this message translates to:
  /// **'Modifica Veicolo'**
  String get editVehicle;

  /// No description provided for @noVehicleConfigured.
  ///
  /// In it, this message translates to:
  /// **'Nessun veicolo configurato'**
  String get noVehicleConfigured;

  /// No description provided for @vehicleDescription.
  ///
  /// In it, this message translates to:
  /// **'Parlaci del tuo veicolo'**
  String get vehicleDescription;

  /// No description provided for @vehicleDescriptionSubtext.
  ///
  /// In it, this message translates to:
  /// **'Queste informazioni aiutano a determinare se il tuo veicolo è autorizzato nelle zone ambientali.'**
  String get vehicleDescriptionSubtext;

  /// No description provided for @chooseLanguage.
  ///
  /// In it, this message translates to:
  /// **'Scegli la tua lingua preferita'**
  String get chooseLanguage;

  /// No description provided for @zoneDetails.
  ///
  /// In it, this message translates to:
  /// **'Dettagli Zona'**
  String get zoneDetails;

  /// No description provided for @zoneName.
  ///
  /// In it, this message translates to:
  /// **'Nome Zona'**
  String get zoneName;

  /// No description provided for @zoneCity.
  ///
  /// In it, this message translates to:
  /// **'Città'**
  String get zoneCity;

  /// No description provided for @zoneCountry.
  ///
  /// In it, this message translates to:
  /// **'Paese'**
  String get zoneCountry;

  /// No description provided for @zoneType.
  ///
  /// In it, this message translates to:
  /// **'Tipo di Zona'**
  String get zoneType;

  /// No description provided for @zoneInformation.
  ///
  /// In it, this message translates to:
  /// **'Informazioni Zona'**
  String get zoneInformation;

  /// No description provided for @zoneNotFound.
  ///
  /// In it, this message translates to:
  /// **'Zona non trovata'**
  String get zoneNotFound;

  /// No description provided for @activeFrom.
  ///
  /// In it, this message translates to:
  /// **'Attiva dal'**
  String get activeFrom;

  /// No description provided for @activeTo.
  ///
  /// In it, this message translates to:
  /// **'Attiva fino al'**
  String get activeTo;

  /// No description provided for @activeDays.
  ///
  /// In it, this message translates to:
  /// **'Giorni attivi'**
  String get activeDays;

  /// No description provided for @minimumEuro.
  ///
  /// In it, this message translates to:
  /// **'Classe Euro Minima'**
  String get minimumEuro;

  /// No description provided for @allowedFuelTypes.
  ///
  /// In it, this message translates to:
  /// **'Tipi di alimentazione consentiti'**
  String get allowedFuelTypes;

  /// No description provided for @allowedVehicleTypes.
  ///
  /// In it, this message translates to:
  /// **'Tipi di veicolo consentiti'**
  String get allowedVehicleTypes;

  /// No description provided for @restrictions.
  ///
  /// In it, this message translates to:
  /// **'Restrizioni'**
  String get restrictions;

  /// No description provided for @officialSource.
  ///
  /// In it, this message translates to:
  /// **'Fonte Ufficiale'**
  String get officialSource;

  /// No description provided for @lastVerified.
  ///
  /// In it, this message translates to:
  /// **'Ultima Verifica'**
  String get lastVerified;

  /// No description provided for @disclaimer.
  ///
  /// In it, this message translates to:
  /// **'Risultato informativo. Verifica sempre le regole ufficiali.'**
  String get disclaimer;

  /// No description provided for @notGovernmentDisclaimer.
  String get notGovernmentDisclaimer;

  /// No description provided for @aboutSection.
  String get aboutSection;

  /// No description provided for @officialSourcesSection.
  String get officialSourcesSection;

  /// No description provided for @car.
  ///
  /// In it, this message translates to:
  /// **'Automobile'**
  String get car;

  /// No description provided for @van.
  ///
  /// In it, this message translates to:
  /// **'Furgone'**
  String get van;

  /// No description provided for @truck.
  ///
  /// In it, this message translates to:
  /// **'Camion'**
  String get truck;

  /// No description provided for @camper.
  ///
  /// In it, this message translates to:
  /// **'Camper'**
  String get camper;

  /// No description provided for @motorcycle.
  ///
  /// In it, this message translates to:
  /// **'Motociclo'**
  String get motorcycle;

  /// No description provided for @diesel.
  ///
  /// In it, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @petrol.
  ///
  /// In it, this message translates to:
  /// **'Benzina'**
  String get petrol;

  /// No description provided for @lpg.
  ///
  /// In it, this message translates to:
  /// **'GPL'**
  String get lpg;

  /// No description provided for @hybrid.
  ///
  /// In it, this message translates to:
  /// **'Ibrido'**
  String get hybrid;

  /// No description provided for @electric.
  ///
  /// In it, this message translates to:
  /// **'Elettrico'**
  String get electric;

  /// No description provided for @speed.
  ///
  /// In it, this message translates to:
  /// **'Velocità'**
  String get speed;

  /// No description provided for @kmh.
  ///
  /// In it, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// No description provided for @meters.
  ///
  /// In it, this message translates to:
  /// **'{count} m'**
  String meters(int count);

  /// No description provided for @kilometers.
  ///
  /// In it, this message translates to:
  /// **'{count} km'**
  String kilometers(int count);

  /// No description provided for @environmentalZone.
  ///
  /// In it, this message translates to:
  /// **'Zona Ambientale'**
  String get environmentalZone;

  /// No description provided for @zeroEmissionZone.
  ///
  /// In it, this message translates to:
  /// **'Zona a Zero Emissioni'**
  String get zeroEmissionZone;

  /// No description provided for @noZonesNearby.
  ///
  /// In it, this message translates to:
  /// **'Nessuna zona nelle vicinanze'**
  String get noZonesNearby;

  /// No description provided for @syncingZones.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione dati zone...'**
  String get syncingZones;

  /// No description provided for @syncComplete.
  ///
  /// In it, this message translates to:
  /// **'Dati zone aggiornati'**
  String get syncComplete;

  /// No description provided for @syncError.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione fallita'**
  String get syncError;

  /// No description provided for @approachingZone.
  ///
  /// In it, this message translates to:
  /// **'Avvicinamento a {zoneName} - {distance}m'**
  String approachingZone(String zoneName, int distance);

  /// No description provided for @insideZoneAuthorized.
  ///
  /// In it, this message translates to:
  /// **'Dentro {zoneName} - Veicolo autorizzato'**
  String insideZoneAuthorized(String zoneName);

  /// No description provided for @insideZoneNotAuthorized.
  ///
  /// In it, this message translates to:
  /// **'⚠ Veicolo NON autorizzato in {zoneName}'**
  String insideZoneNotAuthorized(String zoneName);

  /// No description provided for @loading.
  ///
  /// In it, this message translates to:
  /// **'Caricamento...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In it, this message translates to:
  /// **'Errore'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In it, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @appVersion.
  ///
  /// In it, this message translates to:
  /// **'MilieuAlert v{version}'**
  String appVersion(String version);

  /// No description provided for @licensePlateHint.
  ///
  /// In it, this message translates to:
  /// **'es. AB-123-CD'**
  String get licensePlateHint;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In it, this message translates to:
  /// **'Il permesso di localizzazione è necessario per gli avvisi sulle zone'**
  String get locationPermissionRequired;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In it, this message translates to:
  /// **'Il permesso di notifica è necessario per gli avvisi sulle zone'**
  String get notificationPermissionRequired;

  /// No description provided for @backgroundLocationRequired.
  ///
  /// In it, this message translates to:
  /// **'La localizzazione in background è necessaria per avvisarti durante la guida'**
  String get backgroundLocationRequired;

  /// No description provided for @grantPermission.
  ///
  /// In it, this message translates to:
  /// **'Concedi Permesso'**
  String get grantPermission;

  /// No description provided for @locationDisclosureTitle.
  ///
  /// In it, this message translates to:
  /// **'Posizione'**
  String get locationDisclosureTitle;

  /// No description provided for @locationDisclosureBody.
  ///
  /// In it, this message translates to:
  /// **'MilieuAlert usa la tua posizione per navigare e avvisarti delle milieuzone, anche quando l\'app è in background o non in uso. Puoi rifiutare.'**
  String get locationDisclosureBody;

  /// No description provided for @locationDisclosureContinue.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get locationDisclosureContinue;

  /// No description provided for @locationDisclosureDeny.
  ///
  /// In it, this message translates to:
  /// **'Nega'**
  String get locationDisclosureDeny;

  /// No description provided for @paywallExpiredTitle.
  ///
  /// In it, this message translates to:
  /// **'15 giorni scaduti'**
  String get paywallExpiredTitle;

  /// No description provided for @paywallExpiredBody.
  ///
  /// In it, this message translates to:
  /// **'2,99 euro al mese per sbloccare tutto: milieuzone, autovelox, EcoEntry. Resta il navigatore base (mappa, percorso A-B, heading-up, metri).'**
  String get paywallExpiredBody;

  /// No description provided for @paywallUnlock.
  ///
  /// In it, this message translates to:
  /// **'Sblocca tutto — 2,99 €/mese'**
  String get paywallUnlock;

  /// No description provided for @paywallTrialTitle.
  ///
  /// In it, this message translates to:
  /// **'Prova 15 giorni'**
  String get paywallTrialTitle;

  /// No description provided for @paywallTrialDays.
  ///
  /// In it, this message translates to:
  /// **'Prova: {days} giorni rimasti'**
  String paywallTrialDays(int days);

  /// No description provided for @paywallTrialHint.
  ///
  /// In it, this message translates to:
  /// **'Poi 2,99 €/mese per milieuzone, autovelox, EcoEntry.'**
  String get paywallTrialHint;

  /// No description provided for @paywallRedeem.
  ///
  /// In it, this message translates to:
  /// **'Ho un codice / licenza GS'**
  String get paywallRedeem;

  /// No description provided for @euro.
  ///
  /// In it, this message translates to:
  /// **'Euro {level}'**
  String euro(int level);

  /// No description provided for @searchPlace.
  ///
  /// In it, this message translates to:
  /// **'Cerca un luogo'**
  String get searchPlace;

  /// No description provided for @searchPlaceOrAddress.
  ///
  /// In it, this message translates to:
  /// **'Cerca un luogo o un indirizzo'**
  String get searchPlaceOrAddress;

  /// No description provided for @fromMyLocation.
  ///
  /// In it, this message translates to:
  /// **'Da: La mia posizione'**
  String get fromMyLocation;

  /// No description provided for @myLocation.
  ///
  /// In it, this message translates to:
  /// **'La mia posizione'**
  String get myLocation;

  /// No description provided for @useMyLocation.
  ///
  /// In it, this message translates to:
  /// **'Usa la mia posizione'**
  String get useMyLocation;

  /// No description provided for @swapOriginDestination.
  ///
  /// In it, this message translates to:
  /// **'Inverti A e B'**
  String get swapOriginDestination;

  /// No description provided for @go.
  ///
  /// In it, this message translates to:
  /// **'VAI'**
  String get go;

  /// No description provided for @calculating.
  ///
  /// In it, this message translates to:
  /// **'Calcolo…'**
  String get calculating;

  /// No description provided for @goHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca VAI per partire'**
  String get goHint;

  /// No description provided for @goHintLez.
  ///
  /// In it, this message translates to:
  /// **'Milieuzone sul percorso — tocca VAI'**
  String get goHintLez;

  /// No description provided for @travelCar.
  ///
  /// In it, this message translates to:
  /// **'Auto'**
  String get travelCar;

  /// No description provided for @travelFoot.
  ///
  /// In it, this message translates to:
  /// **'A piedi'**
  String get travelFoot;

  /// No description provided for @travelTransit.
  ///
  /// In it, this message translates to:
  /// **'Mezzi'**
  String get travelTransit;

  /// No description provided for @noResultsNearby.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato in zona'**
  String get noResultsNearby;

  /// No description provided for @noZones.
  ///
  /// In it, this message translates to:
  /// **'Nessuna zona'**
  String get noZones;

  /// No description provided for @zonesOnRouteCount.
  ///
  /// In it, this message translates to:
  /// **'{count} milieuzone'**
  String zonesOnRouteCount(int count);

  /// No description provided for @noSpeedCameras.
  ///
  /// In it, this message translates to:
  /// **'Nessun autovelox'**
  String get noSpeedCameras;

  /// No description provided for @speedCamerasCount.
  ///
  /// In it, this message translates to:
  /// **'{count} autovelox'**
  String speedCamerasCount(int count);

  /// No description provided for @lezOnRoute.
  ///
  /// In it, this message translates to:
  /// **'Milieuzone sul percorso'**
  String get lezOnRoute;

  /// No description provided for @lezOnChosenRoute.
  ///
  /// In it, this message translates to:
  /// **'Zona ambientale sul tragitto scelto'**
  String get lezOnChosenRoute;

  /// No description provided for @dropoffRecommended.
  ///
  /// In it, this message translates to:
  /// **'Consigliato: sosta e a piedi'**
  String get dropoffRecommended;

  /// No description provided for @places.
  ///
  /// In it, this message translates to:
  /// **'Luoghi'**
  String get places;

  /// No description provided for @recents.
  ///
  /// In it, this message translates to:
  /// **'Recenti'**
  String get recents;

  /// No description provided for @itineraries.
  ///
  /// In it, this message translates to:
  /// **'Itinerari'**
  String get itineraries;

  /// No description provided for @fromOrigin.
  ///
  /// In it, this message translates to:
  /// **'Da {origin}'**
  String fromOrigin(String origin);

  /// No description provided for @environmentalZoneShort.
  ///
  /// In it, this message translates to:
  /// **'Zona ambientale'**
  String get environmentalZoneShort;

  /// No description provided for @centered.
  ///
  /// In it, this message translates to:
  /// **'Centrato'**
  String get centered;

  /// No description provided for @recenter.
  ///
  /// In it, this message translates to:
  /// **'Ricentra'**
  String get recenter;

  /// No description provided for @overview.
  ///
  /// In it, this message translates to:
  /// **'Panoramica'**
  String get overview;

  /// No description provided for @endNav.
  ///
  /// In it, this message translates to:
  /// **'Fine'**
  String get endNav;

  /// No description provided for @noLezOnRoute.
  ///
  /// In it, this message translates to:
  /// **'Nessuna milieuzone sul percorso'**
  String get noLezOnRoute;

  /// No description provided for @routeAvoidsLez.
  ///
  /// In it, this message translates to:
  /// **'Il tragitto evita le LEZ evidenziate'**
  String get routeAvoidsLez;

  /// No description provided for @zonesCountEnvironmental.
  ///
  /// In it, this message translates to:
  /// **'{count} zona/e ambientali'**
  String zonesCountEnvironmental(int count);

  /// No description provided for @walkLeg.
  ///
  /// In it, this message translates to:
  /// **'Tratto a piedi'**
  String get walkLeg;

  /// No description provided for @walkTowards.
  ///
  /// In it, this message translates to:
  /// **'Cammina verso {dest}'**
  String walkTowards(String dest);

  /// No description provided for @walkAfterStop.
  ///
  /// In it, this message translates to:
  /// **'{distance} a piedi dopo la sosta'**
  String walkAfterStop(String distance);

  /// No description provided for @destinationGeneric.
  ///
  /// In it, this message translates to:
  /// **'destinazione'**
  String get destinationGeneric;

  /// No description provided for @vehicleNotAuthorized.
  ///
  /// In it, this message translates to:
  /// **'Veicolo non autorizzato'**
  String get vehicleNotAuthorized;

  /// No description provided for @vehicleAuthorized.
  ///
  /// In it, this message translates to:
  /// **'Veicolo autorizzato'**
  String get vehicleAuthorized;

  /// No description provided for @nearbyEnvironmentalZone.
  ///
  /// In it, this message translates to:
  /// **'Zona ambientale vicina'**
  String get nearbyEnvironmentalZone;

  /// No description provided for @speedCameraIn.
  ///
  /// In it, this message translates to:
  /// **'Autovelox tra {distance}'**
  String speedCameraIn(String distance);

  /// No description provided for @speedLimitKmh.
  ///
  /// In it, this message translates to:
  /// **'Limite {limit} km/h'**
  String speedLimitKmh(String limit);

  /// No description provided for @speedCheckOnRoute.
  ///
  /// In it, this message translates to:
  /// **'Controllo velocità sul percorso'**
  String get speedCheckOnRoute;

  /// No description provided for @camerasOnRoute.
  ///
  /// In it, this message translates to:
  /// **'{count} autovelox sul percorso'**
  String camerasOnRoute(int count);

  /// No description provided for @camerasAsPins.
  ///
  /// In it, this message translates to:
  /// **'Mostrati come pin sulla mappa'**
  String get camerasAsPins;

  /// No description provided for @transitNoTransfers.
  ///
  /// In it, this message translates to:
  /// **'Mezzi · senza cambi'**
  String get transitNoTransfers;

  /// No description provided for @transitTransfers.
  ///
  /// In it, this message translates to:
  /// **'Mezzi · {count} cambio/i'**
  String transitTransfers(int count);

  /// No description provided for @approachingZoneMeters.
  ///
  /// In it, this message translates to:
  /// **'Zona ambientale tra {distance} m'**
  String approachingZoneMeters(int distance);

  /// No description provided for @vehicleNotAuthorizedInZone.
  ///
  /// In it, this message translates to:
  /// **'{zoneName} · veicolo non autorizzato'**
  String vehicleNotAuthorizedInZone(String zoneName);

  /// No description provided for @insideZoneName.
  ///
  /// In it, this message translates to:
  /// **'Dentro {zoneName}'**
  String insideZoneName(String zoneName);

  /// No description provided for @askAi.
  ///
  /// In it, this message translates to:
  /// **'Chiedi all\'AI'**
  String get askAi;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @speedCheckApproaching.
  ///
  /// In it, this message translates to:
  /// **'Controllo velocità in avvicinamento'**
  String get speedCheckApproaching;

  /// No description provided for @cameraCommunity.
  ///
  /// In it, this message translates to:
  /// **'Non in mappa ufficiale · segnalato da un conducente'**
  String get cameraCommunity;

  /// No description provided for @cameraCommunityLimit.
  ///
  /// In it, this message translates to:
  /// **'Limite {limit} km/h · segnalato da un conducente'**
  String cameraCommunityLimit(String limit);

  /// No description provided for @routeZonesCount.
  ///
  /// In it, this message translates to:
  /// **'{count} zona/e: {names}'**
  String routeZonesCount(int count, String names);

  /// No description provided for @recalculatingRoute.
  ///
  /// In it, this message translates to:
  /// **'Ricalcolo percorso'**
  String get recalculatingRoute;

  /// No description provided for @stopThenWalk.
  ///
  /// In it, this message translates to:
  /// **'Sosta, poi {distance} a piedi'**
  String stopThenWalk(String distance);

  /// No description provided for @walkTowardsDestination.
  ///
  /// In it, this message translates to:
  /// **'Cammina verso destinazione'**
  String get walkTowardsDestination;

  /// No description provided for @towardsDestination.
  ///
  /// In it, this message translates to:
  /// **'Verso {dest}'**
  String towardsDestination(String dest);

  /// No description provided for @routeReady.
  ///
  /// In it, this message translates to:
  /// **'Percorso pronto'**
  String get routeReady;

  /// No description provided for @noRoute.
  ///
  /// In it, this message translates to:
  /// **'Nessun percorso'**
  String get noRoute;

  /// No description provided for @thenWalk.
  ///
  /// In it, this message translates to:
  /// **'Poi {distance} a piedi'**
  String thenWalk(String distance);

  /// No description provided for @premiumActive.
  ///
  /// In it, this message translates to:
  /// **'Premium attivo'**
  String get premiumActive;

  /// No description provided for @complimentaryAccount.
  ///
  /// In it, this message translates to:
  /// **'Account omaggio — accesso completo'**
  String get complimentaryAccount;

  /// No description provided for @premiumUnlockedFeatures.
  ///
  /// In it, this message translates to:
  /// **'Milieuzone, autovelox, EcoEntry sbloccati'**
  String get premiumUnlockedFeatures;

  /// No description provided for @paywallFeatureAlerts.
  ///
  /// In it, this message translates to:
  /// **'Allerte milieuzone / LEZ / ZTL'**
  String get paywallFeatureAlerts;

  /// No description provided for @paywallFeatureCameras.
  ///
  /// In it, this message translates to:
  /// **'Autovelox, flitsers e community'**
  String get paywallFeatureCameras;

  /// No description provided for @paywallFeatureEcoentry.
  ///
  /// In it, this message translates to:
  /// **'EcoEntry, drop-off, AI, preferiti, POI'**
  String get paywallFeatureEcoentry;

  /// No description provided for @playBillingLine.
  ///
  /// In it, this message translates to:
  /// **'Google Play: {productId} · {price} €/mese'**
  String playBillingLine(String productId, String price);

  /// No description provided for @paywallTrialHintShort.
  ///
  /// In it, this message translates to:
  /// **'2,99 €/mese: milieuzone, autovelox, EcoEntry.'**
  String get paywallTrialHintShort;

  /// No description provided for @personalData.
  ///
  /// In it, this message translates to:
  /// **'Dati personali'**
  String get personalData;

  /// No description provided for @name.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il tuo nome'**
  String get enterName;

  /// No description provided for @email.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterValidEmail.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un\'email valida'**
  String get enterValidEmail;

  /// No description provided for @newPasswordOptional.
  ///
  /// In it, this message translates to:
  /// **'Nuova password (facoltativa)'**
  String get newPasswordOptional;

  /// No description provided for @leaveBlankPassword.
  ///
  /// In it, this message translates to:
  /// **'Lascia vuoto per mantenere quella attuale'**
  String get leaveBlankPassword;

  /// No description provided for @show.
  ///
  /// In it, this message translates to:
  /// **'Mostra'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In it, this message translates to:
  /// **'Nascondi'**
  String get hide;

  /// No description provided for @atLeast8Chars.
  ///
  /// In it, this message translates to:
  /// **'Almeno 8 caratteri'**
  String get atLeast8Chars;

  /// No description provided for @navVoice.
  ///
  /// In it, this message translates to:
  /// **'Voce navigazione'**
  String get navVoice;

  /// No description provided for @voiceMale.
  ///
  /// In it, this message translates to:
  /// **'Maschile'**
  String get voiceMale;

  /// No description provided for @voiceFemale.
  ///
  /// In it, this message translates to:
  /// **'Femminile'**
  String get voiceFemale;

  /// No description provided for @yourCar.
  ///
  /// In it, this message translates to:
  /// **'Il tuo veicolo'**
  String get yourCar;

  /// No description provided for @type.
  ///
  /// In it, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @fuel.
  ///
  /// In it, this message translates to:
  /// **'Alimentazione'**
  String get fuel;

  /// No description provided for @saving.
  ///
  /// In it, this message translates to:
  /// **'Salvataggio…'**
  String get saving;

  /// No description provided for @savePersonalData.
  ///
  /// In it, this message translates to:
  /// **'Salva dati personali'**
  String get savePersonalData;

  /// No description provided for @personalDataSaved.
  ///
  /// In it, this message translates to:
  /// **'Dati personali salvati'**
  String get personalDataSaved;

  /// No description provided for @savedLocallyServerFailed.
  ///
  /// In it, this message translates to:
  /// **'Salvato in locale. Impossibile aggiornare il server.'**
  String get savedLocallyServerFailed;

  /// No description provided for @aiAssistant.
  ///
  /// In it, this message translates to:
  /// **'Assistente AI'**
  String get aiAssistant;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Chiedi di zone, autovelox e percorso'**
  String get aiAssistantSubtitle;

  /// No description provided for @installOnPc.
  ///
  /// In it, this message translates to:
  /// **'Installa su questo PC'**
  String get installOnPc;

  /// No description provided for @installOnPcBody.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi MilieuAlert come app sul desktop — nessuno store o SDK richiesto.'**
  String get installOnPcBody;

  /// No description provided for @signOut.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get signOut;

  /// No description provided for @poiRestaurants.
  ///
  /// In it, this message translates to:
  /// **'Ristoranti'**
  String get poiRestaurants;

  /// No description provided for @poiFuel.
  ///
  /// In it, this message translates to:
  /// **'Pompe di benzina'**
  String get poiFuel;

  /// No description provided for @poiTobacco.
  ///
  /// In it, this message translates to:
  /// **'Tabacchi'**
  String get poiTobacco;

  /// No description provided for @poiParking.
  ///
  /// In it, this message translates to:
  /// **'Parcheggi'**
  String get poiParking;

  /// No description provided for @poiSupermarket.
  ///
  /// In it, this message translates to:
  /// **'Supermercati'**
  String get poiSupermarket;

  /// No description provided for @poiCafe.
  ///
  /// In it, this message translates to:
  /// **'Caffè'**
  String get poiCafe;

  /// No description provided for @poiPharmacy.
  ///
  /// In it, this message translates to:
  /// **'Farmacie'**
  String get poiPharmacy;

  /// No description provided for @placeHome.
  ///
  /// In it, this message translates to:
  /// **'Casa'**
  String get placeHome;

  /// No description provided for @placeWork.
  ///
  /// In it, this message translates to:
  /// **'Lavoro'**
  String get placeWork;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'it', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
