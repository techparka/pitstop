import 'package:flutter/material.dart';

class AppTheme {
  static const orange = Color(0xFFFF7A3D);
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(seedColor: orange, brightness: brightness)
            .copyWith(
                primary: dark ? orange : const Color(0xFFBA410C),
                surface: dark ? const Color(0xFF1D222C) : Colors.white);
    final base = ThemeData(
        useMaterial3: true, colorScheme: scheme, brightness: brightness);
    return base.copyWith(
      scaffoldBackgroundColor:
          dark ? const Color(0xFF11151C) : const Color(0xFFF5F6F8),
      textTheme: base.textTheme.copyWith(
          headlineMedium: base.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
          titleLarge:
              base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: base.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      cardTheme: CardTheme(
          elevation: 0,
          color: scheme.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: scheme.outline.withOpacity(.10)))),
      appBarTheme: AppBarTheme(
          backgroundColor:
              dark ? const Color(0xFF11151C) : const Color(0xFFF5F6F8),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: scheme.outline.withOpacity(.25))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: scheme.outline.withOpacity(.25))),
          contentPadding: const EdgeInsets.all(18)),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size(48, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: scheme.surface,
          indicatorColor: scheme.primary.withOpacity(.13),
          height: 76),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: orange,
          foregroundColor: const Color(0xFF23150E),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      chipTheme:
          const ChipThemeData(shape: StadiumBorder(), showCheckmark: false),
      snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    );
  }
}
