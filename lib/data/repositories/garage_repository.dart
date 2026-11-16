import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../../domain/calculations.dart';

class TimelineEntry {
  final int id, vehicleId;
  final String kind, title, category, note, place;
  final DateTime date;
  final int? mileage, cents;
  const TimelineEntry(
      {required this.id,
      required this.vehicleId,
      required this.kind,
      required this.title,
      required this.category,
      required this.date,
      this.mileage,
      this.cents,
      this.note = '',
      this.place = ''});
}

class GarageRepository {
  final AppDatabase db;
  GarageRepository(this.db);
  Stream<int> changes() => db
      .customSelect('SELECT COUNT(*) AS n FROM vehicles', readsFrom: {
        db.vehicles,
        db.serviceRecords,
        db.ledgerEntries,
        db.reminders,
        db.appSettings,
        db.customCategories,
        db.attachments,
        db.serviceItems
      })
      .watch()
      .map((r) => r.first.read<int>('n'));
  Future<List<TimelineEntry>> timeline(int vehicleId) async {
    final rows = await db.customSelect('''
SELECT id, vehicle_id, 'SERVICE' AS kind, title, service_type AS category, service_date AS date, mileage, cost_cents AS cents, COALESCE(description,'') AS note, COALESCE(workshop,'') AS place FROM service_records WHERE vehicle_id = ?
UNION ALL
SELECT id, vehicle_id, kind, title, category, date, mileage, amount_cents, COALESCE(note,''), COALESCE(place,'') FROM ledger_entries WHERE vehicle_id = ?
ORDER BY date DESC, id DESC
''', variables: [
      Variable.withInt(vehicleId),
      Variable.withInt(vehicleId)
    ]).get();
    return rows
        .map((r) => TimelineEntry(
            id: r.read<int>('id'),
            vehicleId: r.read<int>('vehicle_id'),
            kind: r.read<String>('kind'),
            title: r.read<String>('title'),
            category: r.read<String>('category'),
            date:
                DateTime.fromMillisecondsSinceEpoch(r.read<int>('date') * 1000),
            mileage: r.readNullable<int>('mileage'),
            cents: r.readNullable<int>('cents'),
            note: r.read<String>('note'),
            place: r.read<String>('place')))
        .toList();
  }

  Future<String?> setting(String key) async =>
      (await (db.select(db.appSettings)..where((s) => s.key.equals(key)))
              .getSingleOrNull())
          ?.value;
  Future<void> setSetting(String key, String value) =>
      db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value));
  Future<void> mileage(int vehicleId, int value) async {
    if (value < 0) throw ArgumentError('Przebieg nie może być ujemny');
    await (db.update(db.vehicles)
          ..where((v) =>
              v.id.equals(vehicleId) &
              v.currentMileage.isSmallerThanValue(value)))
        .write(VehiclesCompanion(currentMileage: Value(value)));
  }

  Future<int> saveLedger(LedgerEntriesCompanion entry, {int? id}) =>
      db.transaction(() async {
        final result = id ?? await db.into(db.ledgerEntries).insert(entry);
        if (id != null) {
          await (db.update(db.ledgerEntries)..where((e) => e.id.equals(id)))
              .write(entry);
        }
        if (entry.mileage.present && entry.mileage.value != null) {
          await mileage(entry.vehicleId.value, entry.mileage.value!);
        }
        return result;
      });
  Future<bool> duplicate(int vehicleId, String title, DateTime date, int? cents,
      {int? excludeId, String kind = 'SERVICE'}) async {
    final rows = await timeline(vehicleId);
    return rows.any((e) =>
        e.kind == kind &&
        e.id != excludeId &&
        e.title.trim().toLowerCase() == title.trim().toLowerCase() &&
        e.cents == cents &&
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day);
  }

  Future<void> complete(Reminder r, {bool createService = false}) =>
      db.transaction(() async {
        if (r.isDone) return;
        final changed = await (db.update(db.reminders)
              ..where((e) => e.id.equals(r.id) & e.isDone.equals(false)))
            .write(const RemindersCompanion(isDone: Value(true)));
        if (changed == 0) return;
        final vehicle = await (db.select(db.vehicles)
              ..where((e) => e.id.equals(r.vehicleId)))
            .getSingle();
        final now = DateTime.now();
        if (createService) {
          await db.into(db.serviceRecords).insert(
              ServiceRecordsCompanion.insert(
                  vehicleId: r.vehicleId,
                  title: r.title,
                  serviceDate: now,
                  mileage: Value(vehicle.currentMileage),
                  serviceType: Value(r.serviceType)));
        }
        if (r.intervalMonths != null || r.intervalKm != null) {
          await db.into(db.reminders).insert(RemindersCompanion.insert(
              vehicleId: r.vehicleId,
              title: r.title,
              note: Value(r.note),
              serviceType: Value(r.serviceType),
              intervalMonths: Value(r.intervalMonths),
              intervalKm: Value(r.intervalKm),
              dueDate: Value(r.intervalMonths == null
                  ? null
                  : addCalendarMonths(now, r.intervalMonths!)),
              dueMileage: Value(r.intervalKm == null
                  ? null
                  : vehicle.currentMileage + r.intervalKm!)));
        }
      });
}
