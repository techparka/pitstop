import 'package:drift/drift.dart';

class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get make => text()();
  TextColumn get model => text()();
  IntColumn get year => integer()();
  TextColumn get licensePlate => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get currentMileage => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class ServiceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get serviceDate => dateTime()();
  IntColumn get mileage => integer().nullable()();
  RealColumn get cost => real().nullable()();
  TextColumn get serviceType =>
      text().withDefault(const Constant('OTHER'))();
  TextColumn get workshop => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serviceRecordId => integer().references(ServiceRecords, #id,
      onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()(); // IMAGE or PDF
  TextColumn get fileName => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get dueMileage => integer().nullable()();
  BoolColumn get isDone =>
      boolean().withDefault(const Constant(false))();
  TextColumn get serviceType =>
      text().withDefault(const Constant('OTHER'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
