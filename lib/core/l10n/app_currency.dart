/// Waluty dostępne w ustawieniach aplikacji.
///
/// Bazą rozliczeniową pozostają **grosze PLN** (kolumny `*_cents` w bazie).
/// Wybór waluty zmienia sposób wyświetlania i interpretację pól kwotowych;
/// przeliczenie opiera się na kursie wpisanym ręcznie, bo aplikacja jest
/// offline i nie pobiera kursów z sieci.
enum AppCurrency {
  pln('PLN', 'zł'),
  eur('EUR', '€'),
  gbp('GBP', '£'),
  usd('USD', r'$'),
  chf('CHF', 'CHF'),
  czk('CZK', 'Kč'),
  nok('NOK', 'kr'),
  sek('SEK', 'kr'),
  dkk('DKK', 'kr'),
  huf('HUF', 'Ft'),
  uah('UAH', '₴'),
  turkish('TRY', '₺');

  const AppCurrency(this.code, this.symbol);

  /// Kod ISO 4217 — także wartość zapisywana w tabeli `app_settings`.
  final String code;

  /// Znak używany przy formatowaniu kwot.
  final String symbol;

  /// Waluta bazowa, przy której kurs jest zablokowany na 1,00.
  bool get isBase => this == AppCurrency.pln;

  static AppCurrency fromCode(String? code) => AppCurrency.values.firstWhere(
      (c) => c.code == code?.toUpperCase(),
      orElse: () => AppCurrency.pln);

  /// Nazwa klucza ustawienia przechowującego kurs tej waluty.
  static String rateKey(AppCurrency currency) => 'currencyRate.${currency.code}';
}
