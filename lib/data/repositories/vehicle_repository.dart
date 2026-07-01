import 'package:drift/drift.dart';

import '../../core/utils/file_helper.dart';
import '../database/app_database.dart';

class VehicleRepository {
  final AppDatabase _db;
  VehicleRepository(this._db);

  Stream<List<Vehicle>> watchAll() =>
      (_db.select(_db.vehicles)..orderBy([(v) => OrderingTerm.desc(v.createdAt)]))
          .watch();

  // B3: use watchSingleOrNull to avoid error when row is deleted
  Stream<Vehicle?> watchById(int id) =>
      (_db.select(_db.vehicles)..where((v) => v.id.equals(id)))
          .watchSingleOrNull();

  Future<Vehicle> getById(int id) =>
      (_db.select(_db.vehicles)..where((v) => v.id.equals(id))).getSingle();

  Future<int> insert(VehiclesCompanion entry) =>
      _db.into(_db.vehicles).insert(entry);

  Future<bool> update(VehiclesCompanion entry) =>
      _db.update(_db.vehicles).replace(entry);

  // Partial update (only the fields present in [entry]); uses write, not replace.
  Future<int> updateFields(int id, VehiclesCompanion entry) =>
      (_db.update(_db.vehicles)..where((v) => v.id.equals(id))).write(entry);

  Future<int> delete(int id) =>
      (_db.delete(_db.vehicles)..where((v) => v.id.equals(id))).go();

  // B2: delete vehicle with all associated files
  Future<void> deleteWithFiles(int id) async {
    // Fetch all service records for this vehicle to delete their files
    final services = await (_db.select(_db.serviceRecords)
          ..where((s) => s.vehicleId.equals(id)))
        .get();

    for (final svc in services) {
      // Get attachments for each service
      final attachments = await (_db.select(_db.attachments)
            ..where((a) => a.serviceRecordId.equals(svc.id)))
          .get();
      for (final att in attachments) {
        await FileHelper.deleteFile(att.filePath);
      }
      await FileHelper.deleteServiceDir(svc.id);
    }

    // Delete vehicle photo directory
    await FileHelper.deleteVehicleDir(id);

    // Delete from DB (FK cascade removes service_records, attachments, reminders)
    await delete(id);
  }
}
