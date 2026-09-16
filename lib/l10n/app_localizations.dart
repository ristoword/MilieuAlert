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
  /// In en, this message translates to:
  /// **'MilieuAlert'**
  String get appTitle;

  /// No description provided for @alertApproaching.
  ///
  /// In en, this message translates to:
  /// **'Warning: in {distance} metres you will enter the {zoneName}.'**
  String alertApproaching(int distance, String zoneName);

  /// No description provided for @alertEntering.
  ///
  /// In en, this message translates to:
  /// **'You are entering the {zoneName}.'**
  String alertEntering(String zoneName);

  /// No description provided for @alertNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle {euroClass} {fuelType} may not be authorized to drive in this zone.'**
  String alertNotAuthorized(String euroClass, String fuelType);

  /// No description provided for @alertAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle is authorized to drive in this zone.'**
  String get alertAuthorized;

  /// No description provided for @alertLeaving.
  ///
  /// In en, this message translates to:
  /// **'Low emission zone ended.'**
  String get alertLeaving;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Setup'**
  String get onboardingVehicleTitle;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fuelType;

  /// No description provided for @euroClass.
  ///
  /// In en, this message translates to:
  /// **'Euro Class'**
  String get euroClass;

  /// No description provided for @licensePlate.
  ///
  /// In en, this message translates to:
  /// **'License Plate (optional)'**
  String get licensePlate;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country of Registration'**
  String get country;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navNavigation;

  /// No description provided for @alertDistance.
  ///
  /// In en, this message translates to:
  /// **'Alert Distance'**
  String get alertDistance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfo;

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicle;

  /// No description provided for @noVehicleConfigured.
  ///
  /// In en, this message translates to:
  /// **'No vehicle configured'**
  String get noVehicleConfigured;

  /// No description provided for @vehicleDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your vehicle'**
  String get vehicleDescription;

  /// No description provided for @vehicleDescriptionSubtext.
  ///
  /// In en, this message translates to:
  /// **'This information helps determine if your vehicle is allowed in emission zones.'**
  String get vehicleDescriptionSubtext;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @zoneDetails.
  ///
  /// In en, this message translates to:
  /// **'Zone Details'**
  String get zoneDetails;

  /// No description provided for @zoneName.
  ///
  /// In en, this message translates to:
  /// **'Zone Name'**
  String get zoneName;

  /// No description provided for @zoneCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get zoneCity;

  /// No description provided for @zoneCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get zoneCountry;

  /// No description provided for @zoneType.
  ///
  /// In en, this message translates to:
  /// **'Zone Type'**
  String get zoneType;

  /// No description provided for @zoneInformation.
  ///
  /// In en, this message translates to:
  /// **'Zone Information'**
  String get zoneInformation;

  /// No description provided for @zoneNotFound.
  ///
  /// In en, this message translates to:
  /// **'Zone not found'**
  String get zoneNotFound;

  /// No description provided for @activeFrom.
  ///
  /// In en, this message translates to:
  /// **'Active From'**
  String get activeFrom;

  /// No description provided for @activeTo.
  ///
  /// In en, this message translates to:
  /// **'Active To'**
  String get activeTo;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get activeDays;

  /// No description provided for @minimumEuro.
  ///
  /// In en, this message translates to:
  /// **'Minimum Euro Class'**
  String get minimumEuro;

  /// No description provided for @allowedFuelTypes.
  ///
  /// In en, this message translates to:
  /// **'Allowed Fuel Types'**
  String get allowedFuelTypes;

  /// No description provided for @allowedVehicleTypes.
  ///
  /// In en, this message translates to:
  /// **'Allowed Vehicle Types'**
  String get allowedVehicleTypes;

  /// No description provided for @restrictions.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get restrictions;

  /// No description provided for @officialSource.
  ///
  /// In en, this message translates to:
  /// **'Official Source'**
  String get officialSource;

  /// No description provided for @lastVerified.
  ///
  /// In en, this message translates to:
  /// **'Last Verified'**
  String get lastVerified;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Informational result. Always verify official regulations.'**
  String get disclaimer;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @van.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get van;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @camper.
  ///
  /// In en, this message translates to:
  /// **'Camper'**
  String get camper;

  /// No description provided for @motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// No description provided for @diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @petrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get petrol;

  /// No description provided for @lpg.
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get lpg;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @kmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'{count} m'**
  String meters(int count);

  /// No description provided for @kilometers.
  ///
  /// In en, this message translates to:
  /// **'{count} km'**
  String kilometers(int count);

  /// No description provided for @environmentalZone.
  ///
  /// In en, this message translates to:
  /// **'Environmental Zone'**
  String get environmentalZone;

  /// No description provided for @zeroEmissionZone.
  ///
  /// In en, this message translates to:
  /// **'Zero Emission Zone'**
  String get zeroEmissionZone;

  /// No description provided for @noZonesNearby.
  ///
  /// In en, this message translates to:
  /// **'No zones nearby'**
  String get noZonesNearby;

  /// No description provided for @syncingZones.
  ///
  /// In en, this message translates to:
  /// **'Syncing zone data...'**
  String get syncingZones;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'Zone data updated'**
  String get syncComplete;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update zone data'**
  String get syncError;

  /// No description provided for @approachingZone.
  ///
  /// In en, this message translates to:
  /// **'Approaching {zoneName} - {distance}m'**
  String approachingZone(String zoneName, int distance);

  /// No description provided for @insideZoneAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Inside {zoneName} - Vehicle authorized'**
  String insideZoneAuthorized(String zoneName);

  /// No description provided for @insideZoneNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'⚠ Vehicle NOT authorized in {zoneName}'**
  String insideZoneNotAuthorized(String zoneName);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'MilieuAlert v{version}'**
  String appVersion(String version);

  /// No description provided for @licensePlateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AB-123-CD'**
  String get licensePlateHint;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for zone alerts'**
  String get locationPermissionRequired;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required for zone alerts'**
  String get notificationPermissionRequired;

  /// No description provided for @backgroundLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Background location is needed to alert you while driving'**
  String get backgroundLocationRequired;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @euro.
  ///
  /// In en, this message translates to:
  /// **'Euro {level}'**
  String euro(int level);
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
