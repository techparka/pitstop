import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:car_service/core/l10n/app_currency.dart';
import 'package:car_service/core/l10n/app_formats.dart';
import 'package:car_service/data/database/app_database.dart';
import 'package:car_service/features/services/providers/service_providers.dart';
import 'package:car_service/features/services/screens/service_detail_screen.dart';
import 'package:car_service/features/vehicles/providers/vehicle_providers.dart';
import 'package:car_service/l10n/generated/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pl_PL'));
  if (Platform.isWindows) {
    open.overrideFor(
        OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
  }

  testWidgets('new and existing JPG invoices open in the zoomable preview',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    // Sieć awaryjna: gdy test rzuci wyjątkiem, baza ma być domknięta bez
    // czekania, bo czekanie w teardown'ie znaczyłoby zawieszony test.
    addTearDown(() => unawaited(db.close()));
    final date = DateTime(2026);
    final service = ServiceRecord(
      id: 1,
      vehicleId: 1,
      title: 'Wymiana oleju',
      serviceDate: date,
      serviceType: 'OIL_CHANGE',
      createdAt: date,
    );
    final invoices = [
      Attachment(
        id: 1,
        serviceRecordId: 1,
        fileType: 'PDF',
        fileName: 'Starsza faktura.JPG',
        filePath: 'test/fixtures/invoice.jpg',
        createdAt: date,
      ),
      Attachment(
        id: 2,
        serviceRecordId: 1,
        fileType: 'INVOICE_IMAGE',
        fileName: 'Nowa faktura.jpg',
        filePath: 'test/fixtures/invoice.jpg',
        createdAt: date,
      ),
    ];

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        serviceRecordProvider(1).overrideWith((ref) => Stream.value(service)),
        attachmentsProvider(1).overrideWith((ref) => Stream.value(invoices)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pl'),
        home: AppFormats(
            locale: Locale('pl'),
            currency: AppCurrency.pln,
            rate: 1,
            child: ServiceDetailScreen(serviceId: 1)),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Faktury'), findsOneWidget);
    for (final invoice in invoices) {
      await tester.tap(find.text(invoice.fileName));
      await tester.pumpAndSettle();

      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text(invoice.fileName), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      await tester.runAsync(() async {
        final bytes = await (image.image as FileImage).file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        try {
          final frame = await codec.getNextFrame();
          expect(frame.image.width, 8);
          frame.image.dispose();
        } finally {
          codec.dispose();
        }
      });
      expect((image.image as FileImage).file.path, invoice.filePath);
      expect(tester.takeException(), isNull);

      // pageBack() szuka angielskiego tooltipa „Back”, a ten test działa po polsku
      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle();
    }

    // Bazę zamykam w ciele testu, nie w teardown'ie. `close()` czeka na
    // strumienie drifta, te rozłączają się dopiero przy dezintegracji drzewa,
    // a drift dosztukowuje do tego własne timery czyszczące cache - po
    // zakończonym teście nie ma już czego pompować, więc close() czekałby
    // w nieskończoność.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db.close();
  });
}
