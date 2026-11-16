import 'package:drift/drift.dart';

class Vehicles extends Table {
  TextColumn get vin => text().nullable()();
  TextColumn get powertrain => text().withDefault(const Constant('Benzyna'))();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  TextColumn get technicalNotes => text().nullable()();
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get make => text()();
  TextColumn get model => text()();
  IntColumn get year => integer()();
  TextColumn get licensePlate => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get currentMileage => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ServiceRecords extends Table {
  IntColumn get costCents => integer().nullable()();
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get serviceDate => dateTime()();
  IntColumn get mileage => integer().nullable()();
  RealColumn get cost => real().nullable()();
  TextColumn get serviceType => text().withDefault(const Constant('OTHER'))();
  TextColumn get workshop => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serviceRecordId =>
      integer().references(ServiceRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()(); // IMAGE, INVOICE_IMAGE or PDF
  TextColumn get fileName => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Reminders extends Table {
  IntColumn get intervalMonths => integer().nullable()();
  IntColumn get intervalKm => integer().nullable()();
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get dueMileage => integer().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  TextColumn get serviceType => text().withDefault(const Constant('OTHER'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Fuel, charging and other expenses share a timeline, but never service totals.
class LedgerEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()(); // FUEL, CHARGE, EXPENSE, MILEAGE
  TextColumn get title => text()();
  TextColumn get category => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get mileage => integer().nullable()();
  IntColumn get amountCents => integer().nullable()();
  RealColumn get quantity => real().nullable()();
  TextColumn get fuel => text().nullable()();
  BoolColumn get fullTank => boolean().withDefault(const Constant(true))();
  BoolColumn get missed => boolean().withDefault(const Constant(false))();
  TextColumn get place => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get importKey => text().nullable().unique()();
}

class ServiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serviceId =>
      integer().references(ServiceRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  IntColumn get amountCents => integer()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class CustomCategories extends Table {
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {name};
}
