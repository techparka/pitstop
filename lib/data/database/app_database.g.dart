// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
      'vin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _powertrainMeta =
      const VerificationMeta('powertrain');
  @override
  late final GeneratedColumn<String> powertrain = GeneratedColumn<String>(
      'powertrain', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Benzyna'));
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
      'purchase_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _technicalNotesMeta =
      const VerificationMeta('technicalNotes');
  @override
  late final GeneratedColumn<String> technicalNotes = GeneratedColumn<String>(
      'technical_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
      'make', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _licensePlateMeta =
      const VerificationMeta('licensePlate');
  @override
  late final GeneratedColumn<String> licensePlate = GeneratedColumn<String>(
      'license_plate', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currentMileageMeta =
      const VerificationMeta('currentMileage');
  @override
  late final GeneratedColumn<int> currentMileage = GeneratedColumn<int>(
      'current_mileage', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        vin,
        powertrain,
        purchaseDate,
        technicalNotes,
        id,
        name,
        make,
        model,
        year,
        licensePlate,
        photoPath,
        currentMileage,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(Insertable<Vehicle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vin')) {
      context.handle(
          _vinMeta, vin.isAcceptableOrUnknown(data['vin']!, _vinMeta));
    }
    if (data.containsKey('powertrain')) {
      context.handle(
          _powertrainMeta,
          powertrain.isAcceptableOrUnknown(
              data['powertrain']!, _powertrainMeta));
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    }
    if (data.containsKey('technical_notes')) {
      context.handle(
          _technicalNotesMeta,
          technicalNotes.isAcceptableOrUnknown(
              data['technical_notes']!, _technicalNotesMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
          _makeMeta, make.isAcceptableOrUnknown(data['make']!, _makeMeta));
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('license_plate')) {
      context.handle(
          _licensePlateMeta,
          licensePlate.isAcceptableOrUnknown(
              data['license_plate']!, _licensePlateMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('current_mileage')) {
      context.handle(
          _currentMileageMeta,
          currentMileage.isAcceptableOrUnknown(
              data['current_mileage']!, _currentMileageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      vin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vin']),
      powertrain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}powertrain'])!,
      purchaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}purchase_date']),
      technicalNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}technical_notes']),
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      make: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}make'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      licensePlate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_plate']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      currentMileage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_mileage'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final String? vin;
  final String powertrain;
  final DateTime? purchaseDate;
  final String? technicalNotes;
  final int id;
  final String name;
  final String make;
  final String model;
  final int year;
  final String? licensePlate;
  final String? photoPath;
  final int currentMileage;
  final DateTime createdAt;
  const Vehicle(
      {this.vin,
      required this.powertrain,
      this.purchaseDate,
      this.technicalNotes,
      required this.id,
      required this.name,
      required this.make,
      required this.model,
      required this.year,
      this.licensePlate,
      this.photoPath,
      required this.currentMileage,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || vin != null) {
      map['vin'] = Variable<String>(vin);
    }
    map['powertrain'] = Variable<String>(powertrain);
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || technicalNotes != null) {
      map['technical_notes'] = Variable<String>(technicalNotes);
    }
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || licensePlate != null) {
      map['license_plate'] = Variable<String>(licensePlate);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['current_mileage'] = Variable<int>(currentMileage);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      vin: vin == null && nullToAbsent ? const Value.absent() : Value(vin),
      powertrain: Value(powertrain),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      technicalNotes: technicalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(technicalNotes),
      id: Value(id),
      name: Value(name),
      make: Value(make),
      model: Value(model),
      year: Value(year),
      licensePlate: licensePlate == null && nullToAbsent
          ? const Value.absent()
          : Value(licensePlate),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      currentMileage: Value(currentMileage),
      createdAt: Value(createdAt),
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      vin: serializer.fromJson<String?>(json['vin']),
      powertrain: serializer.fromJson<String>(json['powertrain']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      technicalNotes: serializer.fromJson<String?>(json['technicalNotes']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<int>(json['year']),
      licensePlate: serializer.fromJson<String?>(json['licensePlate']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      currentMileage: serializer.fromJson<int>(json['currentMileage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vin': serializer.toJson<String?>(vin),
      'powertrain': serializer.toJson<String>(powertrain),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'technicalNotes': serializer.toJson<String?>(technicalNotes),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<int>(year),
      'licensePlate': serializer.toJson<String?>(licensePlate),
      'photoPath': serializer.toJson<String?>(photoPath),
      'currentMileage': serializer.toJson<int>(currentMileage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vehicle copyWith(
          {Value<String?> vin = const Value.absent(),
          String? powertrain,
          Value<DateTime?> purchaseDate = const Value.absent(),
          Value<String?> technicalNotes = const Value.absent(),
          int? id,
          String? name,
          String? make,
          String? model,
          int? year,
          Value<String?> licensePlate = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          int? currentMileage,
          DateTime? createdAt}) =>
      Vehicle(
        vin: vin.present ? vin.value : this.vin,
        powertrain: powertrain ?? this.powertrain,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        technicalNotes:
            technicalNotes.present ? technicalNotes.value : this.technicalNotes,
        id: id ?? this.id,
        name: name ?? this.name,
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        licensePlate:
            licensePlate.present ? licensePlate.value : this.licensePlate,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        currentMileage: currentMileage ?? this.currentMileage,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('vin: $vin, ')
          ..write('powertrain: $powertrain, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('technicalNotes: $technicalNotes, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('photoPath: $photoPath, ')
          ..write('currentMileage: $currentMileage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      vin,
      powertrain,
      purchaseDate,
      technicalNotes,
      id,
      name,
      make,
      model,
      year,
      licensePlate,
      photoPath,
      currentMileage,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.vin == this.vin &&
          other.powertrain == this.powertrain &&
          other.purchaseDate == this.purchaseDate &&
          other.technicalNotes == this.technicalNotes &&
          other.id == this.id &&
          other.name == this.name &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.licensePlate == this.licensePlate &&
          other.photoPath == this.photoPath &&
          other.currentMileage == this.currentMileage &&
          other.createdAt == this.createdAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<String?> vin;
  final Value<String> powertrain;
  final Value<DateTime?> purchaseDate;
  final Value<String?> technicalNotes;
  final Value<int> id;
  final Value<String> name;
  final Value<String> make;
  final Value<String> model;
  final Value<int> year;
  final Value<String?> licensePlate;
  final Value<String?> photoPath;
  final Value<int> currentMileage;
  final Value<DateTime> createdAt;
  const VehiclesCompanion({
    this.vin = const Value.absent(),
    this.powertrain = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.technicalNotes = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.currentMileage = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.vin = const Value.absent(),
    this.powertrain = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.technicalNotes = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    required String make,
    required String model,
    required int year,
    this.licensePlate = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.currentMileage = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        make = Value(make),
        model = Value(model),
        year = Value(year);
  static Insertable<Vehicle> custom({
    Expression<String>? vin,
    Expression<String>? powertrain,
    Expression<DateTime>? purchaseDate,
    Expression<String>? technicalNotes,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? make,
    Expression<String>? model,
    Expression<int>? year,
    Expression<String>? licensePlate,
    Expression<String>? photoPath,
    Expression<int>? currentMileage,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (vin != null) 'vin': vin,
      if (powertrain != null) 'powertrain': powertrain,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (technicalNotes != null) 'technical_notes': technicalNotes,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (photoPath != null) 'photo_path': photoPath,
      if (currentMileage != null) 'current_mileage': currentMileage,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VehiclesCompanion copyWith(
      {Value<String?>? vin,
      Value<String>? powertrain,
      Value<DateTime?>? purchaseDate,
      Value<String?>? technicalNotes,
      Value<int>? id,
      Value<String>? name,
      Value<String>? make,
      Value<String>? model,
      Value<int>? year,
      Value<String?>? licensePlate,
      Value<String?>? photoPath,
      Value<int>? currentMileage,
      Value<DateTime>? createdAt}) {
    return VehiclesCompanion(
      vin: vin ?? this.vin,
      powertrain: powertrain ?? this.powertrain,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      technicalNotes: technicalNotes ?? this.technicalNotes,
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      photoPath: photoPath ?? this.photoPath,
      currentMileage: currentMileage ?? this.currentMileage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (powertrain.present) {
      map['powertrain'] = Variable<String>(powertrain.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (technicalNotes.present) {
      map['technical_notes'] = Variable<String>(technicalNotes.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (licensePlate.present) {
      map['license_plate'] = Variable<String>(licensePlate.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (currentMileage.present) {
      map['current_mileage'] = Variable<int>(currentMileage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('vin: $vin, ')
          ..write('powertrain: $powertrain, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('technicalNotes: $technicalNotes, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('photoPath: $photoPath, ')
          ..write('currentMileage: $currentMileage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ServiceRecordsTable extends ServiceRecords
    with TableInfo<$ServiceRecordsTable, ServiceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _costCentsMeta =
      const VerificationMeta('costCents');
  @override
  late final GeneratedColumn<int> costCents = GeneratedColumn<int>(
      'cost_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vehicles (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serviceDateMeta =
      const VerificationMeta('serviceDate');
  @override
  late final GeneratedColumn<DateTime> serviceDate = GeneratedColumn<DateTime>(
      'service_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _mileageMeta =
      const VerificationMeta('mileage');
  @override
  late final GeneratedColumn<int> mileage = GeneratedColumn<int>(
      'mileage', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
      'cost', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _serviceTypeMeta =
      const VerificationMeta('serviceType');
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
      'service_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('OTHER'));
  static const VerificationMeta _workshopMeta =
      const VerificationMeta('workshop');
  @override
  late final GeneratedColumn<String> workshop = GeneratedColumn<String>(
      'workshop', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        costCents,
        id,
        vehicleId,
        title,
        description,
        serviceDate,
        mileage,
        cost,
        serviceType,
        workshop,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_records';
  @override
  VerificationContext validateIntegrity(Insertable<ServiceRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cost_cents')) {
      context.handle(_costCentsMeta,
          costCents.isAcceptableOrUnknown(data['cost_cents']!, _costCentsMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('service_date')) {
      context.handle(
          _serviceDateMeta,
          serviceDate.isAcceptableOrUnknown(
              data['service_date']!, _serviceDateMeta));
    } else if (isInserting) {
      context.missing(_serviceDateMeta);
    }
    if (data.containsKey('mileage')) {
      context.handle(_mileageMeta,
          mileage.isAcceptableOrUnknown(data['mileage']!, _mileageMeta));
    }
    if (data.containsKey('cost')) {
      context.handle(
          _costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    }
    if (data.containsKey('service_type')) {
      context.handle(
          _serviceTypeMeta,
          serviceType.isAcceptableOrUnknown(
              data['service_type']!, _serviceTypeMeta));
    }
    if (data.containsKey('workshop')) {
      context.handle(_workshopMeta,
          workshop.isAcceptableOrUnknown(data['workshop']!, _workshopMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceRecord(
      costCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cost_cents']),
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vehicle_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      serviceDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}service_date'])!,
      mileage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mileage']),
      cost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost']),
      serviceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_type'])!,
      workshop: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workshop']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ServiceRecordsTable createAlias(String alias) {
    return $ServiceRecordsTable(attachedDatabase, alias);
  }
}

class ServiceRecord extends DataClass implements Insertable<ServiceRecord> {
  final int? costCents;
  final int id;
  final int vehicleId;
  final String title;
  final String? description;
  final DateTime serviceDate;
  final int? mileage;
  final double? cost;
  final String serviceType;
  final String? workshop;
  final DateTime createdAt;
  const ServiceRecord(
      {this.costCents,
      required this.id,
      required this.vehicleId,
      required this.title,
      this.description,
      required this.serviceDate,
      this.mileage,
      this.cost,
      required this.serviceType,
      this.workshop,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || costCents != null) {
      map['cost_cents'] = Variable<int>(costCents);
    }
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['service_date'] = Variable<DateTime>(serviceDate);
    if (!nullToAbsent || mileage != null) {
      map['mileage'] = Variable<int>(mileage);
    }
    if (!nullToAbsent || cost != null) {
      map['cost'] = Variable<double>(cost);
    }
    map['service_type'] = Variable<String>(serviceType);
    if (!nullToAbsent || workshop != null) {
      map['workshop'] = Variable<String>(workshop);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServiceRecordsCompanion toCompanion(bool nullToAbsent) {
    return ServiceRecordsCompanion(
      costCents: costCents == null && nullToAbsent
          ? const Value.absent()
          : Value(costCents),
      id: Value(id),
      vehicleId: Value(vehicleId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      serviceDate: Value(serviceDate),
      mileage: mileage == null && nullToAbsent
          ? const Value.absent()
          : Value(mileage),
      cost: cost == null && nullToAbsent ? const Value.absent() : Value(cost),
      serviceType: Value(serviceType),
      workshop: workshop == null && nullToAbsent
          ? const Value.absent()
          : Value(workshop),
      createdAt: Value(createdAt),
    );
  }

  factory ServiceRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceRecord(
      costCents: serializer.fromJson<int?>(json['costCents']),
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      serviceDate: serializer.fromJson<DateTime>(json['serviceDate']),
      mileage: serializer.fromJson<int?>(json['mileage']),
      cost: serializer.fromJson<double?>(json['cost']),
      serviceType: serializer.fromJson<String>(json['serviceType']),
      workshop: serializer.fromJson<String?>(json['workshop']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'costCents': serializer.toJson<int?>(costCents),
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'serviceDate': serializer.toJson<DateTime>(serviceDate),
      'mileage': serializer.toJson<int?>(mileage),
      'cost': serializer.toJson<double?>(cost),
      'serviceType': serializer.toJson<String>(serviceType),
      'workshop': serializer.toJson<String?>(workshop),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServiceRecord copyWith(
          {Value<int?> costCents = const Value.absent(),
          int? id,
          int? vehicleId,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? serviceDate,
          Value<int?> mileage = const Value.absent(),
          Value<double?> cost = const Value.absent(),
          String? serviceType,
          Value<String?> workshop = const Value.absent(),
          DateTime? createdAt}) =>
      ServiceRecord(
        costCents: costCents.present ? costCents.value : this.costCents,
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        serviceDate: serviceDate ?? this.serviceDate,
        mileage: mileage.present ? mileage.value : this.mileage,
        cost: cost.present ? cost.value : this.cost,
        serviceType: serviceType ?? this.serviceType,
        workshop: workshop.present ? workshop.value : this.workshop,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('ServiceRecord(')
          ..write('costCents: $costCents, ')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('mileage: $mileage, ')
          ..write('cost: $cost, ')
          ..write('serviceType: $serviceType, ')
          ..write('workshop: $workshop, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(costCents, id, vehicleId, title, description,
      serviceDate, mileage, cost, serviceType, workshop, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceRecord &&
          other.costCents == this.costCents &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.title == this.title &&
          other.description == this.description &&
          other.serviceDate == this.serviceDate &&
          other.mileage == this.mileage &&
          other.cost == this.cost &&
          other.serviceType == this.serviceType &&
          other.workshop == this.workshop &&
          other.createdAt == this.createdAt);
}

class ServiceRecordsCompanion extends UpdateCompanion<ServiceRecord> {
  final Value<int?> costCents;
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> serviceDate;
  final Value<int?> mileage;
  final Value<double?> cost;
  final Value<String> serviceType;
  final Value<String?> workshop;
  final Value<DateTime> createdAt;
  const ServiceRecordsCompanion({
    this.costCents = const Value.absent(),
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.mileage = const Value.absent(),
    this.cost = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.workshop = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ServiceRecordsCompanion.insert({
    this.costCents = const Value.absent(),
    this.id = const Value.absent(),
    required int vehicleId,
    required String title,
    this.description = const Value.absent(),
    required DateTime serviceDate,
    this.mileage = const Value.absent(),
    this.cost = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.workshop = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : vehicleId = Value(vehicleId),
        title = Value(title),
        serviceDate = Value(serviceDate);
  static Insertable<ServiceRecord> custom({
    Expression<int>? costCents,
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? serviceDate,
    Expression<int>? mileage,
    Expression<double>? cost,
    Expression<String>? serviceType,
    Expression<String>? workshop,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (costCents != null) 'cost_cents': costCents,
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (serviceDate != null) 'service_date': serviceDate,
      if (mileage != null) 'mileage': mileage,
      if (cost != null) 'cost': cost,
      if (serviceType != null) 'service_type': serviceType,
      if (workshop != null) 'workshop': workshop,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ServiceRecordsCompanion copyWith(
      {Value<int?>? costCents,
      Value<int>? id,
      Value<int>? vehicleId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? serviceDate,
      Value<int?>? mileage,
      Value<double?>? cost,
      Value<String>? serviceType,
      Value<String?>? workshop,
      Value<DateTime>? createdAt}) {
    return ServiceRecordsCompanion(
      costCents: costCents ?? this.costCents,
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceDate: serviceDate ?? this.serviceDate,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      serviceType: serviceType ?? this.serviceType,
      workshop: workshop ?? this.workshop,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (costCents.present) {
      map['cost_cents'] = Variable<int>(costCents.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<DateTime>(serviceDate.value);
    }
    if (mileage.present) {
      map['mileage'] = Variable<int>(mileage.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (workshop.present) {
      map['workshop'] = Variable<String>(workshop.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceRecordsCompanion(')
          ..write('costCents: $costCents, ')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('mileage: $mileage, ')
          ..write('cost: $cost, ')
          ..write('serviceType: $serviceType, ')
          ..write('workshop: $workshop, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serviceRecordIdMeta =
      const VerificationMeta('serviceRecordId');
  @override
  late final GeneratedColumn<int> serviceRecordId = GeneratedColumn<int>(
      'service_record_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES service_records (id) ON DELETE CASCADE'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileTypeMeta =
      const VerificationMeta('fileType');
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
      'file_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serviceRecordId, filePath, fileType, fileName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(Insertable<Attachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_record_id')) {
      context.handle(
          _serviceRecordIdMeta,
          serviceRecordId.isAcceptableOrUnknown(
              data['service_record_id']!, _serviceRecordIdMeta));
    } else if (isInserting) {
      context.missing(_serviceRecordIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(_fileTypeMeta,
          fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta));
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serviceRecordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}service_record_id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      fileType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_type'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final int id;
  final int serviceRecordId;
  final String filePath;
  final String fileType;
  final String fileName;
  final DateTime createdAt;
  const Attachment(
      {required this.id,
      required this.serviceRecordId,
      required this.filePath,
      required this.fileType,
      required this.fileName,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_record_id'] = Variable<int>(serviceRecordId);
    map['file_path'] = Variable<String>(filePath);
    map['file_type'] = Variable<String>(fileType);
    map['file_name'] = Variable<String>(fileName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      serviceRecordId: Value(serviceRecordId),
      filePath: Value(filePath),
      fileType: Value(fileType),
      fileName: Value(fileName),
      createdAt: Value(createdAt),
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<int>(json['id']),
      serviceRecordId: serializer.fromJson<int>(json['serviceRecordId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileType: serializer.fromJson<String>(json['fileType']),
      fileName: serializer.fromJson<String>(json['fileName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceRecordId': serializer.toJson<int>(serviceRecordId),
      'filePath': serializer.toJson<String>(filePath),
      'fileType': serializer.toJson<String>(fileType),
      'fileName': serializer.toJson<String>(fileName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Attachment copyWith(
          {int? id,
          int? serviceRecordId,
          String? filePath,
          String? fileType,
          String? fileName,
          DateTime? createdAt}) =>
      Attachment(
        id: id ?? this.id,
        serviceRecordId: serviceRecordId ?? this.serviceRecordId,
        filePath: filePath ?? this.filePath,
        fileType: fileType ?? this.fileType,
        fileName: fileName ?? this.fileName,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('serviceRecordId: $serviceRecordId, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, serviceRecordId, filePath, fileType, fileName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.serviceRecordId == this.serviceRecordId &&
          other.filePath == this.filePath &&
          other.fileType == this.fileType &&
          other.fileName == this.fileName &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<int> id;
  final Value<int> serviceRecordId;
  final Value<String> filePath;
  final Value<String> fileType;
  final Value<String> fileName;
  final Value<DateTime> createdAt;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.serviceRecordId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileType = const Value.absent(),
    this.fileName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int serviceRecordId,
    required String filePath,
    required String fileType,
    required String fileName,
    this.createdAt = const Value.absent(),
  })  : serviceRecordId = Value(serviceRecordId),
        filePath = Value(filePath),
        fileType = Value(fileType),
        fileName = Value(fileName);
  static Insertable<Attachment> custom({
    Expression<int>? id,
    Expression<int>? serviceRecordId,
    Expression<String>? filePath,
    Expression<String>? fileType,
    Expression<String>? fileName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceRecordId != null) 'service_record_id': serviceRecordId,
      if (filePath != null) 'file_path': filePath,
      if (fileType != null) 'file_type': fileType,
      if (fileName != null) 'file_name': fileName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AttachmentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? serviceRecordId,
      Value<String>? filePath,
      Value<String>? fileType,
      Value<String>? fileName,
      Value<DateTime>? createdAt}) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      serviceRecordId: serviceRecordId ?? this.serviceRecordId,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceRecordId.present) {
      map['service_record_id'] = Variable<int>(serviceRecordId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('serviceRecordId: $serviceRecordId, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _intervalMonthsMeta =
      const VerificationMeta('intervalMonths');
  @override
  late final GeneratedColumn<int> intervalMonths = GeneratedColumn<int>(
      'interval_months', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _intervalKmMeta =
      const VerificationMeta('intervalKm');
  @override
  late final GeneratedColumn<int> intervalKm = GeneratedColumn<int>(
      'interval_km', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vehicles (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueMileageMeta =
      const VerificationMeta('dueMileage');
  @override
  late final GeneratedColumn<int> dueMileage = GeneratedColumn<int>(
      'due_mileage', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _serviceTypeMeta =
      const VerificationMeta('serviceType');
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
      'service_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('OTHER'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        intervalMonths,
        intervalKm,
        id,
        vehicleId,
        title,
        note,
        dueDate,
        dueMileage,
        isDone,
        serviceType,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('interval_months')) {
      context.handle(
          _intervalMonthsMeta,
          intervalMonths.isAcceptableOrUnknown(
              data['interval_months']!, _intervalMonthsMeta));
    }
    if (data.containsKey('interval_km')) {
      context.handle(
          _intervalKmMeta,
          intervalKm.isAcceptableOrUnknown(
              data['interval_km']!, _intervalKmMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('due_mileage')) {
      context.handle(
          _dueMileageMeta,
          dueMileage.isAcceptableOrUnknown(
              data['due_mileage']!, _dueMileageMeta));
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('service_type')) {
      context.handle(
          _serviceTypeMeta,
          serviceType.isAcceptableOrUnknown(
              data['service_type']!, _serviceTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      intervalMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_months']),
      intervalKm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_km']),
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vehicle_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      dueMileage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_mileage']),
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
      serviceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int? intervalMonths;
  final int? intervalKm;
  final int id;
  final int vehicleId;
  final String title;
  final String? note;
  final DateTime? dueDate;
  final int? dueMileage;
  final bool isDone;
  final String serviceType;
  final DateTime createdAt;
  const Reminder(
      {this.intervalMonths,
      this.intervalKm,
      required this.id,
      required this.vehicleId,
      required this.title,
      this.note,
      this.dueDate,
      this.dueMileage,
      required this.isDone,
      required this.serviceType,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || intervalMonths != null) {
      map['interval_months'] = Variable<int>(intervalMonths);
    }
    if (!nullToAbsent || intervalKm != null) {
      map['interval_km'] = Variable<int>(intervalKm);
    }
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || dueMileage != null) {
      map['due_mileage'] = Variable<int>(dueMileage);
    }
    map['is_done'] = Variable<bool>(isDone);
    map['service_type'] = Variable<String>(serviceType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      intervalMonths: intervalMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalMonths),
      intervalKm: intervalKm == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalKm),
      id: Value(id),
      vehicleId: Value(vehicleId),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      dueMileage: dueMileage == null && nullToAbsent
          ? const Value.absent()
          : Value(dueMileage),
      isDone: Value(isDone),
      serviceType: Value(serviceType),
      createdAt: Value(createdAt),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      intervalMonths: serializer.fromJson<int?>(json['intervalMonths']),
      intervalKm: serializer.fromJson<int?>(json['intervalKm']),
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      dueMileage: serializer.fromJson<int?>(json['dueMileage']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      serviceType: serializer.fromJson<String>(json['serviceType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'intervalMonths': serializer.toJson<int?>(intervalMonths),
      'intervalKm': serializer.toJson<int?>(intervalKm),
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'dueMileage': serializer.toJson<int?>(dueMileage),
      'isDone': serializer.toJson<bool>(isDone),
      'serviceType': serializer.toJson<String>(serviceType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Reminder copyWith(
          {Value<int?> intervalMonths = const Value.absent(),
          Value<int?> intervalKm = const Value.absent(),
          int? id,
          int? vehicleId,
          String? title,
          Value<String?> note = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<int?> dueMileage = const Value.absent(),
          bool? isDone,
          String? serviceType,
          DateTime? createdAt}) =>
      Reminder(
        intervalMonths:
            intervalMonths.present ? intervalMonths.value : this.intervalMonths,
        intervalKm: intervalKm.present ? intervalKm.value : this.intervalKm,
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        title: title ?? this.title,
        note: note.present ? note.value : this.note,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        dueMileage: dueMileage.present ? dueMileage.value : this.dueMileage,
        isDone: isDone ?? this.isDone,
        serviceType: serviceType ?? this.serviceType,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueMileage: $dueMileage, ')
          ..write('isDone: $isDone, ')
          ..write('serviceType: $serviceType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(intervalMonths, intervalKm, id, vehicleId,
      title, note, dueDate, dueMileage, isDone, serviceType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.intervalMonths == this.intervalMonths &&
          other.intervalKm == this.intervalKm &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.title == this.title &&
          other.note == this.note &&
          other.dueDate == this.dueDate &&
          other.dueMileage == this.dueMileage &&
          other.isDone == this.isDone &&
          other.serviceType == this.serviceType &&
          other.createdAt == this.createdAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int?> intervalMonths;
  final Value<int?> intervalKm;
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<String> title;
  final Value<String?> note;
  final Value<DateTime?> dueDate;
  final Value<int?> dueMileage;
  final Value<bool> isDone;
  final Value<String> serviceType;
  final Value<DateTime> createdAt;
  const RemindersCompanion({
    this.intervalMonths = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueMileage = const Value.absent(),
    this.isDone = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.intervalMonths = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.id = const Value.absent(),
    required int vehicleId,
    required String title,
    this.note = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueMileage = const Value.absent(),
    this.isDone = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : vehicleId = Value(vehicleId),
        title = Value(title);
  static Insertable<Reminder> custom({
    Expression<int>? intervalMonths,
    Expression<int>? intervalKm,
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<String>? title,
    Expression<String>? note,
    Expression<DateTime>? dueDate,
    Expression<int>? dueMileage,
    Expression<bool>? isDone,
    Expression<String>? serviceType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (intervalMonths != null) 'interval_months': intervalMonths,
      if (intervalKm != null) 'interval_km': intervalKm,
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (dueDate != null) 'due_date': dueDate,
      if (dueMileage != null) 'due_mileage': dueMileage,
      if (isDone != null) 'is_done': isDone,
      if (serviceType != null) 'service_type': serviceType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RemindersCompanion copyWith(
      {Value<int?>? intervalMonths,
      Value<int?>? intervalKm,
      Value<int>? id,
      Value<int>? vehicleId,
      Value<String>? title,
      Value<String?>? note,
      Value<DateTime?>? dueDate,
      Value<int?>? dueMileage,
      Value<bool>? isDone,
      Value<String>? serviceType,
      Value<DateTime>? createdAt}) {
    return RemindersCompanion(
      intervalMonths: intervalMonths ?? this.intervalMonths,
      intervalKm: intervalKm ?? this.intervalKm,
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      isDone: isDone ?? this.isDone,
      serviceType: serviceType ?? this.serviceType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (intervalMonths.present) {
      map['interval_months'] = Variable<int>(intervalMonths.value);
    }
    if (intervalKm.present) {
      map['interval_km'] = Variable<int>(intervalKm.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (dueMileage.present) {
      map['due_mileage'] = Variable<int>(dueMileage.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueMileage: $dueMileage, ')
          ..write('isDone: $isDone, ')
          ..write('serviceType: $serviceType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vehicles (id) ON DELETE CASCADE'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _mileageMeta =
      const VerificationMeta('mileage');
  @override
  late final GeneratedColumn<int> mileage = GeneratedColumn<int>(
      'mileage', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _amountCentsMeta =
      const VerificationMeta('amountCents');
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
      'amount_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fuelMeta = const VerificationMeta('fuel');
  @override
  late final GeneratedColumn<String> fuel = GeneratedColumn<String>(
      'fuel', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fullTankMeta =
      const VerificationMeta('fullTank');
  @override
  late final GeneratedColumn<bool> fullTank = GeneratedColumn<bool>(
      'full_tank', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("full_tank" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _missedMeta = const VerificationMeta('missed');
  @override
  late final GeneratedColumn<bool> missed = GeneratedColumn<bool>(
      'missed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("missed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
      'place', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _importKeyMeta =
      const VerificationMeta('importKey');
  @override
  late final GeneratedColumn<String> importKey = GeneratedColumn<String>(
      'import_key', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        vehicleId,
        kind,
        title,
        category,
        date,
        mileage,
        amountCents,
        quantity,
        fuel,
        fullTank,
        missed,
        place,
        note,
        importKey
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mileage')) {
      context.handle(_mileageMeta,
          mileage.isAcceptableOrUnknown(data['mileage']!, _mileageMeta));
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
          _amountCentsMeta,
          amountCents.isAcceptableOrUnknown(
              data['amount_cents']!, _amountCentsMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('fuel')) {
      context.handle(
          _fuelMeta, fuel.isAcceptableOrUnknown(data['fuel']!, _fuelMeta));
    }
    if (data.containsKey('full_tank')) {
      context.handle(_fullTankMeta,
          fullTank.isAcceptableOrUnknown(data['full_tank']!, _fullTankMeta));
    }
    if (data.containsKey('missed')) {
      context.handle(_missedMeta,
          missed.isAcceptableOrUnknown(data['missed']!, _missedMeta));
    }
    if (data.containsKey('place')) {
      context.handle(
          _placeMeta, place.isAcceptableOrUnknown(data['place']!, _placeMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('import_key')) {
      context.handle(_importKeyMeta,
          importKey.isAcceptableOrUnknown(data['import_key']!, _importKeyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vehicle_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      mileage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mileage']),
      amountCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_cents']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity']),
      fuel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuel']),
      fullTank: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}full_tank'])!,
      missed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}missed'])!,
      place: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      importKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}import_key']),
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final int id;
  final int vehicleId;
  final String kind;
  final String title;
  final String category;
  final DateTime date;
  final int? mileage;
  final int? amountCents;
  final double? quantity;
  final String? fuel;
  final bool fullTank;
  final bool missed;
  final String? place;
  final String? note;
  final String? importKey;
  const LedgerEntry(
      {required this.id,
      required this.vehicleId,
      required this.kind,
      required this.title,
      required this.category,
      required this.date,
      this.mileage,
      this.amountCents,
      this.quantity,
      this.fuel,
      required this.fullTank,
      required this.missed,
      this.place,
      this.note,
      this.importKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || mileage != null) {
      map['mileage'] = Variable<int>(mileage);
    }
    if (!nullToAbsent || amountCents != null) {
      map['amount_cents'] = Variable<int>(amountCents);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || fuel != null) {
      map['fuel'] = Variable<String>(fuel);
    }
    map['full_tank'] = Variable<bool>(fullTank);
    map['missed'] = Variable<bool>(missed);
    if (!nullToAbsent || place != null) {
      map['place'] = Variable<String>(place);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || importKey != null) {
      map['import_key'] = Variable<String>(importKey);
    }
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      kind: Value(kind),
      title: Value(title),
      category: Value(category),
      date: Value(date),
      mileage: mileage == null && nullToAbsent
          ? const Value.absent()
          : Value(mileage),
      amountCents: amountCents == null && nullToAbsent
          ? const Value.absent()
          : Value(amountCents),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      fuel: fuel == null && nullToAbsent ? const Value.absent() : Value(fuel),
      fullTank: Value(fullTank),
      missed: Value(missed),
      place:
          place == null && nullToAbsent ? const Value.absent() : Value(place),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      importKey: importKey == null && nullToAbsent
          ? const Value.absent()
          : Value(importKey),
    );
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      mileage: serializer.fromJson<int?>(json['mileage']),
      amountCents: serializer.fromJson<int?>(json['amountCents']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      fuel: serializer.fromJson<String?>(json['fuel']),
      fullTank: serializer.fromJson<bool>(json['fullTank']),
      missed: serializer.fromJson<bool>(json['missed']),
      place: serializer.fromJson<String?>(json['place']),
      note: serializer.fromJson<String?>(json['note']),
      importKey: serializer.fromJson<String?>(json['importKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<DateTime>(date),
      'mileage': serializer.toJson<int?>(mileage),
      'amountCents': serializer.toJson<int?>(amountCents),
      'quantity': serializer.toJson<double?>(quantity),
      'fuel': serializer.toJson<String?>(fuel),
      'fullTank': serializer.toJson<bool>(fullTank),
      'missed': serializer.toJson<bool>(missed),
      'place': serializer.toJson<String?>(place),
      'note': serializer.toJson<String?>(note),
      'importKey': serializer.toJson<String?>(importKey),
    };
  }

  LedgerEntry copyWith(
          {int? id,
          int? vehicleId,
          String? kind,
          String? title,
          String? category,
          DateTime? date,
          Value<int?> mileage = const Value.absent(),
          Value<int?> amountCents = const Value.absent(),
          Value<double?> quantity = const Value.absent(),
          Value<String?> fuel = const Value.absent(),
          bool? fullTank,
          bool? missed,
          Value<String?> place = const Value.absent(),
          Value<String?> note = const Value.absent(),
          Value<String?> importKey = const Value.absent()}) =>
      LedgerEntry(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        category: category ?? this.category,
        date: date ?? this.date,
        mileage: mileage.present ? mileage.value : this.mileage,
        amountCents: amountCents.present ? amountCents.value : this.amountCents,
        quantity: quantity.present ? quantity.value : this.quantity,
        fuel: fuel.present ? fuel.value : this.fuel,
        fullTank: fullTank ?? this.fullTank,
        missed: missed ?? this.missed,
        place: place.present ? place.value : this.place,
        note: note.present ? note.value : this.note,
        importKey: importKey.present ? importKey.value : this.importKey,
      );
  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('mileage: $mileage, ')
          ..write('amountCents: $amountCents, ')
          ..write('quantity: $quantity, ')
          ..write('fuel: $fuel, ')
          ..write('fullTank: $fullTank, ')
          ..write('missed: $missed, ')
          ..write('place: $place, ')
          ..write('note: $note, ')
          ..write('importKey: $importKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      vehicleId,
      kind,
      title,
      category,
      date,
      mileage,
      amountCents,
      quantity,
      fuel,
      fullTank,
      missed,
      place,
      note,
      importKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.category == this.category &&
          other.date == this.date &&
          other.mileage == this.mileage &&
          other.amountCents == this.amountCents &&
          other.quantity == this.quantity &&
          other.fuel == this.fuel &&
          other.fullTank == this.fullTank &&
          other.missed == this.missed &&
          other.place == this.place &&
          other.note == this.note &&
          other.importKey == this.importKey);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> category;
  final Value<DateTime> date;
  final Value<int?> mileage;
  final Value<int?> amountCents;
  final Value<double?> quantity;
  final Value<String?> fuel;
  final Value<bool> fullTank;
  final Value<bool> missed;
  final Value<String?> place;
  final Value<String?> note;
  final Value<String?> importKey;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.mileage = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.quantity = const Value.absent(),
    this.fuel = const Value.absent(),
    this.fullTank = const Value.absent(),
    this.missed = const Value.absent(),
    this.place = const Value.absent(),
    this.note = const Value.absent(),
    this.importKey = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required String kind,
    required String title,
    required String category,
    required DateTime date,
    this.mileage = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.quantity = const Value.absent(),
    this.fuel = const Value.absent(),
    this.fullTank = const Value.absent(),
    this.missed = const Value.absent(),
    this.place = const Value.absent(),
    this.note = const Value.absent(),
    this.importKey = const Value.absent(),
  })  : vehicleId = Value(vehicleId),
        kind = Value(kind),
        title = Value(title),
        category = Value(category),
        date = Value(date);
  static Insertable<LedgerEntry> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<int>? mileage,
    Expression<int>? amountCents,
    Expression<double>? quantity,
    Expression<String>? fuel,
    Expression<bool>? fullTank,
    Expression<bool>? missed,
    Expression<String>? place,
    Expression<String>? note,
    Expression<String>? importKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (mileage != null) 'mileage': mileage,
      if (amountCents != null) 'amount_cents': amountCents,
      if (quantity != null) 'quantity': quantity,
      if (fuel != null) 'fuel': fuel,
      if (fullTank != null) 'full_tank': fullTank,
      if (missed != null) 'missed': missed,
      if (place != null) 'place': place,
      if (note != null) 'note': note,
      if (importKey != null) 'import_key': importKey,
    });
  }

  LedgerEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? vehicleId,
      Value<String>? kind,
      Value<String>? title,
      Value<String>? category,
      Value<DateTime>? date,
      Value<int?>? mileage,
      Value<int?>? amountCents,
      Value<double?>? quantity,
      Value<String?>? fuel,
      Value<bool>? fullTank,
      Value<bool>? missed,
      Value<String?>? place,
      Value<String?>? note,
      Value<String?>? importKey}) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      amountCents: amountCents ?? this.amountCents,
      quantity: quantity ?? this.quantity,
      fuel: fuel ?? this.fuel,
      fullTank: fullTank ?? this.fullTank,
      missed: missed ?? this.missed,
      place: place ?? this.place,
      note: note ?? this.note,
      importKey: importKey ?? this.importKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mileage.present) {
      map['mileage'] = Variable<int>(mileage.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (fuel.present) {
      map['fuel'] = Variable<String>(fuel.value);
    }
    if (fullTank.present) {
      map['full_tank'] = Variable<bool>(fullTank.value);
    }
    if (missed.present) {
      map['missed'] = Variable<bool>(missed.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (importKey.present) {
      map['import_key'] = Variable<String>(importKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('mileage: $mileage, ')
          ..write('amountCents: $amountCents, ')
          ..write('quantity: $quantity, ')
          ..write('fuel: $fuel, ')
          ..write('fullTank: $fullTank, ')
          ..write('missed: $missed, ')
          ..write('place: $place, ')
          ..write('note: $note, ')
          ..write('importKey: $importKey')
          ..write(')'))
        .toString();
  }
}

class $ServiceItemsTable extends ServiceItems
    with TableInfo<$ServiceItemsTable, ServiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<int> serviceId = GeneratedColumn<int>(
      'service_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES service_records (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountCentsMeta =
      const VerificationMeta('amountCents');
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
      'amount_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serviceId, name, kind, amountCents];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_items';
  @override
  VerificationContext validateIntegrity(Insertable<ServiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
          _amountCentsMeta,
          amountCents.isAcceptableOrUnknown(
              data['amount_cents']!, _amountCentsMeta));
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}service_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      amountCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_cents'])!,
    );
  }

  @override
  $ServiceItemsTable createAlias(String alias) {
    return $ServiceItemsTable(attachedDatabase, alias);
  }
}

class ServiceItem extends DataClass implements Insertable<ServiceItem> {
  final int id;
  final int serviceId;
  final String name;
  final String kind;
  final int amountCents;
  const ServiceItem(
      {required this.id,
      required this.serviceId,
      required this.name,
      required this.kind,
      required this.amountCents});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_id'] = Variable<int>(serviceId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['amount_cents'] = Variable<int>(amountCents);
    return map;
  }

  ServiceItemsCompanion toCompanion(bool nullToAbsent) {
    return ServiceItemsCompanion(
      id: Value(id),
      serviceId: Value(serviceId),
      name: Value(name),
      kind: Value(kind),
      amountCents: Value(amountCents),
    );
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceItem(
      id: serializer.fromJson<int>(json['id']),
      serviceId: serializer.fromJson<int>(json['serviceId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceId': serializer.toJson<int>(serviceId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'amountCents': serializer.toJson<int>(amountCents),
    };
  }

  ServiceItem copyWith(
          {int? id,
          int? serviceId,
          String? name,
          String? kind,
          int? amountCents}) =>
      ServiceItem(
        id: id ?? this.id,
        serviceId: serviceId ?? this.serviceId,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        amountCents: amountCents ?? this.amountCents,
      );
  @override
  String toString() {
    return (StringBuffer('ServiceItem(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('amountCents: $amountCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serviceId, name, kind, amountCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceItem &&
          other.id == this.id &&
          other.serviceId == this.serviceId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.amountCents == this.amountCents);
}

class ServiceItemsCompanion extends UpdateCompanion<ServiceItem> {
  final Value<int> id;
  final Value<int> serviceId;
  final Value<String> name;
  final Value<String> kind;
  final Value<int> amountCents;
  const ServiceItemsCompanion({
    this.id = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountCents = const Value.absent(),
  });
  ServiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int serviceId,
    required String name,
    required String kind,
    required int amountCents,
  })  : serviceId = Value(serviceId),
        name = Value(name),
        kind = Value(kind),
        amountCents = Value(amountCents);
  static Insertable<ServiceItem> custom({
    Expression<int>? id,
    Expression<int>? serviceId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? amountCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (amountCents != null) 'amount_cents': amountCents,
    });
  }

  ServiceItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? serviceId,
      Value<String>? name,
      Value<String>? kind,
      Value<int>? amountCents}) {
    return ServiceItemsCompanion(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      amountCents: amountCents ?? this.amountCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<int>(serviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('amountCents: $amountCents')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) => AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCategoriesTable extends CustomCategories
    with TableInfo<$CustomCategoriesTable, CustomCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_categories';
  @override
  VerificationContext validateIntegrity(Insertable<CustomCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CustomCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCategory(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CustomCategoriesTable createAlias(String alias) {
    return $CustomCategoriesTable(attachedDatabase, alias);
  }
}

class CustomCategory extends DataClass implements Insertable<CustomCategory> {
  final String name;
  const CustomCategory({required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    return map;
  }

  CustomCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomCategoriesCompanion(
      name: Value(name),
    );
  }

  factory CustomCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCategory(
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
    };
  }

  CustomCategory copyWith({String? name}) => CustomCategory(
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('CustomCategory(')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => name.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCategory && other.name == this.name);
}

class CustomCategoriesCompanion extends UpdateCompanion<CustomCategory> {
  final Value<String> name;
  final Value<int> rowid;
  const CustomCategoriesCompanion({
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCategoriesCompanion.insert({
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CustomCategory> custom({
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCategoriesCompanion copyWith({Value<String>? name, Value<int>? rowid}) {
    return CustomCategoriesCompanion(
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoriesCompanion(')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $ServiceRecordsTable serviceRecords = $ServiceRecordsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $ServiceItemsTable serviceItems = $ServiceItemsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CustomCategoriesTable customCategories =
      $CustomCategoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        vehicles,
        serviceRecords,
        attachments,
        reminders,
        ledgerEntries,
        serviceItems,
        appSettings,
        customCategories
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('vehicles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('service_records', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('service_records',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('vehicles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reminders', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('vehicles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('ledger_entries', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('service_records',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('service_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}
