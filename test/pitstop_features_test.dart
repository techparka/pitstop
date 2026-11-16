import 'dart:convert';
import 'dart:ui' show Locale;
import 'dart:ffi';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:car_service/core/services/backup_service.dart';
import 'package:car_service/core/services/csv_service.dart';
import 'package:car_service/core/services/device_services.dart';
import 'package:car_service/data/database/app_database.dart';
import 'package:car_service/data/repositories/garage_repository.dart';
import 'package:car_service/data/repositories/service_repository.dart';
import 'package:car_service/domain/calculations.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:car_service/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    open.overrideFor(
        OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
  }
  late AppDatabase db;
  final pl = lookupAppLocalizations(const Locale('pl'));
  late GarageRepository repo;
  late Directory dir;
  late int vehicle;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = GarageRepository(db);
    dir = await Directory.systemTemp.createTemp('pitstop-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => dir.path);
    vehicle = await db.into(db.vehicles).insert(VehiclesCompanion.insert(
        name: 'Test',
        make: 'Toyota',
        model: 'Corolla',
        year: 2020,
        currentMileage: const Value(100000)));
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });
  group('money and calendar', () {
    test('Polish decimals are parsed exactly to cents', () {
      expect(Money.parse('1 234,56'), 123456);
      expect(Money.parse('0,01'), 1);
      expect(Money.parse('12.5'), 1250);
      expect(Money.parse('0'), 0);
    });
    test('invalid, negative, infinite and overprecise money rejected', () {
      for (final value in ['-1', 'NaN', 'Infinity', '1,234', '1.2.3', '']) {
        expect(Money.parse(value), isNull, reason: value);
      }
    });
    test('month recurrence clamps to end of month and crosses years', () {
      expect(
          addCalendarMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
      expect(
          addCalendarMonths(DateTime(2025, 1, 31), 1), DateTime(2025, 2, 28));
      expect(
          addCalendarMonths(DateTime(2025, 12, 31), 2), DateTime(2026, 2, 28));
    });
  });
  group('fuel calculations', () {
    test('full tanks exclude the first tank and sum partial fills', () {
      final result = consumption([
        const FillUp(1000, 40),
        const FillUp(1200, 10, full: false),
        const FillUp(1500, 25)
      ]).single;
      expect(result.distance, 500);
      expect(result.liters, 35);
      expect(result.per100, closeTo(7, 0.000001));
    });
    test('missed tank interrupts calculation until a new full anchor', () {
      final result = consumption([
        const FillUp(1000, 40),
        const FillUp(1200, 20, missed: true),
        const FillUp(1600, 28)
      ]).single;
      expect(result.distance, 400);
      expect(result.per100, closeTo(7, 0.000001));
    });
    test('partial start and insufficient data do not invent consumption', () {
      expect(
          consumption(
              [const FillUp(1000, 10, full: false), const FillUp(1100, 40)]),
          isEmpty);
      expect(
          consumption(
              [const FillUp(1000, 40), const FillUp(1200, 12, full: false)]),
          isEmpty);
    });
    test('LPG and petrol remain independent', () {
      final result = consumption([
        const FillUp(1000, 40),
        const FillUp(1000, 40, fuel: 'LPG'),
        const FillUp(1500, 5),
        const FillUp(1500, 45, fuel: 'LPG')
      ]);
      expect(result.map((r) => r.per100), [1, 9]);
    });
    test('equal mileage never divides by zero', () {
      expect(consumption([const FillUp(1000, 40), const FillUp(1000, 20)]),
          isEmpty);
    });
  });
  group('repository transactions', () {
    test('ledger saves cents and only raises current mileage', () async {
      await repo.saveLedger(LedgerEntriesCompanion.insert(
          vehicleId: vehicle,
          kind: 'EXPENSE',
          title: 'Parking',
          category: 'Parking',
          date: DateTime(2026),
          amountCents: const Value(1234),
          mileage: const Value(110000)));
      await repo.saveLedger(LedgerEntriesCompanion.insert(
          vehicleId: vehicle,
          kind: 'MILEAGE',
          title: 'Old',
          category: 'Przebieg',
          date: DateTime(2025),
          mileage: const Value(90000)));
      expect((await db.select(db.vehicles).getSingle()).currentMileage, 110000);
      expect(
          (await repo.timeline(vehicle))
              .fold<int>(0, (sum, e) => sum + (e.cents ?? 0)),
          1234);
    });
    test('service items do not double-count service total', () async {
      await ServiceRepository(db).save(
          ServiceRecordsCompanion.insert(
              vehicleId: vehicle,
              title: 'Serwis',
              serviceDate: DateTime(2026),
              cost: const Value(450.5)),
          items: [
            (name: 'Olej', kind: 'Część', cents: 30000),
            (name: 'Praca', kind: 'Robocizna', cents: 15050)
          ]);
      expect((await repo.timeline(vehicle)).single.cents, 45050);
      expect((await db.select(db.serviceItems).get()).length, 2);
    });
    test('attachment failure leaves no service or mileage update', () async {
      await expectLater(
          ServiceRepository(db).save(
              ServiceRecordsCompanion.insert(
                  vehicleId: vehicle,
                  title: 'Serwis',
                  serviceDate: DateTime(2026),
                  mileage: const Value(120000)),
              attachments: [
                (
                  path: '${dir.path}/missing.pdf',
                  name: 'missing.pdf',
                  type: 'PDF'
                )
              ]),
          throwsA(anything));
      expect(await db.select(db.serviceRecords).get(), isEmpty);
      expect((await db.select(db.vehicles).getSingle()).currentMileage, 100000);
    });
    test('deleting one service keeps a PDF referenced by another service',
        () async {
      final file = File('${dir.path}/shared.pdf');
      await file.writeAsString('shared');
      final svc = ServiceRepository(db);
      final first = await svc.save(ServiceRecordsCompanion.insert(
          vehicleId: vehicle, title: 'A', serviceDate: DateTime(2026)));
      final second = await svc.save(ServiceRecordsCompanion.insert(
          vehicleId: vehicle, title: 'B', serviceDate: DateTime(2026)));
      for (final id in [first, second]) {
        await svc.insertAttachment(AttachmentsCompanion.insert(
            serviceRecordId: id,
            filePath: file.path,
            fileType: 'PDF',
            fileName: 'shared.pdf'));
      }
      await svc.deleteWithFiles(first);
      expect(await file.exists(), true);
      await svc.deleteWithFiles(second);
      expect(await file.exists(), false);
    });
    test('database attachment failure rolls back copied file and entire save',
        () async {
      final file = File('${dir.path}/invoice.pdf');
      await file.writeAsString('pdf-bytes');
      await db.customStatement(
          "CREATE TRIGGER reject_attachment BEFORE INSERT ON attachments BEGIN SELECT RAISE(ABORT,'test'); END");
      await expectLater(
          ServiceRepository(db).save(
              ServiceRecordsCompanion.insert(
                  vehicleId: vehicle,
                  title: 'Serwis',
                  serviceDate: DateTime(2026),
                  mileage: const Value(120000)),
              attachments: [
                (path: file.path, name: 'invoice.pdf', type: 'PDF')
              ]),
          throwsA(anything));
      expect(await db.select(db.serviceRecords).get(), isEmpty);
      expect((await db.select(db.vehicles).getSingle()).currentMileage, 100000);
      final copies = Directory('${dir.path}/car_service/files');
      if (await copies.exists()) expect(await copies.list().toList(), isEmpty);
    });
    test(
        'recurrence and optional service are created once on double completion',
        () async {
      final id = await db.into(db.reminders).insert(RemindersCompanion.insert(
          vehicleId: vehicle,
          title: 'Olej',
          dueDate: Value(DateTime(2026, 1, 31)),
          dueMileage: const Value(100000),
          intervalMonths: const Value(12),
          intervalKm: const Value(15000)));
      final reminder = await (db.select(db.reminders)
            ..where((r) => r.id.equals(id)))
          .getSingle();
      await repo.complete(reminder, createService: true);
      await repo.complete(reminder, createService: true);
      final reminders = await db.select(db.reminders).get();
      expect(reminders.length, 2);
      expect(reminders.where((r) => !r.isDone).single.dueMileage, 115000);
      expect((await db.select(db.serviceRecords).get()).length, 1);
    });
    test('probable duplicate checks kind, day, amount and excludes itself',
        () async {
      final id = await ServiceRepository(db).save(
          ServiceRecordsCompanion.insert(
              vehicleId: vehicle,
              title: 'Olej',
              serviceDate: DateTime(2026, 1, 1, 10),
              cost: const Value(100)));
      expect(
          await repo.duplicate(vehicle, ' olej ', DateTime(2026, 1, 1), 10000),
          true);
      expect(
          await repo.duplicate(vehicle, 'Olej', DateTime(2026, 1, 1), 10000,
              excludeId: id),
          false);
      expect(await repo.duplicate(vehicle, 'Olej', DateTime(2026, 1, 2), 10000),
          false);
    });
  });
  group('complete backup', () {
    Future<File> populated() async {
      final photo = File('${dir.path}/car.jpg');
      await photo.writeAsBytes([1, 2, 3, 4]);
      await (db.update(db.vehicles)..where((v) => v.id.equals(vehicle))).write(
          VehiclesCompanion(
              photoPath: Value(photo.path),
              vin: const Value('WVWZZZ1JZXW000001')));
      final id = await ServiceRepository(db).save(
          ServiceRecordsCompanion.insert(
              vehicleId: vehicle,
              title: 'Olej',
              serviceDate: DateTime(2026),
              cost: const Value(100)));
      final pdf = File('${dir.path}/invoice.pdf');
      await pdf.writeAsString('test-pdf');
      await db.into(db.attachments).insert(AttachmentsCompanion.insert(
          serviceRecordId: id,
          filePath: pdf.path,
          fileType: 'PDF',
          fileName: 'invoice.pdf'));
      await repo.setSetting('theme', 'dark');
      return BackupService(db, dir).create();
    }

    test('inspect does not change live data; restore includes all media',
        () async {
      final file = await populated();
      final service = BackupService(db, dir);
      final preview = await service.inspect(file);
      expect(preview.vehicles, 1);
      expect((await db.select(db.vehicles).getSingle()).name, 'Test');
      await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          name: 'Extra', make: 'X', model: 'Y', year: 2020));
      await service.restore(preview);
      expect((await db.select(db.vehicles).get()).length, 1);
      final car = await db.select(db.vehicles).getSingle();
      expect(await File(car.photoPath!).readAsBytes(), [1, 2, 3, 4]);
      final att = await db.select(db.attachments).getSingle();
      expect(await File(att.filePath).readAsString(), 'test-pdf');
      expect(await repo.setting('theme'), 'dark');
      expect((await service.backups.list().toList()).length,
          greaterThanOrEqualTo(2));
    });
    test('draft photos and pending files survive a full backup restore',
        () async {
      final file = File('${dir.path}/draft.jpg');
      await file.writeAsBytes([6, 7, 8]);
      await repo.setSetting(
          'draft:service:1:null',
          jsonEncode({
            'title': 'Draft',
            '_extra': {
              'pending': [
                {'path': file.path, 'name': 'draft.jpg', 'type': 'IMAGE'}
              ]
            }
          }));
      final service = BackupService(db, dir);
      final backup = await service.create();
      final preview = await service.inspect(backup);
      await service.restore(preview);
      final draft = jsonDecode((await repo.setting('draft:service:1:null'))!);
      final path = draft['_extra']['pending'][0]['path'] as String;
      expect(path, isNot(file.path));
      expect(await File(path).readAsBytes(), [6, 7, 8]);
    });
    test('checksum corruption is rejected without changing the database',
        () async {
      final original = await populated();
      final archive = ZipDecoder().decodeBytes(await original.readAsBytes());
      final corrupt = Archive();
      for (final entry in archive) {
        final bytes = entry.name == 'data.json'
            ? utf8.encode('{}')
            : entry.content as List<int>;
        corrupt.addFile(ArchiveFile(entry.name, bytes.length, bytes));
      }
      final file = File('${dir.path}/bad.zip');
      await file.writeAsBytes(ZipEncoder().encode(corrupt)!);
      await expectLater(
          BackupService(db, dir).inspect(file), throwsA(anything));
      expect((await db.select(db.vehicles).getSingle()).name, 'Test');
      expect((await db.select(db.attachments).get()).length, 1);
    });
    test('valid checksums with broken foreign keys still reject and roll back',
        () async {
      final original = await populated();
      final archive = ZipDecoder().decodeBytes(await original.readAsBytes());
      final files = {
        for (final f in archive) f.name: List<int>.from(f.content as List<int>)
      };
      final data = jsonDecode(utf8.decode(files['data.json']!));
      data['attachments'][0]['service_record_id'] = 999999;
      files['data.json'] = utf8.encode(jsonEncode(data));
      final manifest = jsonDecode(utf8.decode(files['manifest.json']!));
      manifest['sha256']['data.json'] =
          sha256.convert(files['data.json']!).toString();
      files['manifest.json'] = utf8.encode(jsonEncode(manifest));
      final corrupt = Archive();
      for (final e in files.entries) {
        corrupt.addFile(ArchiveFile(e.key, e.value.length, e.value));
      }
      final file = File('${dir.path}/bad-relations.zip');
      await file.writeAsBytes(ZipEncoder().encode(corrupt)!);
      await expectLater(
          BackupService(db, dir).inspect(file), throwsA(anything));
      expect((await db.select(db.attachments).getSingle()).serviceRecordId,
          isNot(999999));
    });
    test('archive path traversal is rejected', () async {
      final a = Archive()..addFile(ArchiveFile('../outside', 1, [0]));
      final f = File('${dir.path}/unsafe.zip');
      await f.writeAsBytes(ZipEncoder().encode(a)!);
      await expectLater(BackupService(db, dir).inspect(f), throwsA(anything));
    });
    test('only five automatic backups are retained', () async {
      final service = BackupService(db, dir);
      for (var i = 0; i < 7; i++) {
        await service.create(automatic: true);
      }
      expect((await service.backups.list().toList()).length, 5);
    });
  });
  group('notification schedule', () {
    test('date reminders schedule 7 days, 1 day and due date', () async {
      final car = await db.select(db.vehicles).getSingle();
      final reminder = Reminder(
          id: 1,
          vehicleId: vehicle,
          title: 'OC',
          isDone: false,
          serviceType: 'OTHER',
          createdAt: DateTime(2026),
          dueDate: DateTime(2026, 11, 10));
      final alarms = DeviceServices.scheduleFor([reminder], [car], pl,
          now: DateTime(2026, 11, 1));
      expect(alarms.length, 3);
      expect(
          alarms.map(
              (a) => DateTime.fromMillisecondsSinceEpoch(a['at'] as int).day),
          [3, 9, 10]);
      expect(alarms.first['route'], '/reminder/1/edit?vehicleId=$vehicle');
    });
    test('mileage uses latest reading and completed reminders are excluded',
        () async {
      final car = await db.select(db.vehicles).getSingle();
      final reminder = Reminder(
          id: 2,
          vehicleId: vehicle,
          title: 'Olej',
          isDone: false,
          serviceType: 'OTHER',
          createdAt: DateTime(2026),
          dueMileage: 100500);
      expect(DeviceServices.scheduleFor([reminder], [car], pl).single['at'], 0);
      expect(
          DeviceServices.scheduleFor([reminder.copyWith(isDone: true)], [car], pl),
          isEmpty);
      expect(
          DeviceServices.scheduleFor(
              [reminder.copyWith(dueMileage: const Value(105000))], [car], pl),
          isEmpty);
    });
  });
  group('CSV', () {
    test('quoted separator, newlines, quotes and Polish text roundtrip', () {
      final rows = [
        ['title', 'note'],
        ['Ładowanie; test', 'Linia 1\n"Faktura"']
      ];
      final csv = CsvData.parse(CsvData.encode(rows));
      expect(csv.headers, rows.first);
      expect(csv.rows.single, rows.last);
    });
    test('preview isolates errors and import is idempotent', () async {
      final csv = CsvData.parse(
          'title;date;amount;mileage\nOlej;2026-01-01;450,50;120000\nBad;wrong;-1;20\nParking;2026-01-02;0;');
      final service = CsvService(db);
      final rows = service.preview(csv, {});
      expect(rows.where((r) => r.error != null).length, 1);
      expect(await service.import(vehicle, rows), 2);
      expect(await service.import(vehicle, rows), 0);
      expect(
          (await repo.timeline(vehicle))
              .fold<int>(0, (a, e) => a + (e.cents ?? 0)),
          45050);
    });
    test('mapped external headers import fuel quantity and flags', () async {
      final csv = CsvData.parse(
          'typ,nazwa,data,litry,licznik,paliwo\nFUEL,Bak,2026-01-01,45,120000,Diesel');
      final service = CsvService(db);
      final rows = service.preview(csv, {
        'kind': 'typ',
        'title': 'nazwa',
        'date': 'data',
        'quantity': 'litry',
        'mileage': 'licznik',
        'fuel': 'paliwo'
      });
      expect(rows.single.error, isNull);
      await service.import(vehicle, rows);
      final fuel = await db.select(db.ledgerEntries).getSingle();
      expect(fuel.quantity, 45);
      expect(fuel.fuel, 'Diesel');
    });
    test('failed row insert rolls back the entire import and fingerprints',
        () async {
      final csv = CsvData.parse(
          'title;date;amount\nFirst;2026-01-01;10\nSecond;2026-01-02;20');
      await db.customStatement(
          "CREATE TRIGGER reject_second BEFORE INSERT ON service_records WHEN NEW.title='Second' BEGIN SELECT RAISE(ABORT,'test'); END");
      await expectLater(
          CsvService(db).import(vehicle, CsvService(db).preview(csv, {})),
          throwsA(anything));
      expect(await db.select(db.serviceRecords).get(), isEmpty);
      expect(await db.select(db.appSettings).get(), isEmpty);
    });
    test('10,000 history records are queried within a practical bound',
        () async {
      await db.batch((b) {
        b.insertAll(
            db.ledgerEntries,
            List.generate(
                10000,
                (i) => LedgerEntriesCompanion.insert(
                    vehicleId: vehicle,
                    kind: 'EXPENSE',
                    title: 'Wpis $i',
                    category: 'Inne',
                    date: DateTime(2026).add(Duration(minutes: i)),
                    amountCents: Value(i))));
      });
      final timer = Stopwatch()..start();
      final rows = await repo.timeline(vehicle);
      timer.stop();
      expect(rows.length, 10000);
      expect(timer.elapsed.inSeconds, lessThan(5));
    });
  });
}
