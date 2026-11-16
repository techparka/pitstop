import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../../core/l10n/app_errors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/garage_repository.dart';
import '../../domain/calculations.dart';

class CsvData {
  final List<String> headers;
  final List<List<String>> rows;
  const CsvData(this.headers, this.rows);
  static CsvData parse(String text) {
    text = text.replaceFirst('\uFEFF', '');
    final separator = text.split('\n').first.contains(';') ? ';' : ',';
    final rows = <List<String>>[];
    var row = <String>[], cell = StringBuffer(), quoted = false;
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == '"') {
        if (quoted && i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (c == separator && !quoted) {
        row.add(cell.toString());
        cell = StringBuffer();
      } else if ((c == '\n' || c == '\r') && !quoted) {
        if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
        row.add(cell.toString());
        if (row.any((s) => s.isNotEmpty)) rows.add(row);
        row = [];
        cell = StringBuffer();
      } else {
        cell.write(c);
      }
    }
    if (quoted) throw const L10nException(AppError.csvUnclosedQuote);
    row.add(cell.toString());
    if (row.any((s) => s.isNotEmpty)) rows.add(row);
    if (rows.isEmpty || rows.first.toSet().length != rows.first.length) {
      throw const L10nException(AppError.csvNoHeader);
    }
    return CsvData(rows.first, rows.skip(1).toList());
  }

  static String encode(List<List<String>> rows) =>
      '\uFEFF${rows.map((r) => r.map((s) => '"${s.replaceAll('"', '""')}"').join(';')).join('\r\n')}';
}

class ImportRow {
  final int line;
  final Map<String, String> data;

  /// Kod błędu zamiast zdania: walidacja nie zna języka interfejsu, a listę
  /// błędów w podglądzie tłumaczy interfejs przez `AppError.label`.
  final AppError? error;
  const ImportRow(this.line, this.data, this.error);
}

class CsvService {
  static const fields = [
    'kind',
    'title',
    'date',
    'mileage',
    'amount',
    'category',
    'quantity',
    'fuel',
    'fullTank',
    'missed',
    'place',
    'note'
  ];
  final AppDatabase db;
  CsvService(this.db);
  List<ImportRow> preview(CsvData csv, Map<String, String> mapping) {
    return csv.rows.asMap().entries.map((e) {
      final data = <String, String>{};
      for (final field in fields) {
        final index = csv.headers.indexOf(mapping[field] ?? field);
        data[field] =
            index < 0 || index >= e.value.length ? '' : e.value[index].trim();
      }
      AppError? error;
      final kind =
          data['kind']!.isEmpty ? 'SERVICE' : data['kind']!.toUpperCase();
      data['kind'] = kind;
      final date = DateTime.tryParse(data['date']!);
      final mileage = int.tryParse(data['mileage']!);
      final quantity = double.tryParse(data['quantity']!.replaceAll(',', '.'));
      if (!['SERVICE', 'FUEL', 'CHARGE', 'EXPENSE', 'MILEAGE'].contains(kind)) {
        error = AppError.csvKind;
      } else if (data['title']!.isEmpty) {
        error = AppError.csvTitle;
      } else if (date == null ||
          date.year < 1990 ||
          date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
        error = AppError.csvDate;
      } else if (data['amount']!.isNotEmpty &&
          Money.parse(data['amount']!) == null) {
        error = AppError.csvAmount;
      } else if (data['mileage']!.isNotEmpty &&
          (mileage == null || mileage < 0)) {
        error = AppError.csvMileage;
      } else if (['FUEL', 'CHARGE', 'MILEAGE'].contains(kind) &&
          mileage == null) {
        error = AppError.csvMileageRequired;
      } else if (['FUEL', 'CHARGE'].contains(kind) &&
          (quantity == null || !quantity.isFinite || quantity <= 0)) {
        error = AppError.csvQuantity;
      } else if (kind == 'FUEL' &&
          !['Benzyna', 'Diesel', 'LPG'].contains(data['fuel'])) {
        error = AppError.csvFuel;
      } else if (['fullTank', 'missed'].any((key) =>
          data[key]!.isNotEmpty && !['true', 'false'].contains(data[key]))) {
        error = AppError.csvBoolean;
      }
      return ImportRow(e.key + 2, data, error);
    }).toList();
  }

  Future<int> import(int vehicleId, List<ImportRow> rows) =>
      db.transaction(() async {
        var count = 0;
        final repo = GarageRepository(db);
        for (final row in rows.where((r) => r.error == null)) {
          final d = row.data;
          final fingerprint =
              'import:$vehicleId:${sha256.convert(utf8.encode(jsonEncode(fields.map((f) => d[f]).toList())))}';
          if (await repo.setting(fingerprint) != null) continue;
          final amount =
              d['amount']!.isEmpty ? null : Money.parse(d['amount']!);
          final mileage = int.tryParse(d['mileage']!);
          if (d['kind'] == 'SERVICE') {
            await db.into(db.serviceRecords).insert(
                ServiceRecordsCompanion.insert(
                    vehicleId: vehicleId,
                    title: d['title']!,
                    serviceDate: DateTime.parse(d['date']!),
                    costCents: Value(amount),
                    cost: Value(amount == null ? null : amount / 100),
                    mileage: Value(mileage),
                    serviceType: Value(
                        d['category']!.isEmpty ? 'OTHER' : d['category']!),
                    description: Value(d['note']),
                    workshop: Value(d['place'])));
          } else {
            await db.into(db.ledgerEntries).insert(
                LedgerEntriesCompanion.insert(
                    vehicleId: vehicleId,
                    kind: d['kind']!,
                    title: d['title']!,
                    category: d['category']!.isEmpty ? 'Inne' : d['category']!,
                    date: DateTime.parse(d['date']!),
                    mileage: Value(mileage),
                    amountCents: Value(amount),
                    quantity: Value(
                        double.tryParse(d['quantity']!.replaceAll(',', '.'))),
                    fuel: Value(d['fuel']),
                    fullTank: Value(d['fullTank'] != 'false'),
                    missed: Value(d['missed'] == 'true'),
                    place: Value(d['place']),
                    note: Value(d['note']),
                    importKey: Value(fingerprint)));
          }
          if (mileage != null) await repo.mileage(vehicleId, mileage);
          await repo.setSetting(fingerprint, '1');
          count++;
        }
        return count;
      });
  Future<String> export(int vehicleId) async {
    final rows = <List<String>>[fields];
    final ledger = {
      for (final e in await (db.select(db.ledgerEntries)
            ..where((e) => e.vehicleId.equals(vehicleId)))
          .get())
        e.id: e
    };
    for (final e in await GarageRepository(db).timeline(vehicleId)) {
      final row = e.kind == 'SERVICE' ? null : ledger[e.id];
      final map = <String, String>{
        'kind': e.kind,
        'title': e.title,
        'date': e.date.toIso8601String(),
        'mileage': e.mileage?.toString() ?? '',
        'amount': e.cents == null ? '' : Money.input(e.cents!),
        'category': e.category,
        'quantity': row?.quantity?.toString() ?? '',
        'fuel': row?.fuel ?? '',
        'fullTank': row?.fullTank.toString() ?? '',
        'missed': row?.missed.toString() ?? '',
        'place': e.place,
        'note': e.note
      };
      rows.add(fields.map((f) => map[f] ?? '').toList());
    }
    return CsvData.encode(rows);
  }
}
