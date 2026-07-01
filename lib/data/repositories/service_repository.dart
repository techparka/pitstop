import 'package:drift/drift.dart';

import '../../core/utils/file_helper.dart';
import '../database/app_database.dart';

class ServiceRepository {
  final AppDatabase _db;
  ServiceRepository(this._db);

  Stream<List<ServiceRecord>> watchByVehicle(int vehicleId) =>
      (_db.select(_db.serviceRecords)
            ..where((s) => s.vehicleId.equals(vehicleId))
            ..orderBy([(s) => OrderingTerm.desc(s.serviceDate)]))
          .watch();

  // B3: use watchSingleOrNull to avoid error when row is deleted
  Stream<ServiceRecord?> watchById(int id) =>
      (_db.select(_db.serviceRecords)..where((s) => s.id.equals(id)))
          .watchSingleOrNull();

  Future<ServiceRecord> getById(int id) =>
      (_db.select(_db.serviceRecords)..where((s) => s.id.equals(id)))
          .getSingle();

  Future<int> insert(ServiceRecordsCompanion entry) =>
      _db.into(_db.serviceRecords).insert(entry);

  Future<bool> update(ServiceRecordsCompanion entry) =>
      _db.update(_db.serviceRecords).replace(entry);

  Future<int> delete(int id) =>
      (_db.delete(_db.serviceRecords)..where((s) => s.id.equals(id))).go();

  // B2: delete service record with all associated files
  Future<void> deleteWithFiles(int id) async {
    final attachments = await getAttachments(id);
    for (final att in attachments) {
      await FileHelper.deleteFile(att.filePath);
    }
    await FileHelper.deleteServiceDir(id);
    await delete(id);
  }

  // Attachments
  Stream<List<Attachment>> watchAttachments(int serviceRecordId) =>
      (_db.select(_db.attachments)
            ..where((a) => a.serviceRecordId.equals(serviceRecordId))
            ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
          .watch();

  Future<int> insertAttachment(AttachmentsCompanion entry) =>
      _db.into(_db.attachments).insert(entry);

  Future<int> deleteAttachment(int id) =>
      (_db.delete(_db.attachments)..where((a) => a.id.equals(id))).go();

  Future<List<Attachment>> getAttachments(int serviceRecordId) =>
      (_db.select(_db.attachments)
            ..where((a) => a.serviceRecordId.equals(serviceRecordId)))
          .get();
}
