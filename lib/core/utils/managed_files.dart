import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';

/// Remove bytes only after the last live reference has been removed.
Future<void> deleteManagedFile(AppDatabase db, String path) async {
  try {
    await db.transaction(() async {
      final attachment = await (db.select(db.attachments)
            ..where((a) => a.filePath.equals(path))
            ..limit(1))
          .get();
      final vehicle = await (db.select(db.vehicles)
            ..where((v) => v.photoPath.equals(path))
            ..limit(1))
          .get();
      if (attachment.isNotEmpty || vehicle.isNotEmpty) return;
      final drafts = await (db.select(db.appSettings)
            ..where((s) => s.key.like('draft:%')))
          .get();
      bool references(Object? value) =>
          value == path ||
          (value is List && value.any(references)) ||
          (value is Map && value.values.any(references));
      for (final draft in drafts) {
        if (references(jsonDecode(draft.value))) return;
      }
      final file = File(path);
      if (await file.exists()) await file.delete();
    });
  } catch (_) {/* unreferenced files may be cleaned up later */}
}
