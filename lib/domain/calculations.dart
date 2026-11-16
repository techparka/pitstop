/// Parsowanie i formatowanie kwot zapisywanych w groszach.
///
/// Parametr `locale` rozstrzyga wyłącznie znaczenie separatorów, bez przeliczeń
/// walutowych. Po polsku przecinek i kropka są wymienne jako separator
/// dziesiętny, więc `12.5` to 12,50, a `1,234` pozostaje błędem. Po angielsku
/// przecinek grupuje tysiące, więc `1,234.56` to 1234,56.
class Money {
  static int? parse(String input, [String locale = 'pl_PL']) {
    final digits = input.replaceAll(RegExp(r'[\s\u00a0]'), '');
    // Po angielsku przecinek grupuje tysiące, po polsku jest separatorem
    // dziesiętnym; kropka po polsku zostaje kropką dziesiętną, więc `1.2.3`
    // nadal jest błędem, a nie liczbą tysięcy.
    final value = locale.startsWith('en')
        ? digits.replaceAll(',', '')
        : digits.replaceAll(',', '.');
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) return null;
    final parts = value.split('.');
    final cents = int.tryParse(parts[0]);
    if (cents == null || cents > 1000000000) return null;
    return cents * 100 +
        (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
  }

  static String input(int cents, [String locale = 'pl_PL']) =>
      '${cents ~/ 100}${locale.startsWith('en') ? '.' : ','}'
      '${(cents % 100).toString().padLeft(2, '0')}';
}

DateTime addCalendarMonths(DateTime date, int months) {
  final first = DateTime(date.year, date.month + months);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, date.day > last ? last : date.day);
}

class FillUp {
  final int mileage;
  final double quantity;
  final bool full, missed;
  final String fuel;
  const FillUp(this.mileage, this.quantity,
      {this.full = true, this.missed = false, this.fuel = 'Benzyna'});
}

class FuelResult {
  final String fuel;
  final double liters;
  final int distance;
  const FuelResult(this.fuel, this.liters, this.distance);
  double get per100 => liters / distance * 100;
}

List<FuelResult> consumption(List<FillUp> entries) {
  final results = <FuelResult>[];
  final fuels = entries.map((e) => e.fuel).toSet();
  for (final fuel in fuels) {
    final rows = entries.where((e) => e.fuel == fuel).toList()
      ..sort((a, b) => a.mileage.compareTo(b.mileage));
    int? anchor;
    double pending = 0, liters = 0;
    int distance = 0;
    for (final row in rows) {
      if (row.missed) {
        anchor = null;
        pending = 0;
      }
      if (anchor == null) {
        if (row.full) anchor = row.mileage;
        continue;
      }
      if (row.mileage <= anchor) {
        anchor = row.full ? row.mileage : null;
        pending = 0;
        continue;
      }
      pending += row.quantity;
      if (row.full) {
        distance += row.mileage - anchor;
        liters += pending;
        anchor = row.mileage;
        pending = 0;
      }
    }
    if (distance > 0) results.add(FuelResult(fuel, liters, distance));
  }
  return results;
}
