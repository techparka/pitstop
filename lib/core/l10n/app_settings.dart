import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../l10n/generated/app_localizations.dart';
import 'app_currency.dart';

/// Język interfejsu wybierany przez użytkownika.
///
/// [AppLanguage.system] oznacza "podążaj za językiem telefonu"; pozostałe
/// wartości wymuszają własny wybór. Wartość jest zapisywana w tabeli
/// `app_settings` pod kluczem `language`, tak jak motyw.
enum AppLanguage {
  system('system'),
  polish('pl'),
  english('en');

  const AppLanguage(this.code);
  final String code;

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.code == code,
          orElse: () => AppLanguage.system);

  /// Locale dla `MaterialApp`; `null` pozostawia decyzję Flutterowi, czyli
  /// wybór systemu z dopasowaniem do `AppLocalizations.supportedLocales`.
  Locale? get locale => switch (this) {
        AppLanguage.system => null,
        AppLanguage.polish => const Locale('pl'),
        AppLanguage.english => const Locale('en'),
      };
}

/// Klucz ustawienia przechowującego język interfejsu.
const languageSettingKey = 'language';

/// Klucz ustawienia przechowującego kod waluty pokazowej.
const currencySettingKey = 'currency';

/// Waluta wyświetlania razem z kursem względem waluty bazowej (PLN).
class DisplayCurrency {
  const DisplayCurrency(this.currency, [this.rate = 1]);

  final AppCurrency currency;

  /// Ile jednostek [currency] wypada na 1 PLN. Kurs wpisuje użytkownik, bo
  /// aplikacja nie pobiera kursów z sieci.
  final double rate;

  /// Kurs zabezpieczony przed zerem i wartościami ujemnymi z zapisu.
  double get safeRate => rate > 0 ? rate : 1;

  @override
  bool operator ==(Object other) =>
      other is DisplayCurrency &&
      other.currency == currency &&
      other.rate == rate;

  @override
  int get hashCode => Object.hash(currency, rate);
}

/// Język interfejsu. `AppLanguage.system` jest domyślny, więc świeża instalacja
/// i instalacja po aktualizacji idzie za językiem telefonu.
final appLanguageProvider =
    StateProvider<AppLanguage>((ref) => AppLanguage.system);

/// Waluta pokazowa wraz z kursem.
final displayCurrencyProvider = StateProvider<DisplayCurrency>(
    (ref) => const DisplayCurrency(AppCurrency.pln));

/// Ustawienia wyświetlania odczytane z bazy.
class DisplaySettings {
  const DisplaySettings({required this.language, required this.currency});
  final AppLanguage language;
  final DisplayCurrency currency;
}

Future<String?> _setting(AppDatabase db, String key) async =>
    (await (db.select(db.appSettings)..where((s) => s.key.equals(key)))
            .getSingleOrNull())
        ?.value;

/// Locale, którego użyje aplikacja.
///
/// `AppLanguage.system` oddaje decyzję językom telefonu, a przy języku
/// nieobsługiwanym wypada na angielski — tak samo postępuje `MaterialApp`
/// dla `AppLocalizations.supportedLocales`, gdzie `en` jest pierwszy.
Locale resolveAppLocale(AppLanguage language) {
  final forced = language.locale;
  if (forced != null) return forced;
  for (final candidate in WidgetsBinding.instance.platformDispatcher.locales) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == candidate.languageCode) return supported;
    }
  }
  return AppLocalizations.supportedLocales.first;
}

/// Odczyt języka, waluty i kursu.
Future<DisplaySettings> readDisplaySettings(AppDatabase db) async {
  final currency = AppCurrency.fromCode(await _setting(db, currencySettingKey));
  final stored = await _setting(db, AppCurrency.rateKey(currency));
  final rate = double.tryParse((stored ?? '').replaceAll(',', '.'));
  return DisplaySettings(
    language: AppLanguage.fromCode(await _setting(db, languageSettingKey)),
    currency: DisplayCurrency(
        currency, currency.isBase ? 1 : (rate == null || rate <= 0 ? 1 : rate)),
  );
}

/// Zapis języka interfejsu.
Future<void> saveLanguage(AppDatabase db, AppLanguage language) => db
    .into(db.appSettings)
    .insertOnConflictUpdate(AppSettingsCompanion.insert(
        key: languageSettingKey, value: language.code));

/// Kurs zapisany wcześniej dla waluty; `1.0` dla waluty bazowej i dla waluty,
/// której kursu jeszcze nie wpisano lub wpisano błędnie.
Future<double> readRate(AppDatabase db, AppCurrency currency) async {
  if (currency.isBase) return 1;
  final stored = double.tryParse(
      ((await _setting(db, AppCurrency.rateKey(currency))) ?? '')
          .replaceAll(',', '.'));
  return stored == null || stored <= 0 ? 1 : stored;
}

/// Zapis waluty pokazowej; przy walucie bazowej kurs jest zawsze 1,00.
Future<void> saveCurrency(AppDatabase db, DisplayCurrency value) async {
  await db.into(db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
          key: currencySettingKey, value: value.currency.code));
  await db.into(db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
          key: AppCurrency.rateKey(value.currency),
          value: value.currency.isBase
              ? '1'
              : value.rate.toStringAsFixed(6).trim()));
}

/// Wstrzykuje odczytane ustawienia do stanu aplikacji.
void applyDisplaySettings(WidgetRef ref, DisplaySettings settings) {
  ref.read(appLanguageProvider.notifier).state = settings.language;
  ref.read(displayCurrencyProvider.notifier).state = settings.currency;
}
