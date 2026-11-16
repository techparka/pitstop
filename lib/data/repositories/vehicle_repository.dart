import 'dart:io';
import 'package:drift/drift.dart';

import '../../core/utils/managed_files.dart';
import '../database/app_database.dart';

class VehicleRepository {
  final AppDatabase _db;
  VehicleRepository(this._db);

  Stream<List<Vehicle>> watchAll() => (_db.select(_db.vehicles)
        ..orderBy([(v) => OrderingTerm.desc(v.createdAt)]))
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

    final paths = <String>[];
    for (final svc in services) {
      final attachments = await (_db.select(_db.attachments)
            ..where((a) => a.serviceRecordId.equals(svc.id)))
          .get();
      paths.addAll(attachments.map((a) => a.filePath));
    }
    final vehicle = await getById(id);
    if (vehicle.photoPath != null) paths.add(vehicle.photoPath!);
    await delete(id);
    for (final path in paths) {
      try {
        await deleteManagedFile(_db, path);
      } on FileSystemException {/* unreferenced file */}
    }
  }
}
