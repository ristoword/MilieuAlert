enum VehicleType {
  car('automobile'),
  van('furgone'),
  truck('camion'),
  camper('camper'),
  motorcycle('motociclo');

  const VehicleType(this.labelIt);
  final String labelIt;
}

enum FuelType {
  diesel('Diesel'),
  petrol('Benzina'),
  lpg('GPL'),
  hybrid('Ibrido'),
  electric('Elettrico');

  const FuelType(this.label);
  final String label;
}

enum EuroClass {
  euro1('Euro 1', 1),
  euro2('Euro 2', 2),
  euro3('Euro 3', 3),
  euro4('Euro 4', 4),
  euro5('Euro 5', 5),
  euro6('Euro 6', 6);

  const EuroClass(this.label, this.level);
  final String label;
  final int level;
}

class Vehicle {
  final int? id;
  final VehicleType type;
  final FuelType fuelType;
  final EuroClass euroClass;
  final String? licensePlate;
  final String? country;

  const Vehicle({
    this.id,
    required this.type,
    required this.fuelType,
    required this.euroClass,
    this.licensePlate,
    this.country,
  });

  Vehicle copyWith({
    int? id,
    VehicleType? type,
    FuelType? fuelType,
    EuroClass? euroClass,
    String? licensePlate,
    String? country,
  }) {
    return Vehicle(
      id: id ?? this.id,
      type: type ?? this.type,
      fuelType: fuelType ?? this.fuelType,
      euroClass: euroClass ?? this.euroClass,
      licensePlate: licensePlate ?? this.licensePlate,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'fuelType': fuelType.name,
        'euroClass': euroClass.name,
        'licensePlate': licensePlate,
        'country': country,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    T enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
      final name = raw?.toString();
      if (name == null || name.isEmpty) return fallback;
      for (final value in values) {
        if (value.name == name) return value;
      }
      return fallback;
    }

    return Vehicle(
      id: json['id'] is int ? json['id'] as int : null,
      type: enumByName(VehicleType.values, json['type'], VehicleType.car),
      fuelType: enumByName(FuelType.values, json['fuelType'], FuelType.diesel),
      euroClass:
          enumByName(EuroClass.values, json['euroClass'], EuroClass.euro4),
      licensePlate: json['licensePlate'] as String?,
      country: json['country'] as String?,
    );
  }
}
