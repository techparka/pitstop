import 'dart:io';
import 'package:drift/drift.dart';

import '../../core/utils/file_helper.dart';
import '../../core/utils/managed_files.dart';
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

  /// Save the record and its odometer update as one database operation.
  Future<int> save(ServiceRecordsCompanion entry,
      {bool isEdit = false,
      List<({String path, String name, String type})> attachments = const [],
      Set<int> deleteAttachmentIds = const {},
      List<({String name, String kind, int cents})>? items}) async {
    final prepared = <({String path, String name, String type})>[];
    final removed = <Attachment>[];
    try {
      for (final att in attachments) {
        prepared.add((
          path: await FileHelper.prepareAttachment(att.path),
          name: att.name,
          type: att.type
        ));
      }
      final result = await _db.transaction(() async {
        if (entry.cost.present) {
          entry = entry.copyWith(
              costCents: Value(entry.cost.value == null
                  ? null
                  : (entry.cost.value! * 100).round()));
        }
        final int serviceId;
        if (isEdit) {
          if (!await update(entry)) {
            throw StateError('Nie znaleziono wpisu serwisu.');
          }
          serviceId = entry.id.value;
        } else {
          serviceId = await insert(entry);
        }

        final mileage = entry.mileage;
        if (mileage.present && mileage.value != null) {
          // A partial write preserves the required vehicle profile fields.
          await (_db.update(_db.vehicles)
                ..where((v) =>
                    v.id.equals(entry.vehicleId.value) &
                    v.currentMileage.isSmallerThanValue(mileage.value!)))
              .write(VehiclesCompanion(currentMileage: Value(mileage.value!)));
        }
        if (items != null) {
          await (_db.delete(_db.serviceItems)
                ..where((i) => i.serviceId.equals(serviceId)))
              .go();
          for (final item in items) {
            await _db.into(_db.serviceItems).insert(
                ServiceItemsCompanion.insert(
                    serviceId: serviceId,
                    name: item.name,
                    kind: item.kind,
                    amountCents: item.cents));
          }
        }
        if (deleteAttachmentIds.isNotEmpty) {
          removed.addAll(await (_db.select(_db.attachments)
                ..where((a) =>
                    a.serviceRecordId.equals(serviceId) &
                    a.id.isIn(deleteAttachmentIds)))
              .get());
          await (_db.delete(_db.attachments)
                ..where((a) =>
                    a.serviceRecordId.equals(serviceId) &
                    a.id.isIn(deleteAttachmentIds)))
              .go();
        }
        for (final att in prepared) {
          await _db.into(_db.attachments).insert(AttachmentsCompanion.insert(
              serviceRecordId: serviceId,
              filePath: att.path,
              fileType: att.type,
              fileName: att.name));
        }
        return serviceId;
      });
      for (final att in removed) {
        try {
          await deleteManagedFile(_db, att.filePath);
        } on FileSystemException {/* safely leave unreferenced file */}
      }
      return result;
    } catch (_) {
      for (final att in prepared) {
        try {
          await FileHelper.deleteFile(att.path);
        } on FileSystemException {/* retryable cleanup */}
      }
      rethrow;
    }
  }

  Future<int> delete(int id) =>
      (_db.delete(_db.serviceRecords)..where((s) => s.id.equals(id))).go();

  // B2: delete service record with all associated files
  Future<void> deleteWithFiles(int id) async {
    final attachments = await getAttachments(id);
    await delete(id);
    for (final att in attachments) {
      try {
        await deleteManagedFile(_db, att.filePath);
      } on FileSystemException {/* unreferenced file */}
    }
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
