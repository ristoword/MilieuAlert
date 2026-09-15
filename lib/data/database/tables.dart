import 'package:drift/drift.dart';

@DataClassName('EmissionZoneRow')
class EmissionZones extends Table {
  TextColumn get id => text()();
  TextColumn get country => text()();
  TextColumn get city => text()();
  TextColumn get name => text()();
  TextColumn get zoneType => text()();
  TextColumn get polygonJson => text()();
  DateTimeColumn get activeFrom => dateTime().nullable()();
  DateTimeColumn get activeTo => dateTime().nullable()();
  TextColumn get activeDays => text().nullable()();
  IntColumn get minimumEuroLevel => integer().nullable()();
  TextColumn get allowedFuelTypes => text().nullable()();
  TextColumn get allowedVehicleTypes => text().nullable()();
  TextColumn get restrictions => text().nullable()();
  TextColumn get officialSource => text().nullable()();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VehicleRow')
class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get fuelType => text()();
  TextColumn get euroClass => text()();
  TextColumn get licensePlate => text().nullable()();
  TextColumn get country => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

@DataClassName('UserRow')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get preferredLanguage =>
      text().withDefault(const Constant('en'))();
  TextColumn get country => text().nullable()();
  BoolColumn get isPremium =>
      boolean().withDefault(const Constant(false))();
  TextColumn get subscriptionPlan => text().nullable()();
  DateTimeColumn get subscriptionExpiresAt => dateTime().nullable()();
  BoolColumn get marketingConsent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get dataProcessingConsent =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastActiveAt => dateTime().nullable()();
  TextColumn get referralCode => text().nullable()();
  TextColumn get referredBy => text().nullable()();
}

@DataClassName('UserVehicleRow')
class UserVehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get vehicleType => text()();
  TextColumn get fuelType => text()();
  TextColumn get euroClass => text()();
  TextColumn get licensePlate => text().nullable()();
  TextColumn get vehicleCountry => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  IntColumn get year => integer().nullable()();
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('TripLogRow')
class TripLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable()();
  TextColumn get zoneId => text().nullable()();
  TextColumn get zoneName => text().nullable()();
  TextColumn get eventType => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  BoolColumn get wasAllowed => boolean().nullable()();
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AiConversationRow')
class AiConversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable()();
  TextColumn get sessionId => text()();
  TextColumn get userMessage => text()();
  TextColumn get aiResponse => text()();
  TextColumn get context => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
