import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/reminders/screens/add_reminder_screen.dart';
import 'features/services/screens/add_service_screen.dart';
import 'features/services/screens/service_detail_screen.dart';
import 'features/stats/screens/stats_screen.dart';
import 'features/vehicles/screens/add_car_screen.dart';
import 'features/vehicles/screens/car_profile_screen.dart';
import 'features/vehicles/screens/home_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
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
      builder: (_, state) => AddCarScreen(
          vehicleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/vehicle/:vehicleId/service/add',
      builder: (_, state) => AddServiceScreen(
          vehicleId: int.parse(state.pathParameters['vehicleId']!)),
    ),
    GoRoute(
      path: '/service/:id',
      builder: (_, state) =>
          ServiceDetailScreen(serviceId: int.parse(state.pathParameters['id']!)),
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
          StatsScreen(vehicleId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

class CarServiceApp extends StatelessWidget {
  const CarServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PitStop',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('pl'), Locale('en')],
      locale: const Locale('pl'),
    );
  }
}
