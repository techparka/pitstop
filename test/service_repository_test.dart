import 'dart:ffi';
import 'dart:io';

import 'package:car_service/data/database/app_database.dart';
import 'package:car_service/data/repositories/service_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isWindows) {
    open.overrideFor(
        OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
  }

  late AppDatabase db;
  late ServiceRepository repository;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ServiceRepository(db);
    vehicleId = await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          name: 'Test car',
          make: 'Toyota',
          model: 'Corolla',
          year: 2020,
          currentMileage: const Value(100000),
        ));
  });

  tearDown(() => db.close());

  ServiceRecordsCompanion entry({int? mileage}) =>
      ServiceRecordsCompanion.insert(
        vehicleId: vehicleId,
        title: 'Wymiana oleju',
        serviceDate: DateTime(2026, 10, 29),
        mileage: Value(mileage),
        cost: const Value(450.50),
      );

  test('saving a higher mileage preserves the vehicle and inserts once',
      () async {
    final id = await repository.save(entry(mileage: 220000));
    final vehicle = await db.select(db.vehicles).getSingle();
    expect(vehicle.currentMileage, 220000);
    expect(vehicle.name, 'Test car');
    expect(vehicle.make, 'Toyota');
    expect(vehicle.model, 'Corolla');
    expect(vehicle.year, 2020);
    expect((await db.select(db.serviceRecords).get()).length, 1);
    expect((await repository.getById(id)).cost, 450.50);
  });

  test('older mileage and missing mileage do not lower the odometer', () async {
    await repository.save(entry(mileage: 90000));
    await repository.save(entry());
    expect((await db.select(db.vehicles).getSingle()).currentMileage, 100000);
    expect((await db.select(db.serviceRecords).get()).length, 2);
  });

  test('editing updates the existing record and odometer', () async {
    final id = await repository.save(entry());
    await repository.save(entry(mileage: 120000).copyWith(id: Value(id)),
        isEdit: true);
    expect((await db.select(db.serviceRecords).get()).length, 1);
    expect((await repository.getById(id)).mileage, 120000);
    expect((await db.select(db.vehicles).getSingle()).currentMileage, 120000);
  });

  test('odometer failure rolls back the service instead of leaving a duplicate',
      () async {
    await db.customStatement('''
      CREATE TRIGGER reject_mileage BEFORE UPDATE OF current_mileage ON vehicles
      BEGIN SELECT RAISE(ABORT, 'test failure'); END
    ''');
    await expectLater(
        repository.save(entry(mileage: 220000)), throwsA(anything));
    expect(await db.select(db.serviceRecords).get(), isEmpty);
    expect((await db.select(db.vehicles).getSingle()).currentMileage, 100000);
  });
}
