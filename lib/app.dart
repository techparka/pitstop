import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'core/services/backup_service.dart';
import 'core/services/device_services.dart';
import 'features/garage/garage_providers.dart';
import 'features/garage/garage_shell.dart';
import 'features/garage/entry_screen.dart';
import 'features/garage/analytics_screen.dart';
import 'features/garage/settings_screen.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/app_errors.dart';
import 'core/l10n/app_formats.dart';
import 'core/l10n/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/reminders/screens/add_reminder_screen.dart';
import 'features/services/screens/add_service_screen.dart';
import 'features/services/screens/service_detail_screen.dart';
import 'features/vehicles/screens/add_car_screen.dart';
import 'features/vehicles/screens/car_profile_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(
        path: '/vehicle/:id/import',
        builder: (_, state) =>
            CsvImportScreen(vehicleId: int.parse(state.pathParameters['id']!))),
    GoRoute(
        path: '/vehicle/:id/analytics',
        builder: (_, state) =>
            AnalyticsScreen(vehicleId: int.parse(state.pathParameters['id']!))),
    GoRoute(
        path: '/vehicle/:id/entry/:kind',
        builder: (_, state) => EntryScreen(
            vehicleId: int.parse(state.pathParameters['id']!),
            kind: state.pathParameters['kind']!,
            id: int.tryParse(state.uri.queryParameters['id'] ?? ''))),
    GoRoute(
      path: '/',
      builder: (_, __) => const GarageShell(),
    ),
    GoRoute(
      path: '/vehicle/add',
      builder: (_, __) => const AddCarScreen(),
    ),
    GoRoute(
      path: '/vehicle/:id',
      builder: (_, state) =>
          CarProfileScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/vehicle/:id/edit',
      builder: (_, state) =>
          AddCarScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/vehicle/:vehicleId/service/add',
      builder: (_, state) => AddServiceScreen(
          vehicleId: int.parse(state.pathParameters['vehicleId']!)),
    ),
    GoRoute(
      path: '/service/:id',
      builder: (_, state) => ServiceDetailScreen(
          serviceId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/service/:id/edit',
      builder: (_, state) {
        final serviceId = int.parse(state.pathParameters['id']!);
        final vehicleId = int.parse(state.uri.queryParameters['vehicleId']!);
        return AddServiceScreen(vehicleId: vehicleId, serviceId: serviceId);
      },
    ),
    GoRoute(
      path: '/vehicle/:vehicleId/reminder/add',
      builder: (_, state) => AddReminderScreen(
          vehicleId: int.parse(state.pathParameters['vehicleId']!)),
    ),
    GoRoute(
      path: '/reminder/:id/edit',
      builder: (_, state) {
        final reminderId = int.parse(state.pathParameters['id']!);
        final vehicleId = int.parse(state.uri.queryParameters['vehicleId']!);
        return AddReminderScreen(vehicleId: vehicleId, reminderId: reminderId);
      },
    ),
    GoRoute(
      path: '/vehicle/:id/stats',
      builder: (_, state) =>
          AnalyticsScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

class CarServiceApp extends ConsumerStatefulWidget {
  const CarServiceApp({super.key});

  @override
  ConsumerState<CarServiceApp> createState() => _CarServiceAppState();
}

class _CarServiceAppState extends ConsumerState<CarServiceApp>
    with WidgetsBindingObserver {
  StreamSubscription<int>? subscription;
  Timer? timer;
  bool working = false;
  bool pending = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final repo = ref.read(garageRepositoryProvider);
    subscription = repo.changes().listen((_) => queue(),
        onError: (Object e, StackTrace st) {
      if (mounted) {
        ref.read(backupErrorProvider.notifier).state = AppError.databaseOpen;
      }
    });
    repo.setting('theme').then((theme) {
      if (mounted) {
        ref.read(appThemeModeProvider.notifier).state = ThemeMode.values
            .firstWhere((m) => m.name == theme, orElse: () => ThemeMode.system);
      }
    });
    readDisplaySettings(repo.db).then((settings) {
      if (mounted) applyDisplaySettings(ref, settings);
    });
    // Zmiana języka zmienia treść zaplanowanych powiadomień Androida.
    ref.listen(appLanguageProvider, (_, __) => queue());
    DeviceServices.channel.setMethodCallHandler((call) async {
      if (call.method == 'openRoute') openRoute(call.arguments as String?);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final route =
            await DeviceServices.channel.invokeMethod<String>('initialRoute');
        if (mounted) openRoute(route);
      } catch (_) {/* no Android bridge on other platforms */}
    });
  }

  void openRoute(String? route) {
    if (route != null &&
        (route == '/settings' ||
            RegExp(r'^/reminder/\d+/edit\?vehicleId=\d+$').hasMatch(route))) {
      _router.push(route);
    }
  }

  void queue() {
    pending = true;
    timer?.cancel();
    timer = Timer(const Duration(seconds: 3), maintain);
  }

  Future<void> maintain() async {
    if (working || !mounted) return;
    working = true;
    pending = false;
    final repo = ref.read(garageRepositoryProvider), db = repo.db;
    try {
      await DeviceServices.sync(
          await db.select(db.reminders).get(),
          await db.select(db.vehicles).get(),
          lookupAppLocalizations(
              resolveAppLocale(ref.read(appLanguageProvider))));
    } catch (_) {/* date and mileage reminders remain visible in the app */}
    try {
      await BackupService(db, await getApplicationDocumentsDirectory())
          .create(automatic: true);
      if (mounted) ref.read(backupErrorProvider.notifier).state = null;
    } catch (_) {
      if (mounted) {
        ref.read(backupErrorProvider.notifier).state =
            AppError.automaticBackupFailed;
      }
    }
    working = false;
    if (pending && mounted) queue();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) queue();
  }

  @override
  void dispose() {
    timer?.cancel();
    subscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PitStop',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(appThemeModeProvider),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(appLanguageProvider).locale,
      builder: (_, child) => _AppScope(child: child!),
    );
  }
}

/// Udostępnia formaty kwot, dat i liczeń oraz ustawia domyślne locale `intl`.
///
/// `MaterialApp` woła `builder` przed zbudowaniem tras, więc `Intl.defaultLocale`
/// jest gotowe, zanim którykolwiek ekran sformatuje liczbę lub datę.
class _AppScope extends ConsumerWidget {
  const _AppScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('pl', 'PL');
    Intl.defaultLocale = locale.languageCode == 'pl' ? 'pl_PL' : 'en_GB';
    final currency = ref.watch(displayCurrencyProvider);
    return AppFormats(
        locale: locale,
        currency: currency.currency,
        rate: currency.safeRate,
        child: child);
  }
}
