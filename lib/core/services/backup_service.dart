import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../data/database/app_database.dart';
import '../l10n/app_errors.dart';

class BackupPreview {
  final Map<String, List<Map<String, dynamic>>> tables;
  final Map<String, List<int>> files;
  final DateTime created;
  BackupPreview(this.tables, this.files, this.created);
  int get vehicles => tables['vehicles']!.length;
  int get entries =>
      tables['service_records']!.length + tables['ledger_entries']!.length;
}

class BackupService {
  static const names = [
    'vehicles',
    'service_records',
    'attachments',
    'reminders',
    'ledger_entries',
    'service_items',
    'app_settings',
    'custom_categories'
  ];
  final AppDatabase db;
  final Directory directory;
  BackupService(this.db, this.directory);
  Directory get backups => Directory(p.join(directory.path, 'backups'));
  Future<File> create({bool automatic = false}) async {
    final archive = Archive();
    final hashes = <String, String>{};
    void add(String name, List<int> bytes) {
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
      hashes[name] = sha256.convert(bytes).toString();
    }

    final data = <String, List<Map<String, dynamic>>>{};
    await db.transaction(() async {
      for (final name in names) {
        data[name] = (await db.customSelect('SELECT * FROM "$name"').get())
            .map((r) => Map<String, dynamic>.from(r.data))
            .toList();
      }
      final seen = <String, String>{};
      Future<String> media(String source) async {
        if (seen.containsKey(source)) return seen[source]!;
        final file = File(source);
        if (!await file.exists()) {
          throw const L10nException(AppError.attachmentMissing);
        }
        final extension = p.extension(source).toLowerCase();
        final safe = RegExp(r'^\.[a-z0-9]{1,10}$').hasMatch(extension)
            ? extension
            : '.bin';
        final dest = 'media/${seen.length}$safe';
        seen[source] = dest;
        add(dest, await file.readAsBytes());
        return dest;
      }

      for (final spec in [
        ('vehicles', 'photo_path'),
        ('attachments', 'file_path')
      ]) {
        for (final row in data[spec.$1]!) {
          if (row[spec.$2] != null) {
            row[spec.$2] = await media(row[spec.$2] as String);
          }
        }
      }
      await _draftMedia(data['app_settings']!, media);
      add('data.json', utf8.encode(jsonEncode(data)));
    });
    final manifest = utf8.encode(jsonEncode({
      'format': 1,
      'schema': db.schemaVersion,
      'created': DateTime.now().toIso8601String(),
      'sha256': hashes
    }));
    archive.addFile(ArchiveFile('manifest.json', manifest.length, manifest));
    await backups.create(recursive: true);
    final file = await _reserveName(backups, automatic);
    await file.writeAsBytes(ZipEncoder().encode(archive)!, flush: true);
    if (automatic) {
      final files = await backups
          .list()
          .where((f) => p.basename(f.path).startsWith('auto-') && f is File)
          .cast<File>()
          .toList();
      files.sort((a, b) => b.path.compareTo(a.path));
      for (final old in files.skip(5)) {
        await old.delete();
      }
    }
    return file;
  }

  /// Ostatni przydzielony znacznik nazwy kopii.
  static int _lastStamp = 0;

  /// Rezerwuje nazwę pliku kopii.
  ///
  /// Znacznik `microsecondsSinceEpoch` nie jest unikalny: zegar Windowsa ma
  /// rozdzielczość gorszą niż mikrosekunda, więc dwie kopie w pętli testowej
  /// brały tę samą nazwę i druga nadpisywała pierwszą — retencja widziała wtedy
  /// trzy pliki zamiast pięciu. Znacznik jest podbijany w pamięci i sprawdzany
  /// na dysku, a sortowanie po ścieżce nadal porządkuje kopie od najnowszej.
  Future<File> _reserveName(Directory backups, bool automatic) async {
    final prefix = automatic ? 'auto' : 'pitstop';
    var stamp = DateTime.now().microsecondsSinceEpoch;
    if (stamp <= _lastStamp) stamp = _lastStamp + 1;
    _lastStamp = stamp;
    var file = File(p.join(backups.path, '$prefix-$stamp.zip'));
    while (await file.exists()) {
      stamp++;
      _lastStamp = stamp;
      file = File(p.join(backups.path, '$prefix-$stamp.zip'));
    }
    return file;
  }

  Future<BackupPreview> inspect(File file) async {
    if (await file.length() > 200 * 1024 * 1024) {
      throw const L10nException(AppError.backupTooLarge);
    }
    final archive =
        ZipDecoder().decodeBytes(await file.readAsBytes(), verify: true);
    final files = <String, List<int>>{};
    var total = 0;
    for (final item in archive) {
      if (!item.isFile ||
          item.isSymbolicLink ||
          files.containsKey(item.name) ||
          !(item.name == 'manifest.json' ||
              item.name == 'data.json' ||
              RegExp(r'^media/[0-9]+\.[a-z0-9]+$').hasMatch(item.name))) {
        throw const L10nException(AppError.archiveBroken);
      }
      total += item.size;
      if (total > 500 * 1024 * 1024) {
        throw const L10nException(AppError.unpackedTooLarge);
      }
      files[item.name] = List<int>.from(item.content as List<int>);
    }
    final manifest = jsonDecode(utf8.decode(files['manifest.json'] ?? []))
        as Map<String, dynamic>;
    if (manifest['format'] != 1 || manifest['schema'] != db.schemaVersion) {
      throw const L10nException(AppError.archiveVersion);
    }
    final hashes = Map<String, dynamic>.from(manifest['sha256'] as Map);
    if (hashes.length != files.length - 1) {
      throw const L10nException(AppError.archiveIncomplete);
    }
    for (final e in hashes.entries) {
      if (files[e.key] == null ||
          sha256.convert(files[e.key]!).toString() != e.value) {
        throw const L10nException(AppError.archiveCorrupted);
      }
    }
    final raw =
        jsonDecode(utf8.decode(files['data.json']!)) as Map<String, dynamic>;
    if (raw.length != names.length || !names.every(raw.containsKey)) {
      throw const L10nException(AppError.archiveDataset);
    }
    final tables = <String, List<Map<String, dynamic>>>{};
    for (final name in names) {
      final columns =
          (await db.customSelect('PRAGMA table_info("$name")').get())
              .map((r) => r.read<String>('name'))
              .toSet();
      tables[name] = (raw[name] as List)
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      for (final row in tables[name]!) {
        if (row.keys.toSet().difference(columns).isNotEmpty ||
            columns.difference(row.keys.toSet()).isNotEmpty) {
          throw const L10nException(AppError.archiveColumns);
        }
      }
    }
    for (final spec in [
      ('vehicles', 'photo_path'),
      ('attachments', 'file_path')
    ]) {
      for (final row in tables[spec.$1]!) {
        final path = row[spec.$2];
        if (path != null &&
            (!path.toString().startsWith('media/') || files[path] == null)) {
          throw const L10nException(AppError.missingBackupFile);
        }
      }
    }
    await _draftMedia(tables['app_settings']!, (path) async {
      if (!path.startsWith('media/') || !files.containsKey(path)) {
        throw const L10nException(AppError.missingDraftFile);
      }
      return path;
    });
    // Validate SQL types, NOT NULL, unique keys and foreign keys without retaining changes.
    try {
      await db.transaction(() async {
        await _replace(tables);
        final invalid = await db.customSelect('PRAGMA foreign_key_check').get();
        if (invalid.isNotEmpty) {
          throw const L10nException(AppError.archiveRelations);
        }
        throw const _ValidBackup();
      });
    } on _ValidBackup {/* the validation transaction was rolled back */}
    return BackupPreview(
        tables, files, DateTime.parse(manifest['created'] as String));
  }

  Future<void> _draftMedia(List<Map<String, dynamic>> settings,
      Future<String> Function(String) transform) async {
    for (final row
        in settings.where((r) => (r['key'] as String).startsWith('draft:'))) {
      final value = jsonDecode(row['value'] as String) as Map<String, dynamic>;
      final extra = value['_extra'] as Map<String, dynamic>?;
      if (extra == null) continue;
      if (extra['photo'] is String) {
        extra['photo'] = await transform(extra['photo'] as String);
      }
      for (final pending in extra['pending'] as List? ?? []) {
        if (pending['path'] is String) {
          pending['path'] = await transform(pending['path'] as String);
        }
      }
      row['value'] = jsonEncode(value);
    }
  }

  Future<void> _replace(Map<String, List<Map<String, dynamic>>> tables) async {
    for (final name in names.reversed) {
      await db.customStatement('DELETE FROM "$name"');
    }
    for (final name in names) {
      for (final row in tables[name]!) {
        await db.customStatement(
            'INSERT INTO "$name" (${row.keys.map((k) => '"$k"').join(',')}) VALUES (${List.filled(row.length, '?').join(',')})',
            row.values.toList());
      }
    }
  }

  Future<void> restore(BackupPreview preview) async {
    await create(); // recoverable snapshot before replacement
    final staging =
        Directory(p.join(directory.path, 'restored', const Uuid().v4()));
    await staging.create(recursive: true);
    var committed = false;
    try {
      final tables =
          jsonDecode(jsonEncode(preview.tables)) as Map<String, dynamic>;
      final typed = tables.map((k, v) => MapEntry(
          k,
          (v as List)
              .map((r) => Map<String, dynamic>.from(r as Map))
              .toList()));
      for (final e
          in preview.files.entries.where((e) => e.key.startsWith('media/'))) {
        await File(p.join(staging.path, p.basename(e.key)))
            .writeAsBytes(e.value, flush: true);
      }
      for (final spec in [
        ('vehicles', 'photo_path'),
        ('attachments', 'file_path')
      ]) {
        for (final row in typed[spec.$1]!) {
          if (row[spec.$2] != null) {
            row[spec.$2] =
                p.join(staging.path, p.basename(row[spec.$2] as String));
          }
        }
      }
      await _draftMedia(typed['app_settings']!,
          (path) async => p.join(staging.path, p.basename(path)));
      await db.transaction(() async {
        await _replace(typed);
      });
      db.markTablesUpdated(db.allTables.toSet());
      committed = true;
    } finally {
      if (!committed) await staging.delete(recursive: true);
    }
  }
}

class _ValidBackup implements Exception {
  const _ValidBackup();
}
