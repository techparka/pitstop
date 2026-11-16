import 'package:car_service/core/theme/app_theme.dart';
import 'package:car_service/data/database/app_database.dart';
import 'package:car_service/core/l10n/app_currency.dart';
import 'package:car_service/core/l10n/app_formats.dart';
import 'package:car_service/data/repositories/garage_repository.dart';
import 'package:car_service/features/garage/garage_providers.dart';
import 'package:car_service/features/garage/garage_shell.dart';
import 'package:car_service/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pl_PL'));
  final car = Vehicle(
      id: 1,
      name: 'Audi A5 F5',
      make: 'Audi',
      model: 'A5',
      year: 2020,
      currentMileage: 220000,
      createdAt: DateTime(2026),
      powertrain: 'Benzyna');
  final populated = GarageSnapshot(
      [car],
      car,
      [
        TimelineEntry(
            id: 1,
            vehicleId: 1,
            kind: 'SERVICE',
            title: 'Wymiana oleju',
            category: 'OIL_CHANGE',
            date: DateTime(2026),
            cents: 45050,
            mileage: 220000)
      ],
      [
        Reminder(
            id: 1,
            vehicleId: 1,
            title: 'Badanie techniczne',
            dueMileage: 221000,
            isDone: false,
            serviceType: 'INSPECTION',
            createdAt: DateTime(2026))
      ],
      []);
  Future<void> mount(WidgetTester tester, GarageSnapshot snapshot,
      {bool dark = false,
      double scale = 1,
      Locale locale = const Locale('pl')}) async {
    await tester.pumpWidget(ProviderScope(
        overrides: [
          garageSnapshotProvider(null).overrideWith((ref) => snapshot)
        ],
        child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                // tak jak w aplikacji: kwoty i daty idą przez AppFormats
                child: AppFormats(
                    locale: locale,
                    currency: AppCurrency.pln,
                    rate: 1,
                    child: child!)),
            home: const GarageShell())));
    await tester.pumpAndSettle();
  }

  testWidgets('main navigation works in Polish and English', (tester) async {
    for (final entry in {
      const Locale('pl'): ['Historia', 'Terminy', 'Garaż', 'Pulpit'],
      const Locale('en'): ['History', 'Due dates', 'Garage', 'Dashboard'],
    }.entries) {
      await mount(tester, populated, locale: entry.key);
      for (final label in entry.value) {
        expect(find.text(label), findsWidgets);
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
      }
    }
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.6]) {
      testWidgets(
          'all main tabs fit ${dark ? 'dark' : 'light'} at text scale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await mount(tester, populated, dark: dark, scale: scale);
        expect(find.text('Audi A5 F5'), findsWidgets);
        expect(tester.takeException(), isNull);
        for (final label in ['Historia', 'Terminy', 'Garaż', 'Pulpit']) {
          await tester.tap(find.text(label).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: label);
        }
      });
    }
  }
  testWidgets('empty garage gives add and restore entry points',
      (tester) async {
    await mount(tester, const GarageSnapshot([], null, [], [], []));
    expect(find.text('Dodaj pierwsze auto'), findsOneWidget);
    expect(find.text('Mam kopię danych'), findsOneWidget);
  });
  testWidgets('history filters categories and searches title and workshop',
      (tester) async {
    await mount(tester, populated);
    await tester.tap(find.text('Historia').last);
    await tester.pumpAndSettle();
    expect(find.text('Wymiana oleju'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'nieistniejący');
    await tester.pumpAndSettle();
    expect(find.text('Brak pasujących wpisów'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'oleju');
    await tester.pumpAndSettle();
    expect(find.text('Wymiana oleju'), findsOneWidget);
  });
  testWidgets('long history is built lazily', (tester) async {
    final entries = List.generate(
        10000,
        (i) => TimelineEntry(
            id: i,
            vehicleId: 1,
            kind: 'SERVICE',
            title: 'Serwis $i',
            category: 'OTHER',
            date: DateTime(2026)));
    await mount(tester, GarageSnapshot([car], car, entries, [], []));
    await tester.tap(find.text('Historia').last);
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, lessThan(50));
    expect(tester.takeException(), isNull);
  });
}
