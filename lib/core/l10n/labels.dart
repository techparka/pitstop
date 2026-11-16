/// Nazwy kategorii i typów zapisane w bazie, ale w języku interfejsu.
///
/// Baza przechowuje wartości techniczne (`OIL_CHANGE`, `FUEL`, `Benzyna`), więc
/// zmiana języku nie zmienia żadnych danych — szczegóły w sekcji „Pułapka
/// wartości słownikowych" w `docs/I18N-NOTES.md`.
///
/// Wartości nierozpoznane (np. kategoria z importu CSV) wracają bez zmian,
/// zamiast być po cichu przeklęte na „Inne".
library;

import 'package:flutter/widgets.dart';

import '../../shared/widgets/service_type_chip.dart';
import 'app_formats.dart';

/// Kategorie wpisu używane w filtrach i w tabeli `events`.
const categoryKeys = [
  'FUEL',
  'SERVICE',
  'REPAIR',
  'ACCESSORY',
  'ADMINISTRATIVE',
];

/// Techniczny klucz kategorii; `other` dla wartości spoza słownika.
///
/// Zwraca wielkie litery, aby dało się go porównywać z `event.category` bez
/// zależności od tego, jak wygląda zapis w konkretnym wierszu bazy.
String categoryKey(String raw) {
  final value = raw.trim().toUpperCase();
  return categoryKeys.contains(value) ? value : 'other';
}

/// Nazwa kategorii w języku interfejsu.
String categoryName(BuildContext context, String key) =>
    switch (categoryKey(key)) {
      'FUEL' => context.l10n.categoryFuel,
      'SERVICE' => context.l10n.categoryService,
      'REPAIR' => context.l10n.categoryRepair,
      'ACCESSORY' => context.l10n.categoryAccessory,
      'ADMINISTRATIVE' => context.l10n.categoryAdministrative,
      _ => key,
    };

/// Etykieta kategorii wpisu: najpierw typ serwisu, potem kategoria ogólna.
String categoryLabel(BuildContext context, String category) {
  for (final type in ServiceType.values) {
    if (type.value == category) return type.label(context);
  }
  return categoryName(context, category);
}

/// Paliwo z pola `fuel` w wpisach tankowania.
///
/// Wartości w bazie to `Benzyna`, `Diesel`, `LPG` — te same słowa co w napędzie,
/// więc tekstów nie dublujemy; osobna funkcja zostaje po to, by czytelnik
/// widział, której dziedziny dotyczy słowo.
String fuelLabel(BuildContext context, String fuel) {
  final l = context.l10n;
  return switch (fuel.trim().toLowerCase()) {
    'benzyna' || 'petrol' || 'gasoline' => l.powertrainPetrol,
    'diesel' || 'olej napędowy' || 'olej' => l.powertrainDiesel,
    'lpg' || 'autogaz' => l.powertrainLpg,
    _ => fuel,
  };
}

/// Napęd zapisany w tabeli `vehicles`.
///
/// Domyślna wartość kolumny to `Benzyna`, a starsze wpisy trzymają polskie
/// nazwy, więc tłumaczenie działa w obie strony: `Petrol` z ewentualnego
/// importu wróci jako „Benzyna" po polsku i „Petrol" po angielsku.
String powertrainLabel(BuildContext context, String powertrain) {
  final l = context.l10n;
  final key = powertrain.trim().toLowerCase();
  return switch (key) {
    'benzyna' || 'petrol' || 'gasoline' => l.powertrainPetrol,
    'diesel' || 'olej napędowy' || 'olej' => l.powertrainDiesel,
    'lpg' || 'autogaz' => l.powertrainLpg,
    'hybryda (benzyna)' || 'hybrid (petrol)' => l.powertrainHybridPetrol,
    'hybryda (diesel)' || 'hybrid (diesel)' => l.powertrainHybridDiesel,
    'hybryda' || 'hybrid' => l.powertrainHybrid,
    'hybryda plug-in' || 'plug-in hybrid' || 'phev' =>
      l.powertrainPlugInHybrid,
    'benzyna + lpg' || 'petrol + lpg' => l.powertrainPetrolLpg,
    'elektryczny' || 'electric' || 'ev' => l.powertrainElectric,
    _ => powertrain,
  };
}

/// Napędy dostępne w formularzu auta — wartości zapisywane w `vehicles`.
const powertrainValues = [
  'Benzyna',
  'Diesel',
  'Benzyna + LPG',
  'Hybryda',
  'Hybryda plug-in',
  'Elektryczny',
];

/// Paliwa używane w polu `fuel` i w kategorii wpisów tankowania.
const fuelValues = ['Benzyna', 'Diesel', 'LPG'];

/// Wbudowane kategorie wydatków z `ledger_entries.category`.
///
/// Katalogu nie da się przerzucić na angielskie identyfikatory bez migracji
/// danych, a przypisywane są do niego także kategorie własne z CSV. Zostają
/// polskie wartości, a etykiety są tłumaczone w locie.
const expenseCategoryValues = [
  'Ubezpieczenie',
  'Parking',
  'Opłaty drogowe',
  'Myjnia',
  'Inne',
];

/// Etykieta kategorii wpisu w księdze (wydatek, tankowanie, ładowanie).
///
/// Obsługuje trzy rodzaje wartości: wbudowane kategorie wydatków, kategorie
/// techniczne (`FUEL`, `SERVICE`) oraz nazwy paliw, które dla tankowań lądują
/// w tym samym słupku. Wartość spoza słownika wraca bez zmian.
String ledgerCategoryLabel(BuildContext context, String category) {
  final l = context.l10n;
  final trimmed = category.trim();
  final technical = categoryLabel(context, trimmed);
  if (technical != trimmed) return technical;
  final fuel = fuelLabel(context, trimmed);
  if (fuel != trimmed) return fuel;
  return switch (trimmed) {
    'Ubezpieczenie' => l.categoryInsurance,
    'Parking' => l.categoryParking,
    'Opłaty drogowe' => l.categoryRoadTolls,
    'Myjnia' => l.categoryCarWash,
    'Inne' => l.serviceTypeOther,
    'Energia' => l.categoryEnergy,
    'Przebieg' => l.mileageLabel,
    _ => category,
  };
}

/// Rodzaje pozycji serwisowych tak, jak są zapisane w `service_items.kind`.
///
/// Kolejność listy to kolejność na rozwiniętej liście wyboru w formularzu.
const itemKindValues = ['Część', 'Robocizna'];

/// Etykieta rodzaju pozycji serwisowej; wartość w bazie zostaje polska.
String itemKindLabel(BuildContext context, String kind) {
  final l = context.l10n;
  return switch (kind.trim().toLowerCase()) {
    'część' || 'częsci' || 'czesc' || 'part' => l.itemKindPart,
    'robocizna' || 'usługa' || 'usluga' || 'labour' || 'labor' =>
      l.itemKindLabour,
    _ => kind,
  };
}
