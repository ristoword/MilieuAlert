// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EmissionZonesTable extends EmissionZones
    with TableInfo<$EmissionZonesTable, EmissionZoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmissionZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneTypeMeta = const VerificationMeta(
    'zoneType',
  );
  @override
  late final GeneratedColumn<String> zoneType = GeneratedColumn<String>(
    'zone_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _polygonJsonMeta = const VerificationMeta(
    'polygonJson',
  );
  @override
  late final GeneratedColumn<String> polygonJson = GeneratedColumn<String>(
    'polygon_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeFromMeta = const VerificationMeta(
    'activeFrom',
  );
  @override
  late final GeneratedColumn<DateTime> activeFrom = GeneratedColumn<DateTime>(
    'active_from',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeToMeta = const VerificationMeta(
    'activeTo',
  );
  @override
  late final GeneratedColumn<DateTime> activeTo = GeneratedColumn<DateTime>(
    'active_to',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeDaysMeta = const VerificationMeta(
    'activeDays',
  );
  @override
  late final GeneratedColumn<String> activeDays = GeneratedColumn<String>(
    'active_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minimumEuroLevelMeta = const VerificationMeta(
    'minimumEuroLevel',
  );
  @override
  late final GeneratedColumn<int> minimumEuroLevel = GeneratedColumn<int>(
    'minimum_euro_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allowedFuelTypesMeta = const VerificationMeta(
    'allowedFuelTypes',
  );
  @override
  late final GeneratedColumn<String> allowedFuelTypes = GeneratedColumn<String>(
    'allowed_fuel_types',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allowedVehicleTypesMeta =
      const VerificationMeta('allowedVehicleTypes');
  @override
  late final GeneratedColumn<String> allowedVehicleTypes =
      GeneratedColumn<String>(
        'allowed_vehicle_types',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _restrictionsMeta = const VerificationMeta(
    'restrictions',
  );
  @override
  late final GeneratedColumn<String> restrictions = GeneratedColumn<String>(
    'restrictions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _officialSourceMeta = const VerificationMeta(
    'officialSource',
  );
  @override
  late final GeneratedColumn<String> officialSource = GeneratedColumn<String>(
    'official_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>(
        'last_verified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    country,
    city,
    name,
    zoneType,
    polygonJson,
    activeFrom,
    activeTo,
    activeDays,
    minimumEuroLevel,
    allowedFuelTypes,
    allowedVehicleTypes,
    restrictions,
    officialSource,
    lastVerifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emission_zones';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmissionZoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('zone_type')) {
      context.handle(
        _zoneTypeMeta,
        zoneType.isAcceptableOrUnknown(data['zone_type']!, _zoneTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneTypeMeta);
    }
    if (data.containsKey('polygon_json')) {
      context.handle(
        _polygonJsonMeta,
        polygonJson.isAcceptableOrUnknown(
          data['polygon_json']!,
          _polygonJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_polygonJsonMeta);
    }
    if (data.containsKey('active_from')) {
      context.handle(
        _activeFromMeta,
        activeFrom.isAcceptableOrUnknown(data['active_from']!, _activeFromMeta),
      );
    }
    if (data.containsKey('active_to')) {
      context.handle(
        _activeToMeta,
        activeTo.isAcceptableOrUnknown(data['active_to']!, _activeToMeta),
      );
    }
    if (data.containsKey('active_days')) {
      context.handle(
        _activeDaysMeta,
        activeDays.isAcceptableOrUnknown(data['active_days']!, _activeDaysMeta),
      );
    }
    if (data.containsKey('minimum_euro_level')) {
      context.handle(
        _minimumEuroLevelMeta,
        minimumEuroLevel.isAcceptableOrUnknown(
          data['minimum_euro_level']!,
          _minimumEuroLevelMeta,
        ),
      );
    }
    if (data.containsKey('allowed_fuel_types')) {
      context.handle(
        _allowedFuelTypesMeta,
        allowedFuelTypes.isAcceptableOrUnknown(
          data['allowed_fuel_types']!,
          _allowedFuelTypesMeta,
        ),
      );
    }
    if (data.containsKey('allowed_vehicle_types')) {
      context.handle(
        _allowedVehicleTypesMeta,
        allowedVehicleTypes.isAcceptableOrUnknown(
          data['allowed_vehicle_types']!,
          _allowedVehicleTypesMeta,
        ),
      );
    }
    if (data.containsKey('restrictions')) {
      context.handle(
        _restrictionsMeta,
        restrictions.isAcceptableOrUnknown(
          data['restrictions']!,
          _restrictionsMeta,
        ),
      );
    }
    if (data.containsKey('official_source')) {
      context.handle(
        _officialSourceMeta,
        officialSource.isAcceptableOrUnknown(
          data['official_source']!,
          _officialSourceMeta,
        ),
      );
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmissionZoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmissionZoneRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      zoneType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_type'],
      )!,
      polygonJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polygon_json'],
      )!,
      activeFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}active_from'],
      ),
      activeTo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}active_to'],
      ),
      activeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_days'],
      ),
      minimumEuroLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_euro_level'],
      ),
      allowedFuelTypes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allowed_fuel_types'],
      ),
      allowedVehicleTypes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allowed_vehicle_types'],
      ),
      restrictions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restrictions'],
      ),
      officialSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}official_source'],
      ),
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_verified_at'],
      ),
    );
  }

  @override
  $EmissionZonesTable createAlias(String alias) {
    return $EmissionZonesTable(attachedDatabase, alias);
  }
}

class EmissionZoneRow extends DataClass implements Insertable<EmissionZoneRow> {
  final String id;
  final String country;
  final String city;
  final String name;
  final String zoneType;
  final String polygonJson;
  final DateTime? activeFrom;
  final DateTime? activeTo;
  final String? activeDays;
  final int? minimumEuroLevel;
  final String? allowedFuelTypes;
  final String? allowedVehicleTypes;
  final String? restrictions;
  final String? officialSource;
  final DateTime? lastVerifiedAt;
  const EmissionZoneRow({
    required this.id,
    required this.country,
    required this.city,
    required this.name,
    required this.zoneType,
    required this.polygonJson,
    this.activeFrom,
    this.activeTo,
    this.activeDays,
    this.minimumEuroLevel,
    this.allowedFuelTypes,
    this.allowedVehicleTypes,
    this.restrictions,
    this.officialSource,
    this.lastVerifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['country'] = Variable<String>(country);
    map['city'] = Variable<String>(city);
    map['name'] = Variable<String>(name);
    map['zone_type'] = Variable<String>(zoneType);
    map['polygon_json'] = Variable<String>(polygonJson);
    if (!nullToAbsent || activeFrom != null) {
      map['active_from'] = Variable<DateTime>(activeFrom);
    }
    if (!nullToAbsent || activeTo != null) {
      map['active_to'] = Variable<DateTime>(activeTo);
    }
    if (!nullToAbsent || activeDays != null) {
      map['active_days'] = Variable<String>(activeDays);
    }
    if (!nullToAbsent || minimumEuroLevel != null) {
      map['minimum_euro_level'] = Variable<int>(minimumEuroLevel);
    }
    if (!nullToAbsent || allowedFuelTypes != null) {
      map['allowed_fuel_types'] = Variable<String>(allowedFuelTypes);
    }
    if (!nullToAbsent || allowedVehicleTypes != null) {
      map['allowed_vehicle_types'] = Variable<String>(allowedVehicleTypes);
    }
    if (!nullToAbsent || restrictions != null) {
      map['restrictions'] = Variable<String>(restrictions);
    }
    if (!nullToAbsent || officialSource != null) {
      map['official_source'] = Variable<String>(officialSource);
    }
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    }
    return map;
  }

  EmissionZonesCompanion toCompanion(bool nullToAbsent) {
    return EmissionZonesCompanion(
      id: Value(id),
      country: Value(country),
      city: Value(city),
      name: Value(name),
      zoneType: Value(zoneType),
      polygonJson: Value(polygonJson),
      activeFrom: activeFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(activeFrom),
      activeTo: activeTo == null && nullToAbsent
          ? const Value.absent()
          : Value(activeTo),
      activeDays: activeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(activeDays),
      minimumEuroLevel: minimumEuroLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumEuroLevel),
      allowedFuelTypes: allowedFuelTypes == null && nullToAbsent
          ? const Value.absent()
          : Value(allowedFuelTypes),
      allowedVehicleTypes: allowedVehicleTypes == null && nullToAbsent
          ? const Value.absent()
          : Value(allowedVehicleTypes),
      restrictions: restrictions == null && nullToAbsent
          ? const Value.absent()
          : Value(restrictions),
      officialSource: officialSource == null && nullToAbsent
          ? const Value.absent()
          : Value(officialSource),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
    );
  }

  factory EmissionZoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmissionZoneRow(
      id: serializer.fromJson<String>(json['id']),
      country: serializer.fromJson<String>(json['country']),
      city: serializer.fromJson<String>(json['city']),
      name: serializer.fromJson<String>(json['name']),
      zoneType: serializer.fromJson<String>(json['zoneType']),
      polygonJson: serializer.fromJson<String>(json['polygonJson']),
      activeFrom: serializer.fromJson<DateTime?>(json['activeFrom']),
      activeTo: serializer.fromJson<DateTime?>(json['activeTo']),
      activeDays: serializer.fromJson<String?>(json['activeDays']),
      minimumEuroLevel: serializer.fromJson<int?>(json['minimumEuroLevel']),
      allowedFuelTypes: serializer.fromJson<String?>(json['allowedFuelTypes']),
      allowedVehicleTypes: serializer.fromJson<String?>(
        json['allowedVehicleTypes'],
      ),
      restrictions: serializer.fromJson<String?>(json['restrictions']),
      officialSource: serializer.fromJson<String?>(json['officialSource']),
      lastVerifiedAt: serializer.fromJson<DateTime?>(json['lastVerifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'country': serializer.toJson<String>(country),
      'city': serializer.toJson<String>(city),
      'name': serializer.toJson<String>(name),
      'zoneType': serializer.toJson<String>(zoneType),
      'polygonJson': serializer.toJson<String>(polygonJson),
      'activeFrom': serializer.toJson<DateTime?>(activeFrom),
      'activeTo': serializer.toJson<DateTime?>(activeTo),
      'activeDays': serializer.toJson<String?>(activeDays),
      'minimumEuroLevel': serializer.toJson<int?>(minimumEuroLevel),
      'allowedFuelTypes': serializer.toJson<String?>(allowedFuelTypes),
      'allowedVehicleTypes': serializer.toJson<String?>(allowedVehicleTypes),
      'restrictions': serializer.toJson<String?>(restrictions),
      'officialSource': serializer.toJson<String?>(officialSource),
      'lastVerifiedAt': serializer.toJson<DateTime?>(lastVerifiedAt),
    };
  }

  EmissionZoneRow copyWith({
    String? id,
    String? country,
    String? city,
    String? name,
    String? zoneType,
    String? polygonJson,
    Value<DateTime?> activeFrom = const Value.absent(),
    Value<DateTime?> activeTo = const Value.absent(),
    Value<String?> activeDays = const Value.absent(),
    Value<int?> minimumEuroLevel = const Value.absent(),
    Value<String?> allowedFuelTypes = const Value.absent(),
    Value<String?> allowedVehicleTypes = const Value.absent(),
    Value<String?> restrictions = const Value.absent(),
    Value<String?> officialSource = const Value.absent(),
    Value<DateTime?> lastVerifiedAt = const Value.absent(),
  }) => EmissionZoneRow(
    id: id ?? this.id,
    country: country ?? this.country,
    city: city ?? this.city,
    name: name ?? this.name,
    zoneType: zoneType ?? this.zoneType,
    polygonJson: polygonJson ?? this.polygonJson,
    activeFrom: activeFrom.present ? activeFrom.value : this.activeFrom,
    activeTo: activeTo.present ? activeTo.value : this.activeTo,
    activeDays: activeDays.present ? activeDays.value : this.activeDays,
    minimumEuroLevel: minimumEuroLevel.present
        ? minimumEuroLevel.value
        : this.minimumEuroLevel,
    allowedFuelTypes: allowedFuelTypes.present
        ? allowedFuelTypes.value
        : this.allowedFuelTypes,
    allowedVehicleTypes: allowedVehicleTypes.present
        ? allowedVehicleTypes.value
        : this.allowedVehicleTypes,
    restrictions: restrictions.present ? restrictions.value : this.restrictions,
    officialSource: officialSource.present
        ? officialSource.value
        : this.officialSource,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
  );
  EmissionZoneRow copyWithCompanion(EmissionZonesCompanion data) {
    return EmissionZoneRow(
      id: data.id.present ? data.id.value : this.id,
      country: data.country.present ? data.country.value : this.country,
      city: data.city.present ? data.city.value : this.city,
      name: data.name.present ? data.name.value : this.name,
      zoneType: data.zoneType.present ? data.zoneType.value : this.zoneType,
      polygonJson: data.polygonJson.present
          ? data.polygonJson.value
          : this.polygonJson,
      activeFrom: data.activeFrom.present
          ? data.activeFrom.value
          : this.activeFrom,
      activeTo: data.activeTo.present ? data.activeTo.value : this.activeTo,
      activeDays: data.activeDays.present
          ? data.activeDays.value
          : this.activeDays,
      minimumEuroLevel: data.minimumEuroLevel.present
          ? data.minimumEuroLevel.value
          : this.minimumEuroLevel,
      allowedFuelTypes: data.allowedFuelTypes.present
          ? data.allowedFuelTypes.value
          : this.allowedFuelTypes,
      allowedVehicleTypes: data.allowedVehicleTypes.present
          ? data.allowedVehicleTypes.value
          : this.allowedVehicleTypes,
      restrictions: data.restrictions.present
          ? data.restrictions.value
          : this.restrictions,
      officialSource: data.officialSource.present
          ? data.officialSource.value
          : this.officialSource,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmissionZoneRow(')
          ..write('id: $id, ')
          ..write('country: $country, ')
          ..write('city: $city, ')
          ..write('name: $name, ')
          ..write('zoneType: $zoneType, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('activeFrom: $activeFrom, ')
          ..write('activeTo: $activeTo, ')
          ..write('activeDays: $activeDays, ')
          ..write('minimumEuroLevel: $minimumEuroLevel, ')
          ..write('allowedFuelTypes: $allowedFuelTypes, ')
          ..write('allowedVehicleTypes: $allowedVehicleTypes, ')
          ..write('restrictions: $restrictions, ')
          ..write('officialSource: $officialSource, ')
          ..write('lastVerifiedAt: $lastVerifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    country,
    city,
    name,
    zoneType,
    polygonJson,
    activeFrom,
    activeTo,
    activeDays,
    minimumEuroLevel,
    allowedFuelTypes,
    allowedVehicleTypes,
    restrictions,
    officialSource,
    lastVerifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmissionZoneRow &&
          other.id == this.id &&
          other.country == this.country &&
          other.city == this.city &&
          other.name == this.name &&
          other.zoneType == this.zoneType &&
          other.polygonJson == this.polygonJson &&
          other.activeFrom == this.activeFrom &&
          other.activeTo == this.activeTo &&
          other.activeDays == this.activeDays &&
          other.minimumEuroLevel == this.minimumEuroLevel &&
          other.allowedFuelTypes == this.allowedFuelTypes &&
          other.allowedVehicleTypes == this.allowedVehicleTypes &&
          other.restrictions == this.restrictions &&
          other.officialSource == this.officialSource &&
          other.lastVerifiedAt == this.lastVerifiedAt);
}

class EmissionZonesCompanion extends UpdateCompanion<EmissionZoneRow> {
  final Value<String> id;
  final Value<String> country;
  final Value<String> city;
  final Value<String> name;
  final Value<String> zoneType;
  final Value<String> polygonJson;
  final Value<DateTime?> activeFrom;
  final Value<DateTime?> activeTo;
  final Value<String?> activeDays;
  final Value<int?> minimumEuroLevel;
  final Value<String?> allowedFuelTypes;
  final Value<String?> allowedVehicleTypes;
  final Value<String?> restrictions;
  final Value<String?> officialSource;
  final Value<DateTime?> lastVerifiedAt;
  final Value<int> rowid;
  const EmissionZonesCompanion({
    this.id = const Value.absent(),
    this.country = const Value.absent(),
    this.city = const Value.absent(),
    this.name = const Value.absent(),
    this.zoneType = const Value.absent(),
    this.polygonJson = const Value.absent(),
    this.activeFrom = const Value.absent(),
    this.activeTo = const Value.absent(),
    this.activeDays = const Value.absent(),
    this.minimumEuroLevel = const Value.absent(),
    this.allowedFuelTypes = const Value.absent(),
    this.allowedVehicleTypes = const Value.absent(),
    this.restrictions = const Value.absent(),
    this.officialSource = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmissionZonesCompanion.insert({
    required String id,
    required String country,
    required String city,
    required String name,
    required String zoneType,
    required String polygonJson,
    this.activeFrom = const Value.absent(),
    this.activeTo = const Value.absent(),
    this.activeDays = const Value.absent(),
    this.minimumEuroLevel = const Value.absent(),
    this.allowedFuelTypes = const Value.absent(),
    this.allowedVehicleTypes = const Value.absent(),
    this.restrictions = const Value.absent(),
    this.officialSource = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       country = Value(country),
       city = Value(city),
       name = Value(name),
       zoneType = Value(zoneType),
       polygonJson = Value(polygonJson);
  static Insertable<EmissionZoneRow> custom({
    Expression<String>? id,
    Expression<String>? country,
    Expression<String>? city,
    Expression<String>? name,
    Expression<String>? zoneType,
    Expression<String>? polygonJson,
    Expression<DateTime>? activeFrom,
    Expression<DateTime>? activeTo,
    Expression<String>? activeDays,
    Expression<int>? minimumEuroLevel,
    Expression<String>? allowedFuelTypes,
    Expression<String>? allowedVehicleTypes,
    Expression<String>? restrictions,
    Expression<String>? officialSource,
    Expression<DateTime>? lastVerifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      if (name != null) 'name': name,
      if (zoneType != null) 'zone_type': zoneType,
      if (polygonJson != null) 'polygon_json': polygonJson,
      if (activeFrom != null) 'active_from': activeFrom,
      if (activeTo != null) 'active_to': activeTo,
      if (activeDays != null) 'active_days': activeDays,
      if (minimumEuroLevel != null) 'minimum_euro_level': minimumEuroLevel,
      if (allowedFuelTypes != null) 'allowed_fuel_types': allowedFuelTypes,
      if (allowedVehicleTypes != null)
        'allowed_vehicle_types': allowedVehicleTypes,
      if (restrictions != null) 'restrictions': restrictions,
      if (officialSource != null) 'official_source': officialSource,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmissionZonesCompanion copyWith({
    Value<String>? id,
    Value<String>? country,
    Value<String>? city,
    Value<String>? name,
    Value<String>? zoneType,
    Value<String>? polygonJson,
    Value<DateTime?>? activeFrom,
    Value<DateTime?>? activeTo,
    Value<String?>? activeDays,
    Value<int?>? minimumEuroLevel,
    Value<String?>? allowedFuelTypes,
    Value<String?>? allowedVehicleTypes,
    Value<String?>? restrictions,
    Value<String?>? officialSource,
    Value<DateTime?>? lastVerifiedAt,
    Value<int>? rowid,
  }) {
    return EmissionZonesCompanion(
      id: id ?? this.id,
      country: country ?? this.country,
      city: city ?? this.city,
      name: name ?? this.name,
      zoneType: zoneType ?? this.zoneType,
      polygonJson: polygonJson ?? this.polygonJson,
      activeFrom: activeFrom ?? this.activeFrom,
      activeTo: activeTo ?? this.activeTo,
      activeDays: activeDays ?? this.activeDays,
      minimumEuroLevel: minimumEuroLevel ?? this.minimumEuroLevel,
      allowedFuelTypes: allowedFuelTypes ?? this.allowedFuelTypes,
      allowedVehicleTypes: allowedVehicleTypes ?? this.allowedVehicleTypes,
      restrictions: restrictions ?? this.restrictions,
      officialSource: officialSource ?? this.officialSource,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (zoneType.present) {
      map['zone_type'] = Variable<String>(zoneType.value);
    }
    if (polygonJson.present) {
      map['polygon_json'] = Variable<String>(polygonJson.value);
    }
    if (activeFrom.present) {
      map['active_from'] = Variable<DateTime>(activeFrom.value);
    }
    if (activeTo.present) {
      map['active_to'] = Variable<DateTime>(activeTo.value);
    }
    if (activeDays.present) {
      map['active_days'] = Variable<String>(activeDays.value);
    }
    if (minimumEuroLevel.present) {
      map['minimum_euro_level'] = Variable<int>(minimumEuroLevel.value);
    }
    if (allowedFuelTypes.present) {
      map['allowed_fuel_types'] = Variable<String>(allowedFuelTypes.value);
    }
    if (allowedVehicleTypes.present) {
      map['allowed_vehicle_types'] = Variable<String>(
        allowedVehicleTypes.value,
      );
    }
    if (restrictions.present) {
      map['restrictions'] = Variable<String>(restrictions.value);
    }
    if (officialSource.present) {
      map['official_source'] = Variable<String>(officialSource.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmissionZonesCompanion(')
          ..write('id: $id, ')
          ..write('country: $country, ')
          ..write('city: $city, ')
          ..write('name: $name, ')
          ..write('zoneType: $zoneType, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('activeFrom: $activeFrom, ')
          ..write('activeTo: $activeTo, ')
          ..write('activeDays: $activeDays, ')
          ..write('minimumEuroLevel: $minimumEuroLevel, ')
          ..write('allowedFuelTypes: $allowedFuelTypes, ')
          ..write('allowedVehicleTypes: $allowedVehicleTypes, ')
          ..write('restrictions: $restrictions, ')
          ..write('officialSource: $officialSource, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles
    with TableInfo<$VehiclesTable, VehicleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _euroClassMeta = const VerificationMeta(
    'euroClass',
  );
  @override
  late final GeneratedColumn<String> euroClass = GeneratedColumn<String>(
    'euro_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licensePlateMeta = const VerificationMeta(
    'licensePlate',
  );
  @override
  late final GeneratedColumn<String> licensePlate = GeneratedColumn<String>(
    'license_plate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    fuelType,
    euroClass,
    licensePlate,
    country,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fuelTypeMeta);
    }
    if (data.containsKey('euro_class')) {
      context.handle(
        _euroClassMeta,
        euroClass.isAcceptableOrUnknown(data['euro_class']!, _euroClassMeta),
      );
    } else if (isInserting) {
      context.missing(_euroClassMeta);
    }
    if (data.containsKey('license_plate')) {
      context.handle(
        _licensePlateMeta,
        licensePlate.isAcceptableOrUnknown(
          data['license_plate']!,
          _licensePlateMeta,
        ),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      )!,
      euroClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}euro_class'],
      )!,
      licensePlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_plate'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class VehicleRow extends DataClass implements Insertable<VehicleRow> {
  final int id;
  final String type;
  final String fuelType;
  final String euroClass;
  final String? licensePlate;
  final String? country;
  final bool isActive;
  const VehicleRow({
    required this.id,
    required this.type,
    required this.fuelType,
    required this.euroClass,
    this.licensePlate,
    this.country,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['fuel_type'] = Variable<String>(fuelType);
    map['euro_class'] = Variable<String>(euroClass);
    if (!nullToAbsent || licensePlate != null) {
      map['license_plate'] = Variable<String>(licensePlate);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      type: Value(type),
      fuelType: Value(fuelType),
      euroClass: Value(euroClass),
      licensePlate: licensePlate == null && nullToAbsent
          ? const Value.absent()
          : Value(licensePlate),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      isActive: Value(isActive),
    );
  }

  factory VehicleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleRow(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      fuelType: serializer.fromJson<String>(json['fuelType']),
      euroClass: serializer.fromJson<String>(json['euroClass']),
      licensePlate: serializer.fromJson<String?>(json['licensePlate']),
      country: serializer.fromJson<String?>(json['country']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'fuelType': serializer.toJson<String>(fuelType),
      'euroClass': serializer.toJson<String>(euroClass),
      'licensePlate': serializer.toJson<String?>(licensePlate),
      'country': serializer.toJson<String?>(country),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  VehicleRow copyWith({
    int? id,
    String? type,
    String? fuelType,
    String? euroClass,
    Value<String?> licensePlate = const Value.absent(),
    Value<String?> country = const Value.absent(),
    bool? isActive,
  }) => VehicleRow(
    id: id ?? this.id,
    type: type ?? this.type,
    fuelType: fuelType ?? this.fuelType,
    euroClass: euroClass ?? this.euroClass,
    licensePlate: licensePlate.present ? licensePlate.value : this.licensePlate,
    country: country.present ? country.value : this.country,
    isActive: isActive ?? this.isActive,
  );
  VehicleRow copyWithCompanion(VehiclesCompanion data) {
    return VehicleRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      euroClass: data.euroClass.present ? data.euroClass.value : this.euroClass,
      licensePlate: data.licensePlate.present
          ? data.licensePlate.value
          : this.licensePlate,
      country: data.country.present ? data.country.value : this.country,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('fuelType: $fuelType, ')
          ..write('euroClass: $euroClass, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('country: $country, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    fuelType,
    euroClass,
    licensePlate,
    country,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.fuelType == this.fuelType &&
          other.euroClass == this.euroClass &&
          other.licensePlate == this.licensePlate &&
          other.country == this.country &&
          other.isActive == this.isActive);
}

class VehiclesCompanion extends UpdateCompanion<VehicleRow> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> fuelType;
  final Value<String> euroClass;
  final Value<String?> licensePlate;
  final Value<String?> country;
  final Value<bool> isActive;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.euroClass = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.country = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String fuelType,
    required String euroClass,
    this.licensePlate = const Value.absent(),
    this.country = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : type = Value(type),
       fuelType = Value(fuelType),
       euroClass = Value(euroClass);
  static Insertable<VehicleRow> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? fuelType,
    Expression<String>? euroClass,
    Expression<String>? licensePlate,
    Expression<String>? country,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (fuelType != null) 'fuel_type': fuelType,
      if (euroClass != null) 'euro_class': euroClass,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (country != null) 'country': country,
      if (isActive != null) 'is_active': isActive,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? fuelType,
    Value<String>? euroClass,
    Value<String?>? licensePlate,
    Value<String?>? country,
    Value<bool>? isActive,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      fuelType: fuelType ?? this.fuelType,
      euroClass: euroClass ?? this.euroClass,
      licensePlate: licensePlate ?? this.licensePlate,
      country: country ?? this.country,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (euroClass.present) {
      map['euro_class'] = Variable<String>(euroClass.value);
    }
    if (licensePlate.present) {
      map['license_plate'] = Variable<String>(licensePlate.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('fuelType: $fuelType, ')
          ..write('euroClass: $euroClass, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('country: $country, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EmissionZonesTable emissionZones = $EmissionZonesTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final ZoneDao zoneDao = ZoneDao(this as AppDatabase);
  late final VehicleDao vehicleDao = VehicleDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [emissionZones, vehicles];
}

typedef $$EmissionZonesTableCreateCompanionBuilder =
    EmissionZonesCompanion Function({
      required String id,
      required String country,
      required String city,
      required String name,
      required String zoneType,
      required String polygonJson,
      Value<DateTime?> activeFrom,
      Value<DateTime?> activeTo,
      Value<String?> activeDays,
      Value<int?> minimumEuroLevel,
      Value<String?> allowedFuelTypes,
      Value<String?> allowedVehicleTypes,
      Value<String?> restrictions,
      Value<String?> officialSource,
      Value<DateTime?> lastVerifiedAt,
      Value<int> rowid,
    });
typedef $$EmissionZonesTableUpdateCompanionBuilder =
    EmissionZonesCompanion Function({
      Value<String> id,
      Value<String> country,
      Value<String> city,
      Value<String> name,
      Value<String> zoneType,
      Value<String> polygonJson,
      Value<DateTime?> activeFrom,
      Value<DateTime?> activeTo,
      Value<String?> activeDays,
      Value<int?> minimumEuroLevel,
      Value<String?> allowedFuelTypes,
      Value<String?> allowedVehicleTypes,
      Value<String?> restrictions,
      Value<String?> officialSource,
      Value<DateTime?> lastVerifiedAt,
      Value<int> rowid,
    });

class $$EmissionZonesTableFilterComposer
    extends Composer<_$AppDatabase, $EmissionZonesTable> {
  $$EmissionZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneType => $composableBuilder(
    column: $table.zoneType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get activeTo => $composableBuilder(
    column: $table.activeTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumEuroLevel => $composableBuilder(
    column: $table.minimumEuroLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allowedFuelTypes => $composableBuilder(
    column: $table.allowedFuelTypes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allowedVehicleTypes => $composableBuilder(
    column: $table.allowedVehicleTypes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restrictions => $composableBuilder(
    column: $table.restrictions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officialSource => $composableBuilder(
    column: $table.officialSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmissionZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmissionZonesTable> {
  $$EmissionZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneType => $composableBuilder(
    column: $table.zoneType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get activeTo => $composableBuilder(
    column: $table.activeTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumEuroLevel => $composableBuilder(
    column: $table.minimumEuroLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allowedFuelTypes => $composableBuilder(
    column: $table.allowedFuelTypes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allowedVehicleTypes => $composableBuilder(
    column: $table.allowedVehicleTypes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restrictions => $composableBuilder(
    column: $table.restrictions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officialSource => $composableBuilder(
    column: $table.officialSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmissionZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmissionZonesTable> {
  $$EmissionZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get zoneType =>
      $composableBuilder(column: $table.zoneType, builder: (column) => column);

  GeneratedColumn<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get activeTo =>
      $composableBuilder(column: $table.activeTo, builder: (column) => column);

  GeneratedColumn<String> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumEuroLevel => $composableBuilder(
    column: $table.minimumEuroLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allowedFuelTypes => $composableBuilder(
    column: $table.allowedFuelTypes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allowedVehicleTypes => $composableBuilder(
    column: $table.allowedVehicleTypes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restrictions => $composableBuilder(
    column: $table.restrictions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officialSource => $composableBuilder(
    column: $table.officialSource,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );
}

class $$EmissionZonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmissionZonesTable,
          EmissionZoneRow,
          $$EmissionZonesTableFilterComposer,
          $$EmissionZonesTableOrderingComposer,
          $$EmissionZonesTableAnnotationComposer,
          $$EmissionZonesTableCreateCompanionBuilder,
          $$EmissionZonesTableUpdateCompanionBuilder,
          (
            EmissionZoneRow,
            BaseReferences<_$AppDatabase, $EmissionZonesTable, EmissionZoneRow>,
          ),
          EmissionZoneRow,
          PrefetchHooks Function()
        > {
  $$EmissionZonesTableTableManager(_$AppDatabase db, $EmissionZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmissionZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmissionZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmissionZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> zoneType = const Value.absent(),
                Value<String> polygonJson = const Value.absent(),
                Value<DateTime?> activeFrom = const Value.absent(),
                Value<DateTime?> activeTo = const Value.absent(),
                Value<String?> activeDays = const Value.absent(),
                Value<int?> minimumEuroLevel = const Value.absent(),
                Value<String?> allowedFuelTypes = const Value.absent(),
                Value<String?> allowedVehicleTypes = const Value.absent(),
                Value<String?> restrictions = const Value.absent(),
                Value<String?> officialSource = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmissionZonesCompanion(
                id: id,
                country: country,
                city: city,
                name: name,
                zoneType: zoneType,
                polygonJson: polygonJson,
                activeFrom: activeFrom,
                activeTo: activeTo,
                activeDays: activeDays,
                minimumEuroLevel: minimumEuroLevel,
                allowedFuelTypes: allowedFuelTypes,
                allowedVehicleTypes: allowedVehicleTypes,
                restrictions: restrictions,
                officialSource: officialSource,
                lastVerifiedAt: lastVerifiedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String country,
                required String city,
                required String name,
                required String zoneType,
                required String polygonJson,
                Value<DateTime?> activeFrom = const Value.absent(),
                Value<DateTime?> activeTo = const Value.absent(),
                Value<String?> activeDays = const Value.absent(),
                Value<int?> minimumEuroLevel = const Value.absent(),
                Value<String?> allowedFuelTypes = const Value.absent(),
                Value<String?> allowedVehicleTypes = const Value.absent(),
                Value<String?> restrictions = const Value.absent(),
                Value<String?> officialSource = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmissionZonesCompanion.insert(
                id: id,
                country: country,
                city: city,
                name: name,
                zoneType: zoneType,
                polygonJson: polygonJson,
                activeFrom: activeFrom,
                activeTo: activeTo,
                activeDays: activeDays,
                minimumEuroLevel: minimumEuroLevel,
                allowedFuelTypes: allowedFuelTypes,
                allowedVehicleTypes: allowedVehicleTypes,
                restrictions: restrictions,
                officialSource: officialSource,
                lastVerifiedAt: lastVerifiedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmissionZonesTable, EmissionZoneRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EmissionZonesTable,
                    EmissionZoneRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmissionZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmissionZonesTable,
      EmissionZoneRow,
      $$EmissionZonesTableFilterComposer,
      $$EmissionZonesTableOrderingComposer,
      $$EmissionZonesTableAnnotationComposer,
      $$EmissionZonesTableCreateCompanionBuilder,
      $$EmissionZonesTableUpdateCompanionBuilder,
      (
        EmissionZoneRow,
        BaseReferences<_$AppDatabase, $EmissionZonesTable, EmissionZoneRow>,
      ),
      EmissionZoneRow,
      PrefetchHooks Function()
    >;
typedef $$VehiclesTableCreateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  required String type,
  required String fuelType,
  required String euroClass,
  Value<String?> licensePlate,
  Value<String?> country,
  Value<bool> isActive,
});
typedef $$VehiclesTableUpdateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<String> fuelType,
  Value<String> euroClass,
  Value<String?> licensePlate,
  Value<String?> country,
  Value<bool> isActive,
});

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get euroClass => $composableBuilder(
    column: $table.euroClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get euroClass => $composableBuilder(
    column: $table.euroClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<String> get euroClass =>
      $composableBuilder(column: $table.euroClass, builder: (column) => column);

  GeneratedColumn<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          VehicleRow,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (
            VehicleRow,
            BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow>,
          ),
          VehicleRow,
          PrefetchHooks Function()
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> fuelType = const Value.absent(),
                Value<String> euroClass = const Value.absent(),
                Value<String?> licensePlate = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                type: type,
                fuelType: fuelType,
                euroClass: euroClass,
                licensePlate: licensePlate,
                country: country,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String fuelType,
                required String euroClass,
                Value<String?> licensePlate = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                type: type,
                fuelType: fuelType,
                euroClass: euroClass,
                licensePlate: licensePlate,
                country: country,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehiclesTable, VehicleRow>(table),
                  BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      VehicleRow,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (VehicleRow, BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow>),
      VehicleRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmissionZonesTableTableManager get emissionZones =>
      $$EmissionZonesTableTableManager(_db, _db.emissionZones);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
}
