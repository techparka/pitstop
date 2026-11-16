import 'dart:ffi';
import 'dart:io';
import 'package:car_service/data/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isWindows) {
    open.overrideFor(
        OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
  }
  for (final version in [1, 2]) {
    test(
        'migrates schema v$version preserving vehicles, costs, files and reminders',
        () async {
      var schema = await File('test/fixtures/schema_v2.sql').readAsString();
      if (version == 1) {
        schema = schema
            .split(';\n')
            .where((s) => !s.startsWith('CREATE TABLE "reminders"'))
            .join(';\n');
      }
      final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
        raw.execute(schema);
        raw.execute('PRAGMA user_version = $version');
        raw.execute(
            "INSERT INTO vehicles(id,name,make,model,year,current_mileage) VALUES (1,'Existing','Audi','A5',2020,211000)");
        raw.execute(
            "INSERT INTO service_records(id,vehicle_id,title,service_date,mileage,cost,service_type) VALUES (1,1,'Olej',1700000000,211000,450.29,'OIL_CHANGE'),(2,1,'Bez kosztu',1700000000,210000,NULL,'OTHER')");
        raw.execute(
            "INSERT INTO attachments(id,service_record_id,file_path,file_type,file_name) VALUES (1,1,'/original/invoice.pdf','PDF','invoice.pdf')");
        if (version == 2) {
          raw.execute(
              "INSERT INTO reminders(id,vehicle_id,title,due_date) VALUES (1,1,'OC',1800000000)");
        }
      }));
      try {
        final vehicle = await db.select(db.vehicles).getSingle();
        expect(vehicle.name, 'Existing');
        expect(vehicle.currentMileage, 211000);
        expect(vehicle.powertrain, 'Benzyna');
        final services = await db.select(db.serviceRecords).get();
        expect(services.length, 2);
        expect(services.first.costCents, 45029);
        expect(services.last.costCents, null);
        expect((await db.select(db.attachments).getSingle()).filePath,
            '/original/invoice.pdf');
        expect(
            (await db.select(db.reminders).get()).length, version == 1 ? 0 : 1);
        expect(await db.select(db.ledgerEntries).get(), isEmpty);
        expect(
            (await db.customSelect('PRAGMA foreign_key_check').get()), isEmpty);
      } finally {
        await db.close();
      }
    });
  }
}
