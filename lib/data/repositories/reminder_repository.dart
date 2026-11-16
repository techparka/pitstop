import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'garage_repository.dart';

class ReminderRepository {
  final AppDatabase _db;
  ReminderRepository(this._db);

  Stream<List<Reminder>> watchByVehicle(int vehicleId) =>
      (_db.select(_db.reminders)
            ..where((r) => r.vehicleId.equals(vehicleId))
            ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
          .watch();

  Stream<List<Reminder>> watchActive(int vehicleId) => (_db
          .select(_db.reminders)
        ..where((r) => r.vehicleId.equals(vehicleId) & r.isDone.equals(false))
        ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
      .watch();

  Future<Reminder?> getById(int id) =>
      (_db.select(_db.reminders)..where((r) => r.id.equals(id)))
          .getSingleOrNull();

  Future<int> insert(RemindersCompanion entry) =>
      _db.into(_db.reminders).insert(entry);

  Future<bool> update(RemindersCompanion entry) =>
      _db.update(_db.reminders).replace(entry);

  Future<int> delete(int id) =>
      (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go();

  Future<void> markDone(int id) async {
    final reminder = await getById(id);
    if (reminder != null) await GarageRepository(_db).complete(reminder);
  }
}
