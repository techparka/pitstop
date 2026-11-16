import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../domain/calculations.dart' show Money;
import '../../l10n/generated/app_localizations.dart';
import 'app_currency.dart';

/// Formaty zależne od języka i waluty: kwoty, liczby, daty.
///
/// Teksty (zdania i etykiety) żyją w `AppLocalizations` z plików ARB; to jest
/// uzupełnienie o część numeryczną, której ARB nie opisuje. Warstwa jest
/// `InheritedWidget`, więc wywołanie potrzebuje tylko kontekstu:
///
/// ```dart
/// context.fmt.money(cents);              // 2 500,00 zł / 2,500.00 zł
/// context.fmt.dateMonth(DateTime.now()); // 5 sty 2026 / 5 Jan 2026
/// ```
///
/// Gdy w drzewie nie ma [_AppScope] (testy widgetów, podglądy projektanta),
/// `of()` odtwarza wartości domyślne z locale zwracanego przez `Localizations`,
/// a walutą pozostaje waluta bazowa po kursie 1,00.
class AppFormats extends InheritedWidget {
  const AppFormats(
      {super.key,
      required this.locale,
      required this.currency,
      required this.rate,
      required super.child});

  final Locale locale;
  final AppCurrency currency;

  /// Ile jednostek [currency] wypada na 1 PLN, czyli walutę bazową bazy danych.
  final double rate;

  static const baseCurrency = AppCurrency.pln;

  /// Locale podawane do `intl`: polski albo brytyjski angielski.
  String get intlLocale => locale.languageCode == 'pl' ? 'pl_PL' : 'en_GB';

  bool get _polish => intlLocale == 'pl_PL';

  static const _patterns = {
    'pl': {
      'date': 'd.MM.yyyy',
      'dateTime': 'd.MM.yyyy HH:mm',
      'month': 'd MMM yyyy',
      'long': 'd MMMM yyyy',
      'dayMonth': 'd MMMM',
    },
    'en': {
      'date': 'dd/MM/yyyy',
      'dateTime': 'dd/MM/yyyy HH:mm',
      'month': 'd MMM yyyy',
      'long': 'd MMMM yyyy',
      'dayMonth': 'd MMMM',
    },
  };

  String _format(String key, DateTime date) => DateFormat(
          (_patterns[_polish ? 'pl' : 'en']![key])!, intlLocale)
      .format(date);

  // --- kwoty ---------------------------------------------------------------

  /// Kwota z bazy (grosze PLN) przeliczona i sformatowana z osią i symbolem.
  String money(int baseCents) => formatMoney(toDisplay(baseCents));

  String formatMoney(double valueInCurrency) => NumberFormat.currency(
          locale: intlLocale, symbol: currency.symbol, customPattern: '#,##0.00 ¤')
      .format(valueInCurrency);

  /// Symbol waluty do składania jednostek, np. `zł/km` w statystykach.
  String get currencySymbol => currency.symbol;

  /// Wydatek w przeliczeniu na 1 km, np. `0,58 zł/km`.
  String moneyPerKm(int baseCents, int kilometres) => kilometres <= 0
      ? '—'
      : '${formatMoney(toDisplay(baseCents) / kilometres)}/km';

  /// Wartość z bazy do wpisania w pole kwoty, bez symbolu waluty.
  String moneyInput(int baseCents) => moneyPlain(toDisplay(baseCents));

  String moneyPlain(double valueInCurrency) =>
      NumberFormat.decimalPatternDigits(locale: intlLocale, decimalDigits: 2)
          .format(valueInCurrency);

  /// Tekst z pola kwoty -> grosze waluty bazowej; `null` gdy nie do odczytania.
  /// Waluta wyświetlana decyduje o separatorze, kurs o przeliczeniu.
  int? parseMoney(String input) {
    final cents = Money.parse(input, intlLocale);
    return cents == null ? null : (cents / rate).round();
  }

  double toDisplay(int baseCents) => baseCents / 100 * rate;

  /// Kwota w złotych trzymanej jako `double`, a nie jako grosze.
  ///
  /// Używane w statystykach, które liczą średnie w liczbach zmiennoprzecinkowych.
  String moneyFromZloty(double baseAmount) => formatMoney(baseAmount * rate);

  // --- liczby i daty -------------------------------------------------------

  /// Przebieg lub ilość z grupowaniem tysięcy, bez jednostki.
  String number(int value) =>
      NumberFormat.decimalPattern(intlLocale).format(value);

  String decimal(double value, {int digits = 2}) =>
      NumberFormat.decimalPatternDigits(
              locale: intlLocale, decimalDigits: digits)
          .format(value);

  /// Liczba z pola tekstowego, np. kurs waluty czy ilość litrów.
  ///
  /// Znak dziesiętny wygrywa ten, który wystąpił w tekście później, więc
  /// `0,24`, `0.24` i `1,234.56` są odczytywane poprawnie. Kwoty z bazy nie
  /// idą tą drogą — tam separator jest narzucony przez język i realizuje to
  /// `Money.parse`.
  double? parseDecimal(String input, {double minValue = 0}) {
    var cleaned = input.trim().replaceAll('\u00a0', '').replaceAll(' ', '');
    final comma = cleaned.lastIndexOf(','), dot = cleaned.lastIndexOf('.');
    if (comma >= 0 && dot >= 0) {
      cleaned = comma > dot
          ? cleaned.replaceAll('.', '').replaceAll(',', '.')
          : cleaned.replaceAll(',', '');
    } else if (comma >= 0) {
      cleaned = cleaned.replaceAll(',', '.');
    }
    final value = double.tryParse(cleaned);
    return value == null || value <= minValue ? null : value;
  }

  /// Skrócona data `12.03.2026` / `12/03/2026`.
  String dateNum(DateTime date) => _format('date', date);

  String dateTime(DateTime date) => _format('dateTime', date);

  String dateMonth(DateTime date) => _format('month', date);

  String dateLong(DateTime date) => _format('long', date);

  /// `12 marca` — bez roku, do nagłówków grup na listach.
  String dayMonth(DateTime date) => _format('dayMonth', date);

  /// Nagłówek grupy miesięcznej: `marzec 2026` / `March 2026`.
  String monthLabel(DateTime date) =>
      DateFormat('MMMM yyyy', intlLocale).format(date);

  /// Miesiąc z klucza grupowego `YYYY-MM` utworzonego przez [monthKey].
  String monthLabelFromKey(String key) =>
      monthLabel(DateTime.parse('$key-01T00:00:00'));

  /// Klucz grupowania po miesiącach. Zawsze ISO, bo wartość jest kluczem
  /// mapowania, a nie tekstem pokazywanym użytkownikowi.
  static String monthKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  static AppFormats? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppFormats>();

  static AppFormats of(BuildContext context) =>
      maybeOf(context) ??
      AppFormats(
          locale: Localizations.maybeLocaleOf(context) ?? const Locale('pl'),
          currency: baseCurrency,
          rate: 1,
          child: const SizedBox.shrink());

  @override
  bool updateShouldNotify(AppFormats oldWidget) =>
      oldWidget.locale != locale ||
      oldWidget.currency != currency ||
      oldWidget.rate != rate;
}

/// Skrót dostępu do tekstów i formatów przez `BuildContext`.
///
/// ```dart
/// context.l10n.navHistory  // teksty z ARB
/// context.fmt.money(cents) // kwoty, daty, liczby
/// ```
extension AppLocalizationsAccess on BuildContext {
  /// Teksty z plików ARB: `context.l10n.navHistory`.
  AppLocalizations get l10n {
    final l = Localizations.of<AppLocalizations>(this, AppLocalizations);
    if (l == null) {
      throw StateError(
          'AppLocalizations is not installed in this widget tree. Add '
          'AppLocalizations.localizationsDelegates to MaterialApp (tests do '
          'not get the app delegates for free).');
    }
    return l;
  }

  /// Kwoty, daty i liczby: `context.fmt.money(cents)`.
  AppFormats get fmt => AppFormats.of(this);
}

/// Jednostki measurealne wymagające języka; reszta formatów mieszka w [AppFormats].
extension FormatUnits on BuildContext {
  /// Przebieg z jednostką: `12 500 km`.
  String km(int value) => '${fmt.number(value)} ${l10n.unitKm}';

  /// Litry lub inne pojemności: `37,5 l`.
  String liters(double value) => '${fmt.decimal(value)} ${l10n.unitL}';
}
