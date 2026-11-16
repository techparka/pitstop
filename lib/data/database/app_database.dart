import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Vehicles,
  ServiceRecords,
  Attachments,
  Reminders,
  LedgerEntries,
  ServiceItems,
  AppSettings,
  CustomCategories
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement(
                'CREATE TABLE IF NOT EXISTS reminders (id INTEGER PRIMARY KEY AUTOINCREMENT, vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE, title TEXT NOT NULL, note TEXT, due_date INTEGER, due_mileage INTEGER, is_done INTEGER NOT NULL DEFAULT 0, service_type TEXT NOT NULL DEFAULT \'OTHER\', created_at INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))');
          }
          if (from < 3) {
            await m.addColumn(vehicles, vehicles.vin);
            await m.addColumn(vehicles, vehicles.powertrain);
            await m.addColumn(vehicles, vehicles.purchaseDate);
            await m.addColumn(vehicles, vehicles.technicalNotes);
            await m.addColumn(serviceRecords, serviceRecords.costCents);
            await customStatement(
                'UPDATE service_records SET cost_cents = CAST(ROUND(cost * 100) AS INTEGER) WHERE cost IS NOT NULL');
            await m.addColumn(reminders, reminders.intervalMonths);
            await m.addColumn(reminders, reminders.intervalKm);
            await m.createTable(ledgerEntries);
            await m.createTable(serviceItems);
            await m.createTable(appSettings);
            await m.createTable(customCategories);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS service_vehicle_date ON service_records(vehicle_id, service_date DESC)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS ledger_vehicle_date ON ledger_entries(vehicle_id, date DESC)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS reminder_vehicle ON reminders(vehicle_id, is_done)');
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'car_service.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
