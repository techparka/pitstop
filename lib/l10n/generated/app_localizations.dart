import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// Podtytuł na pasku pulpitu
  ///
  /// In pl, this message translates to:
  /// **'Wszystko o Twoim aucie'**
  String get appTagline;

  /// Błąd nasłuchiwania zmian w bazie
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć bazy danych.'**
  String get backupErrorDatabaseOpen;

  /// Błąd automatycznej kopii ZIP
  ///
  /// In pl, this message translates to:
  /// **'Automatyczna kopia nie powstała. Sprawdź dostępne miejsce i brakujące załączniki.'**
  String get backupErrorAutomaticFailed;

  /// No description provided for @languageSetting.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get languageSetting;

  /// No description provided for @languageSystem.
  ///
  /// In pl, this message translates to:
  /// **'Zgodnie z systemem'**
  String get languageSystem;

  /// No description provided for @currencySetting.
  ///
  /// In pl, this message translates to:
  /// **'Waluta'**
  String get currencySetting;

  /// No description provided for @currencyRateSetting.
  ///
  /// In pl, this message translates to:
  /// **'Kurs 1 zł'**
  String get currencyRateSetting;

  /// Dolna nawigacja — ekran główny auta
  ///
  /// In pl, this message translates to:
  /// **'Pulpit'**
  String get navDashboard;

  /// No description provided for @navHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia'**
  String get navHistory;

  /// No description provided for @navReminders.
  ///
  /// In pl, this message translates to:
  /// **'Terminy'**
  String get navReminders;

  /// No description provided for @navGarage.
  ///
  /// In pl, this message translates to:
  /// **'Garaż'**
  String get navGarage;

  /// No description provided for @errorOperationFailed.
  ///
  /// In pl, this message translates to:
  /// **'Operacja nie powiodła się. Dane pozostają bez zmian. Sprawdź plik i dostępne miejsce.'**
  String get errorOperationFailed;

  /// No description provided for @errorPdfAndroidOnly.
  ///
  /// In pl, this message translates to:
  /// **'Eksport PDF jest dostępny w wersji Android.'**
  String get errorPdfAndroidOnly;

  /// No description provided for @errorCsvUnreadable.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać CSV. Użyj kodowania UTF-8 oraz separatora ; lub ,'**
  String get errorCsvUnreadable;

  /// No description provided for @errorCsvImportFailed.
  ///
  /// In pl, this message translates to:
  /// **'Import nie powiódł się. Nie dodano żadnych wierszy.'**
  String get errorCsvImportFailed;

  /// No description provided for @errorRestoreFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się przywrócić kopii. Sprawdź plik i dostępne miejsce.'**
  String get errorRestoreFailed;

  /// Powiadomienie o terminie w dniu terminu
  ///
  /// In pl, this message translates to:
  /// **'Termin dzisiaj'**
  String get notifDueToday;

  /// Powiadomienie o terminie, który już minął
  ///
  /// In pl, this message translates to:
  /// **'Termin minął — sprawdź szczegóły'**
  String get notifDueOverdue;

  /// Powiadomzenie z wyprzedzeniem
  ///
  /// In pl, this message translates to:
  /// **'{days, plural, =1{Termin za 1 dzień} other{Termin za {days} dni}}'**
  String notifDueInDays(num days);

  /// Powiadomienie przebiegowe
  ///
  /// In pl, this message translates to:
  /// **'Osiągnięto przebieg {mileage} km'**
  String notifMileageReached(Object mileage);

  /// Powiadomienie przebiegowe z zapasem
  ///
  /// In pl, this message translates to:
  /// **'Pozostało {remaining} km według ostatniego odczytu'**
  String notifMileageRemaining(Object remaining);

  /// Typ wpisu: paliwo
  ///
  /// In pl, this message translates to:
  /// **'Paliwo'**
  String get categoryFuel;

  /// Typ wpisu: serwis
  ///
  /// In pl, this message translates to:
  /// **'Serwis'**
  String get categoryService;

  /// Typ wpisu: naprawa
  ///
  /// In pl, this message translates to:
  /// **'Naprawa'**
  String get categoryRepair;

  /// Typ wpisu: wyposażenie
  ///
  /// In pl, this message translates to:
  /// **'Wyposażenie'**
  String get categoryAccessory;

  /// Typ wpisu: opłaty i dokumenty
  ///
  /// In pl, this message translates to:
  /// **'Opłaty'**
  String get categoryAdministrative;

  /// No description provided for @serviceTypeOilChange.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana oleju'**
  String get serviceTypeOilChange;

  /// No description provided for @serviceTypeBrakes.
  ///
  /// In pl, this message translates to:
  /// **'Hamulce'**
  String get serviceTypeBrakes;

  /// No description provided for @serviceTypeFilters.
  ///
  /// In pl, this message translates to:
  /// **'Filtry'**
  String get serviceTypeFilters;

  /// No description provided for @serviceTypeTiming.
  ///
  /// In pl, this message translates to:
  /// **'Rozrząd'**
  String get serviceTypeTiming;

  /// No description provided for @serviceTypeBattery.
  ///
  /// In pl, this message translates to:
  /// **'Akumulator'**
  String get serviceTypeBattery;

  /// No description provided for @serviceTypeFluids.
  ///
  /// In pl, this message translates to:
  /// **'Płyny'**
  String get serviceTypeFluids;

  /// No description provided for @serviceTypeAirConditioning.
  ///
  /// In pl, this message translates to:
  /// **'Klimatyzacja'**
  String get serviceTypeAirConditioning;

  /// No description provided for @serviceTypeSuspension.
  ///
  /// In pl, this message translates to:
  /// **'Zawieszenie'**
  String get serviceTypeSuspension;

  /// No description provided for @serviceTypeRepair.
  ///
  /// In pl, this message translates to:
  /// **'Naprawa'**
  String get serviceTypeRepair;

  /// No description provided for @serviceTypeInspection.
  ///
  /// In pl, this message translates to:
  /// **'Przegląd'**
  String get serviceTypeInspection;

  /// No description provided for @serviceTypeTires.
  ///
  /// In pl, this message translates to:
  /// **'Opony'**
  String get serviceTypeTires;

  /// No description provided for @serviceTypeOther.
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get serviceTypeOther;

  /// No description provided for @powertrainPetrol.
  ///
  /// In pl, this message translates to:
  /// **'Benzyna'**
  String get powertrainPetrol;

  /// No description provided for @powertrainDiesel.
  ///
  /// In pl, this message translates to:
  /// **'Diesel'**
  String get powertrainDiesel;

  /// No description provided for @powertrainLpg.
  ///
  /// In pl, this message translates to:
  /// **'LPG'**
  String get powertrainLpg;

  /// No description provided for @powertrainHybridPetrol.
  ///
  /// In pl, this message translates to:
  /// **'Hybryda (benzyna)'**
  String get powertrainHybridPetrol;

  /// No description provided for @powertrainHybridDiesel.
  ///
  /// In pl, this message translates to:
  /// **'Hybryda (diesel)'**
  String get powertrainHybridDiesel;

  /// No description provided for @powertrainElectric.
  ///
  /// In pl, this message translates to:
  /// **'Elektryczny'**
  String get powertrainElectric;

  /// No description provided for @unitKm.
  ///
  /// In pl, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitL.
  ///
  /// In pl, this message translates to:
  /// **'l'**
  String get unitL;

  /// No description provided for @unitKmPerL.
  ///
  /// In pl, this message translates to:
  /// **'km/l'**
  String get unitKmPerL;

  /// No description provided for @unitLPer100km.
  ///
  /// In pl, this message translates to:
  /// **'l/100 km'**
  String get unitLPer100km;

  /// No description provided for @loadFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać danych.'**
  String get loadFailed;

  /// No description provided for @tryAgain.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get tryAgain;

  /// No description provided for @titleGarageTab.
  ///
  /// In pl, this message translates to:
  /// **'Twój garaż'**
  String get titleGarageTab;

  /// No description provided for @settingsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia i kopie danych'**
  String get settingsTooltip;

  /// No description provided for @addCarAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj auto'**
  String get addCarAction;

  /// No description provided for @addEntryAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wpis'**
  String get addEntryAction;

  /// No description provided for @emptyGarageTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dobra historia zaczyna się tutaj'**
  String get emptyGarageTitle;

  /// No description provided for @emptyGarageBody.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj auto. Serwisy, koszty i ważne terminy będą zawsze pod ręką — również bez internetu.'**
  String get emptyGarageBody;

  /// No description provided for @addFirstCar.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwsze auto'**
  String get addFirstCar;

  /// No description provided for @haveBackup.
  ///
  /// In pl, this message translates to:
  /// **'Mam kopię danych'**
  String get haveBackup;

  /// No description provided for @yourCarBadge.
  ///
  /// In pl, this message translates to:
  /// **'TWOJE AUTO'**
  String get yourCarBadge;

  /// No description provided for @carProfileTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Profil i edycja auta'**
  String get carProfileTooltip;

  /// No description provided for @lastKnownMileage.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni znany przebieg'**
  String get lastKnownMileage;

  /// No description provided for @metricMonthExpenses.
  ///
  /// In pl, this message translates to:
  /// **'Wydatki w tym miesiącu'**
  String get metricMonthExpenses;

  /// No description provided for @metricActiveReminders.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne terminy'**
  String get metricActiveReminders;

  /// No description provided for @analyticsCardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zobacz, ile kosztuje Twoje auto'**
  String get analyticsCardTitle;

  /// No description provided for @analyticsCardSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Koszty, trendy i zużycie paliwa'**
  String get analyticsCardSubtitle;

  /// No description provided for @backupCardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zabezpiecz historię auta'**
  String get backupCardTitle;

  /// No description provided for @backupCardSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz pełną kopię poza telefonem.'**
  String get backupCardSubtitle;

  /// No description provided for @sectionUpcoming.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe terminy'**
  String get sectionUpcoming;

  /// No description provided for @actionAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get actionAll;

  /// No description provided for @hintCalmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Spokojna głowa'**
  String get hintCalmTitle;

  /// No description provided for @hintCalmBody.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj badanie techniczne, polisę lub następny serwis.'**
  String get hintCalmBody;

  /// No description provided for @sectionRecentActivity.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnia aktywność'**
  String get sectionRecentActivity;

  /// No description provided for @hintFirstEntryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pierwszy wpis przed Tobą'**
  String get hintFirstEntryTitle;

  /// No description provided for @hintFirstEntryBody.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz serwis, tankowanie lub inny wydatek.'**
  String get hintFirstEntryBody;

  /// No description provided for @privacyNote.
  ///
  /// In pl, this message translates to:
  /// **'Twoje dane. Tylko na Twoim urządzeniu.'**
  String get privacyNote;

  /// No description provided for @searchEntriesHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj wpisu, opisu, warsztatu…'**
  String get searchEntriesHint;

  /// No description provided for @filterAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko'**
  String get filterAll;

  /// No description provided for @filterServices.
  ///
  /// In pl, this message translates to:
  /// **'Serwisy'**
  String get filterServices;

  /// No description provided for @filterCharges.
  ///
  /// In pl, this message translates to:
  /// **'Ładowania'**
  String get filterCharges;

  /// No description provided for @filterExpenses.
  ///
  /// In pl, this message translates to:
  /// **'Wydatki'**
  String get filterExpenses;

  /// No description provided for @filterMileage.
  ///
  /// In pl, this message translates to:
  /// **'Przebieg'**
  String get filterMileage;

  /// No description provided for @filterAnyCategory.
  ///
  /// In pl, this message translates to:
  /// **'Każda kategoria'**
  String get filterAnyCategory;

  /// No description provided for @filterDatesTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Filtruj daty'**
  String get filterDatesTooltip;

  /// No description provided for @removeDateRangeTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń zakres dat'**
  String get removeDateRangeTooltip;

  /// Podsumowanie filtry historii: liczba wpisów i suma kwot
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{{count} wpis · {total}} few{{count} wpisy · {total}} many{{count} wpisów · {total}} other{{count} wpisów · {total}}}'**
  String entriesSummary(num count, Object total);

  /// No description provided for @noMatchingEntries.
  ///
  /// In pl, this message translates to:
  /// **'Brak pasujących wpisów'**
  String get noMatchingEntries;

  /// No description provided for @termsRuleTitle.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw data lub przebieg'**
  String get termsRuleTitle;

  /// No description provided for @termsRuleBody.
  ///
  /// In pl, this message translates to:
  /// **'Obowiązuje wcześniejszy warunek. Przebiegowe terminy korzystają z ostatniego wpisanego odczytu.'**
  String get termsRuleBody;

  /// No description provided for @notificationsConsentHint.
  ///
  /// In pl, this message translates to:
  /// **'Zgodę na powiadomienia możesz też zmienić w ustawieniach telefonu.'**
  String get notificationsConsentHint;

  /// No description provided for @enableNotifications.
  ///
  /// In pl, this message translates to:
  /// **'Włącz powiadomienia'**
  String get enableNotifications;

  /// No description provided for @noActiveRemindersTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnych terminów'**
  String get noActiveRemindersTitle;

  /// No description provided for @noActiveRemindersBody.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj przypomnienie przyciskiem poniżej.'**
  String get noActiveRemindersBody;

  /// No description provided for @doneRemindersSection.
  ///
  /// In pl, this message translates to:
  /// **'Wykonane ({count})'**
  String doneRemindersSection(Object count);

  /// No description provided for @editAction.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get deleteAction;

  /// No description provided for @cancelAction.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancelAction;

  /// No description provided for @deleteReminderTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć termin?'**
  String get deleteReminderTitle;

  /// No description provided for @markDoneTitle.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako wykonane'**
  String get markDoneTitle;

  /// No description provided for @markDoneBody.
  ///
  /// In pl, this message translates to:
  /// **'Czy zapisać również wpis w historii serwisów?'**
  String get markDoneBody;

  /// No description provided for @markDoneOnly.
  ///
  /// In pl, this message translates to:
  /// **'Tylko wykonaj'**
  String get markDoneOnly;

  /// No description provided for @addServiceAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj serwis'**
  String get addServiceAction;

  /// No description provided for @reminderDoneAction.
  ///
  /// In pl, this message translates to:
  /// **'Wykonane'**
  String get reminderDoneAction;

  /// No description provided for @reminderOptionsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Opcje przypomnienia'**
  String get reminderOptionsTooltip;

  /// No description provided for @urgencyAttention.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga uwagi'**
  String get urgencyAttention;

  /// No description provided for @urgencySoon.
  ///
  /// In pl, this message translates to:
  /// **'Już niedługo'**
  String get urgencySoon;

  /// No description provided for @urgencyPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanowane'**
  String get urgencyPlanned;

  /// No description provided for @kmRemaining.
  ///
  /// In pl, this message translates to:
  /// **'{remaining} km pozostało'**
  String kmRemaining(Object remaining);

  /// No description provided for @repeatLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powtarzaj: {rules}'**
  String repeatLabel(Object rules);

  /// No description provided for @repeatEveryMonths.
  ///
  /// In pl, this message translates to:
  /// **'{months, plural, one{co {months} miesiąc} few{co {months} miesiące} many{co {months} miesięcy} other{co {months} miesięcy}}'**
  String repeatEveryMonths(num months);

  /// No description provided for @repeatEveryKm.
  ///
  /// In pl, this message translates to:
  /// **'co {km}'**
  String repeatEveryKm(Object km);

  /// No description provided for @repeatOr.
  ///
  /// In pl, this message translates to:
  /// **'lub'**
  String get repeatOr;

  /// No description provided for @garageTabTitle.
  ///
  /// In pl, this message translates to:
  /// **'Każde auto ma swoją historię'**
  String get garageTabTitle;

  /// No description provided for @addSheetTitle.
  ///
  /// In pl, this message translates to:
  /// **'Co chcesz zapisać?'**
  String get addSheetTitle;

  /// No description provided for @addServiceEntry.
  ///
  /// In pl, this message translates to:
  /// **'Serwis'**
  String get addServiceEntry;

  /// No description provided for @addRefuel.
  ///
  /// In pl, this message translates to:
  /// **'Tankowanie'**
  String get addRefuel;

  /// No description provided for @addCharge.
  ///
  /// In pl, this message translates to:
  /// **'Ładowanie'**
  String get addCharge;

  /// No description provided for @addExpense.
  ///
  /// In pl, this message translates to:
  /// **'Wydatek'**
  String get addExpense;

  /// No description provided for @addReminder.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie'**
  String get addReminder;

  /// No description provided for @analyticsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Koszty i zużycie'**
  String get analyticsTitle;

  /// No description provided for @statsLoadFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać statystyk'**
  String get statsLoadFailed;

  /// No description provided for @periodAll.
  ///
  /// In pl, this message translates to:
  /// **'Cała historia'**
  String get periodAll;

  /// No description provided for @periodMonth.
  ///
  /// In pl, this message translates to:
  /// **'Ten miesiąc'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In pl, this message translates to:
  /// **'Ten rok'**
  String get periodYear;

  /// No description provided for @periodCustom.
  ///
  /// In pl, this message translates to:
  /// **'Własny okres'**
  String get periodCustom;

  /// No description provided for @amountsInCurrency.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie kwoty w {currency}. Każdy koszt liczony tylko raz.'**
  String amountsInCurrency(Object currency);

  /// No description provided for @metricTotalExpenses.
  ///
  /// In pl, this message translates to:
  /// **'Łączne wydatki'**
  String get metricTotalExpenses;

  /// No description provided for @metricCostedEntries.
  ///
  /// In pl, this message translates to:
  /// **'Wpisy z kosztem'**
  String get metricCostedEntries;

  /// No description provided for @metricCostPerKm.
  ///
  /// In pl, this message translates to:
  /// **'Koszt kilometra'**
  String get metricCostPerKm;

  /// No description provided for @costPerKmRange.
  ///
  /// In pl, this message translates to:
  /// **'Koszt/km: {from} – {to}, {km}. Koszty poza tym odcinkiem nie wchodzą do wskaźnika.'**
  String costPerKmRange(Object from, Object km, Object to);

  /// No description provided for @costPerKmNeedsReadings.
  ///
  /// In pl, this message translates to:
  /// **'Koszt/km wymaga dwóch odczytów przebiegu z różnymi wartościami w wybranym okresie.'**
  String get costPerKmNeedsReadings;

  /// No description provided for @fuelConsumptionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zużycie paliwa'**
  String get fuelConsumptionTitle;

  /// No description provided for @fuelNeedsMoreData.
  ///
  /// In pl, this message translates to:
  /// **'Za mało danych. Dodaj co najmniej dwa pełne tankowania tego samego paliwa. Częściowe tankowania są sumowane, a pominięte przerywają odcinek.'**
  String get fuelNeedsMoreData;

  /// No description provided for @fuelCalculatedOver.
  ///
  /// In pl, this message translates to:
  /// **'{fuel} · obliczono dla {km}'**
  String fuelCalculatedOver(Object fuel, Object km);

  /// No description provided for @fuelSplitNote.
  ///
  /// In pl, this message translates to:
  /// **'Benzyna i LPG są liczone osobno. Przy jeździe na dwóch paliwach wyniki opisują udział każdego paliwa, nie samodzielne spalanie silnika.'**
  String get fuelSplitNote;

  /// No description provided for @expensesByCategory.
  ///
  /// In pl, this message translates to:
  /// **'Wydatki według kategorii'**
  String get expensesByCategory;

  /// No description provided for @monthByMonth.
  ///
  /// In pl, this message translates to:
  /// **'Miesiąc po miesiącu'**
  String get monthByMonth;

  /// No description provided for @addFirstEntryForStats.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy wpis, aby zobaczyć statystyki.'**
  String get addFirstEntryForStats;

  /// No description provided for @settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTitle;

  /// No description provided for @restoreDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przywrócić kopię?'**
  String get restoreDialogTitle;

  /// No description provided for @restoreVehiclesCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{{count} auto} few{{count} auta} many{{count} aut} other{{count} aut}}'**
  String restoreVehiclesCount(num count);

  /// No description provided for @restoreEntriesCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{{count} wpis} few{{count} wpisy} many{{count} wpisów} other{{count} wpisów}}'**
  String restoreEntriesCount(num count);

  /// No description provided for @restoreCreatedAt.
  ///
  /// In pl, this message translates to:
  /// **'Kopia z {created}'**
  String restoreCreatedAt(Object created);

  /// No description provided for @restoreDialogWarning.
  ///
  /// In pl, this message translates to:
  /// **'Zastąpi aktualne dane. Najpierw zapiszemy kopię bezpieczeństwa obecnego stanu.'**
  String get restoreDialogWarning;

  /// No description provided for @restoreDone.
  ///
  /// In pl, this message translates to:
  /// **'Przywrócono dane i załączniki. Poprzedni stan jest w kopiach lokalnych.'**
  String get restoreDone;

  /// No description provided for @reportGeneratedOn.
  ///
  /// In pl, this message translates to:
  /// **'Wygenerowano {date}'**
  String reportGeneratedOn(Object date);

  /// No description provided for @reportVin.
  ///
  /// In pl, this message translates to:
  /// **'VIN: {vin}'**
  String reportVin(Object vin);

  /// No description provided for @reportRegistration.
  ///
  /// In pl, this message translates to:
  /// **'Rejestracja: {plate}'**
  String reportRegistration(Object plate);

  /// No description provided for @reportServiceItems.
  ///
  /// In pl, this message translates to:
  /// **'Pozycje serwisowe (zawarte w kwotach serwisów):'**
  String get reportServiceItems;

  /// No description provided for @reportPreviewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd raportu'**
  String get reportPreviewTitle;

  /// No description provided for @createPdfAction.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz PDF'**
  String get createPdfAction;

  /// No description provided for @yourDataHeader.
  ///
  /// In pl, this message translates to:
  /// **'TWOJE DANE'**
  String get yourDataHeader;

  /// No description provided for @privacyBadge.
  ///
  /// In pl, this message translates to:
  /// **'Bez konta. Bez reklam. Bez opłat.'**
  String get privacyBadge;

  /// No description provided for @privacyBody.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko działa na urządzeniu. Kopia lokalna nie ochroni danych po utracie telefonu — regularnie zapisz ZIP poza nim.'**
  String get privacyBody;

  /// No description provided for @saveFullBackup.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz pełną kopię ZIP'**
  String get saveFullBackup;

  /// No description provided for @saveFullBackupSub.
  ///
  /// In pl, this message translates to:
  /// **'Dane, ustawienia, zdjęcia i dokumenty'**
  String get saveFullBackupSub;

  /// No description provided for @backupSaved.
  ///
  /// In pl, this message translates to:
  /// **'Kopia zapisana w wybranym miejscu. Regularnie przechowuj ją także poza telefonem.'**
  String get backupSaved;

  /// No description provided for @backupSaveCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Anulowano zapis zewnętrzny. Kopia jest dostępna w kopiach lokalnych.'**
  String get backupSaveCancelled;

  /// No description provided for @restoreFromFile.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć z pliku ZIP'**
  String get restoreFromFile;

  /// No description provided for @restoreFromFileSub.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw sprawdzimy integralność kopii'**
  String get restoreFromFileSub;

  /// No description provided for @localBackups.
  ///
  /// In pl, this message translates to:
  /// **'Kopie lokalne'**
  String get localBackups;

  /// No description provided for @localBackupsSub.
  ///
  /// In pl, this message translates to:
  /// **'5 ostatnich automatycznych + kopie ręczne'**
  String get localBackupsSub;

  /// No description provided for @chooseBackup.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz kopię do przywrócenia'**
  String get chooseBackup;

  /// No description provided for @noBackups.
  ///
  /// In pl, this message translates to:
  /// **'Brak kopii'**
  String get noBackups;

  /// No description provided for @appearanceSection.
  ///
  /// In pl, this message translates to:
  /// **'Wygląd i powiadomienia'**
  String get appearanceSection;

  /// No description provided for @themeSetting.
  ///
  /// In pl, this message translates to:
  /// **'Motyw'**
  String get themeSetting;

  /// No description provided for @themeSystem.
  ///
  /// In pl, this message translates to:
  /// **'Zgodnie z systemem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In pl, this message translates to:
  /// **'Jasny'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pl, this message translates to:
  /// **'Ciemny'**
  String get themeDark;

  /// No description provided for @notificationsOn.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia włączone'**
  String get notificationsOn;

  /// No description provided for @notificationsOff.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia wyłączone'**
  String get notificationsOff;

  /// No description provided for @notificationsExplain.
  ///
  /// In pl, this message translates to:
  /// **'Terminy dat: 7 dni wcześniej, dzień wcześniej i w dniu terminu. Android może opóźnić powiadomienie w trybie oszczędzania energii.'**
  String get notificationsExplain;

  /// No description provided for @languageSection.
  ///
  /// In pl, this message translates to:
  /// **'Język i waluta'**
  String get languageSection;

  /// No description provided for @languagePolish.
  ///
  /// In pl, this message translates to:
  /// **'Polski'**
  String get languagePolish;

  /// No description provided for @languageEnglish.
  ///
  /// In pl, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @currencyRateHint.
  ///
  /// In pl, this message translates to:
  /// **'Ile {currency} wypada za 1 zł. Kwoty w bazie zostają w złotych.'**
  String currencyRateHint(Object currency);

  /// No description provided for @currencyRateInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Podaj dodatni kurs, np. 0,24'**
  String get currencyRateInvalid;

  /// No description provided for @customCategoriesSection.
  ///
  /// In pl, this message translates to:
  /// **'Kategorie własne'**
  String get customCategoriesSection;

  /// No description provided for @addCategory.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj kategorię'**
  String get addCategory;

  /// No description provided for @addCategorySub.
  ///
  /// In pl, this message translates to:
  /// **'Dostępna w serwisach i wydatkach'**
  String get addCategorySub;

  /// No description provided for @newCategoryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowa kategoria'**
  String get newCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get categoryNameLabel;

  /// No description provided for @addAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj'**
  String get addAction;

  /// No description provided for @categoryAdded.
  ///
  /// In pl, this message translates to:
  /// **'Dodano kategorię {name}.'**
  String categoryAdded(Object name);

  /// No description provided for @exportImportSection.
  ///
  /// In pl, this message translates to:
  /// **'Eksport i import wybranego auta'**
  String get exportImportSection;

  /// No description provided for @addCarFirst.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw dodaj auto lub przywróć kopię.'**
  String get addCarFirst;

  /// No description provided for @exportCsv.
  ///
  /// In pl, this message translates to:
  /// **'Eksport CSV'**
  String get exportCsv;

  /// No description provided for @exportCsvSub.
  ///
  /// In pl, this message translates to:
  /// **'Historia, tankowania i wydatki'**
  String get exportCsvSub;

  /// No description provided for @importCsv.
  ///
  /// In pl, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @importCsvSub.
  ///
  /// In pl, this message translates to:
  /// **'Mapowanie kolumn i podgląd przed zapisem'**
  String get importCsvSub;

  /// No description provided for @pdfReportCosts.
  ///
  /// In pl, this message translates to:
  /// **'Kwoty w raporcie PDF'**
  String get pdfReportCosts;

  /// No description provided for @pdfReportPrivate.
  ///
  /// In pl, this message translates to:
  /// **'Dane prywatne w raporcie'**
  String get pdfReportPrivate;

  /// No description provided for @pdfReportPrivateSub.
  ///
  /// In pl, this message translates to:
  /// **'VIN, rejestracja, warsztaty, opisy i notatki'**
  String get pdfReportPrivateSub;

  /// No description provided for @historyReportPdf.
  ///
  /// In pl, this message translates to:
  /// **'Raport historii PDF'**
  String get historyReportPdf;

  /// No description provided for @historyReportPdfSub.
  ///
  /// In pl, this message translates to:
  /// **'Z podglądem przed zapisaniem pliku'**
  String get historyReportPdfSub;

  /// No description provided for @appFooter.
  ///
  /// In pl, this message translates to:
  /// **'PitStop 2.0 · Offline, zawsze po Twojej stronie.'**
  String get appFooter;

  /// No description provided for @csvFieldKind.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj (SERVICE, FUEL, CHARGE, EXPENSE, MILEAGE)'**
  String get csvFieldKind;

  /// No description provided for @csvFieldTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get csvFieldTitle;

  /// No description provided for @csvFieldDate.
  ///
  /// In pl, this message translates to:
  /// **'Data (RRRR-MM-DD)'**
  String get csvFieldDate;

  /// No description provided for @csvFieldMileage.
  ///
  /// In pl, this message translates to:
  /// **'Przebieg (km)'**
  String get csvFieldMileage;

  /// No description provided for @csvFieldAmount.
  ///
  /// In pl, this message translates to:
  /// **'Kwota (zł)'**
  String get csvFieldAmount;

  /// No description provided for @csvFieldCategory.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get csvFieldCategory;

  /// No description provided for @csvFieldQuantity.
  ///
  /// In pl, this message translates to:
  /// **'Litry / kWh'**
  String get csvFieldQuantity;

  /// No description provided for @csvFieldFuel.
  ///
  /// In pl, this message translates to:
  /// **'Paliwo'**
  String get csvFieldFuel;

  /// No description provided for @csvFieldFullTank.
  ///
  /// In pl, this message translates to:
  /// **'Pełny bak (true/false)'**
  String get csvFieldFullTank;

  /// No description provided for @csvFieldMissed.
  ///
  /// In pl, this message translates to:
  /// **'Pominięte tankowanie (true/false)'**
  String get csvFieldMissed;

  /// No description provided for @csvFieldPlace.
  ///
  /// In pl, this message translates to:
  /// **'Warsztat / miejsce'**
  String get csvFieldPlace;

  /// No description provided for @csvFieldNote.
  ///
  /// In pl, this message translates to:
  /// **'Opis'**
  String get csvFieldNote;

  /// No description provided for @csvImportIntro.
  ///
  /// In pl, this message translates to:
  /// **'Import do wybranego auta. Powtórny import identycznych wierszy zostanie pominięty. Błędne wiersze nie będą zapisane.'**
  String get csvImportIntro;

  /// No description provided for @chooseCsvFile.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz CSV'**
  String get chooseCsvFile;

  /// No description provided for @csvMapColumns.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{Dopasuj kolumny ({count} wiersz)} few{Dopasuj kolumny ({count} wiersze)} many{Dopasuj kolumny ({count} wierszy)} other{Dopasuj kolumny ({count} wierszy)}}'**
  String csvMapColumns(num count);

  /// No description provided for @csvSkipColumn.
  ///
  /// In pl, this message translates to:
  /// **'Pomiń / wartość domyślna'**
  String get csvSkipColumn;

  /// No description provided for @csvCheckPreview.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź i pokaż podgląd'**
  String get csvCheckPreview;

  /// No description provided for @csvPreviewSummary.
  ///
  /// In pl, this message translates to:
  /// **'{correct} poprawnych · {faulty} błędnych'**
  String csvPreviewSummary(Object correct, Object faulty);

  /// No description provided for @csvRowLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wiersz {line}: {title}'**
  String csvRowLabel(Object line, Object title);

  /// No description provided for @csvPreviewLimited.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd pokazuje pierwsze 200 wierszy. Walidacja obejmuje cały plik.'**
  String get csvPreviewLimited;

  /// No description provided for @csvChangeMapping.
  ///
  /// In pl, this message translates to:
  /// **'Zmień mapowanie'**
  String get csvChangeMapping;

  /// No description provided for @csvImportDone.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{Zaimportowano {count} wpis. Duplikaty pominięto.} few{Zaimportowano {count} wpisy. Duplikaty pominięto.} many{Zaimportowano {count} wpisów. Duplikaty pominięto.} other{Zaimportowano {count} wpisów. Duplikaty pominięto.}}'**
  String csvImportDone(num count);

  /// No description provided for @csvImporting.
  ///
  /// In pl, this message translates to:
  /// **'Importowanie…'**
  String get csvImporting;

  /// No description provided for @csvImportValidRows.
  ///
  /// In pl, this message translates to:
  /// **'Importuj poprawne wiersze'**
  String get csvImportValidRows;

  /// No description provided for @restoreConfirmAction.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć'**
  String get restoreConfirmAction;

  /// No description provided for @statsCostsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki kosztów'**
  String get statsCostsTitle;

  /// No description provided for @errorWithDetails.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String errorWithDetails(Object error);

  /// No description provided for @noDataTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych'**
  String get noDataTitle;

  /// No description provided for @statsEmptyBody.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wpisy serwisowe z kosztem,\naby zobaczyć statystyki.'**
  String get statsEmptyBody;

  /// No description provided for @statsTotalCost.
  ///
  /// In pl, this message translates to:
  /// **'Suma kosztów'**
  String get statsTotalCost;

  /// No description provided for @statsEntryCount.
  ///
  /// In pl, this message translates to:
  /// **'Liczba wpisów'**
  String get statsEntryCount;

  /// No description provided for @statsAverageCost.
  ///
  /// In pl, this message translates to:
  /// **'Śr. koszt/wpis'**
  String get statsAverageCost;

  /// No description provided for @statsLastService.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni serwis'**
  String get statsLastService;

  /// No description provided for @statsCostByType.
  ///
  /// In pl, this message translates to:
  /// **'Koszty wg typu serwisu'**
  String get statsCostByType;

  /// No description provided for @editServiceTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj serwis'**
  String get editServiceTooltip;

  /// No description provided for @deleteServiceTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń serwis'**
  String get deleteServiceTooltip;

  /// No description provided for @serviceItemsSection.
  ///
  /// In pl, this message translates to:
  /// **'Części i robocizna'**
  String get serviceItemsSection;

  /// No description provided for @mileageLabel.
  ///
  /// In pl, this message translates to:
  /// **'Przebieg'**
  String get mileageLabel;

  /// No description provided for @costLabel.
  ///
  /// In pl, this message translates to:
  /// **'Koszt'**
  String get costLabel;

  /// No description provided for @workshopLabel.
  ///
  /// In pl, this message translates to:
  /// **'Warsztat'**
  String get workshopLabel;

  /// No description provided for @descriptionSection.
  ///
  /// In pl, this message translates to:
  /// **'Opis'**
  String get descriptionSection;

  /// No description provided for @photosSection.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia'**
  String get photosSection;

  /// No description provided for @invoicesSection.
  ///
  /// In pl, this message translates to:
  /// **'Faktury'**
  String get invoicesSection;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wpis'**
  String get deleteEntryTitle;

  /// No description provided for @deleteServiceConfirmBody.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć ten wpis serwisowy?'**
  String get deleteServiceConfirmBody;

  /// No description provided for @tapToOpen.
  ///
  /// In pl, this message translates to:
  /// **'Dotknij, żeby otworzyć'**
  String get tapToOpen;

  /// No description provided for @imageUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Nie można wyświetlić zdjęcia. Plik jest niedostępny lub uszkodzony.'**
  String get imageUnavailable;

  /// No description provided for @invoiceFileMissing.
  ///
  /// In pl, this message translates to:
  /// **'Plik faktury nie istnieje.'**
  String get invoiceFileMissing;

  /// No description provided for @noPdfApp.
  ///
  /// In pl, this message translates to:
  /// **'Brak aplikacji do otwierania plików PDF.'**
  String get noPdfApp;

  /// No description provided for @invoiceAccessDenied.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępu do pliku faktury.'**
  String get invoiceAccessDenied;

  /// No description provided for @pdfOpenFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć pliku PDF.'**
  String get pdfOpenFailed;

  /// No description provided for @newServiceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy serwis'**
  String get newServiceTitle;

  /// No description provided for @editServiceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj serwis'**
  String get editServiceTitle;

  /// No description provided for @templateTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Wypełnij z szablonu'**
  String get templateTooltip;

  /// No description provided for @templateOilChange.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana oleju i filtrów'**
  String get templateOilChange;

  /// No description provided for @templateTires.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana opon'**
  String get templateTires;

  /// No description provided for @templateInspection.
  ///
  /// In pl, this message translates to:
  /// **'Przegląd techniczny'**
  String get templateInspection;

  /// No description provided for @useTemplateAction.
  ///
  /// In pl, this message translates to:
  /// **'Użyj szablonu lub poprzedniego serwisu'**
  String get useTemplateAction;

  /// No description provided for @serviceTitleField.
  ///
  /// In pl, this message translates to:
  /// **'Co zostało zrobione?'**
  String get serviceTitleField;

  /// No description provided for @categoryField.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get categoryField;

  /// No description provided for @serviceDateField.
  ///
  /// In pl, this message translates to:
  /// **'Data serwisu'**
  String get serviceDateField;

  /// No description provided for @mileageField.
  ///
  /// In pl, this message translates to:
  /// **'Przebieg (km)'**
  String get mileageField;

  /// No description provided for @costField.
  ///
  /// In pl, this message translates to:
  /// **'Łączny koszt ({currency}, opcjonalnie)'**
  String costField(Object currency);

  /// No description provided for @partsTotalLabel.
  ///
  /// In pl, this message translates to:
  /// **'Suma części i robocizny'**
  String get partsTotalLabel;

  /// No description provided for @partsSectionSub.
  ///
  /// In pl, this message translates to:
  /// **'Opcjonalne rozbicie łącznej kwoty'**
  String get partsSectionSub;

  /// No description provided for @itemKindPart.
  ///
  /// In pl, this message translates to:
  /// **'Część'**
  String get itemKindPart;

  /// No description provided for @itemKindLabour.
  ///
  /// In pl, this message translates to:
  /// **'Robocizna'**
  String get itemKindLabour;

  /// No description provided for @removeItemTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pozycję'**
  String get removeItemTooltip;

  /// No description provided for @itemNameField.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa pozycji'**
  String get itemNameField;

  /// No description provided for @itemCostField.
  ///
  /// In pl, this message translates to:
  /// **'Koszt pozycji ({currency})'**
  String itemCostField(Object currency);

  /// No description provided for @addItemAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pozycję'**
  String get addItemAction;

  /// No description provided for @workshopAndDescription.
  ///
  /// In pl, this message translates to:
  /// **'Warsztat i opis'**
  String get workshopAndDescription;

  /// No description provided for @descriptionField.
  ///
  /// In pl, this message translates to:
  /// **'Opis i notatki'**
  String get descriptionField;

  /// No description provided for @photosAndInvoices.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia i faktury'**
  String get photosAndInvoices;

  /// No description provided for @removeAttachmentTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń załącznik'**
  String get removeAttachmentTooltip;

  /// No description provided for @photoAction.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie'**
  String get photoAction;

  /// No description provided for @invoiceAction.
  ///
  /// In pl, this message translates to:
  /// **'Faktura (PDF lub zdjęcie)'**
  String get invoiceAction;

  /// No description provided for @savingLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie…'**
  String get savingLabel;

  /// No description provided for @saveServiceAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz serwis'**
  String get saveServiceAction;

  /// No description provided for @takePhotoAction.
  ///
  /// In pl, this message translates to:
  /// **'Zrób zdjęcie'**
  String get takePhotoAction;

  /// No description provided for @fromGalleryAction.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz z galerii'**
  String get fromGalleryAction;

  /// No description provided for @photoAddFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dodać zdjęcia. Sprawdź uprawnienia aparatu lub galerii.'**
  String get photoAddFailed;

  /// No description provided for @invoiceAddFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dodać faktury.'**
  String get invoiceAddFailed;

  /// No description provided for @serviceLoadFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać serwisu. Wróć i spróbuj ponownie.'**
  String get serviceLoadFailed;

  /// No description provided for @duplicateServiceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podobny serwis już istnieje'**
  String get duplicateServiceTitle;

  /// No description provided for @duplicateServiceBody.
  ///
  /// In pl, this message translates to:
  /// **'Ten sam tytuł, dzień i kwota. Zapisać kolejny wpis?'**
  String get duplicateServiceBody;

  /// No description provided for @goBackAction.
  ///
  /// In pl, this message translates to:
  /// **'Wróć'**
  String get goBackAction;

  /// No description provided for @saveAnotherAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz kolejny'**
  String get saveAnotherAction;

  /// No description provided for @serviceSaveFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać serwisu. Formularz i załączniki zostały zachowane.'**
  String get serviceSaveFailed;

  /// No description provided for @validationRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wymagane'**
  String get validationRequired;

  /// No description provided for @validationTitleRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz tytuł serwisu'**
  String get validationTitleRequired;

  /// No description provided for @validationMileageNonNegative.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nieujemny przebieg'**
  String get validationMileageNonNegative;

  /// No description provided for @validationAmount.
  ///
  /// In pl, this message translates to:
  /// **'Podaj kwotę, maks. 2 miejsca po przecinku'**
  String get validationAmount;

  /// No description provided for @validationAmountRequired.
  ///
  /// In pl, this message translates to:
  /// **'Podaj kwotę'**
  String get validationAmountRequired;

  /// No description provided for @validationMileageNumber.
  ///
  /// In pl, this message translates to:
  /// **'Podaj przebieg w kilometrach'**
  String get validationMileageNumber;

  /// No description provided for @categoryInsurance.
  ///
  /// In pl, this message translates to:
  /// **'Ubezpieczenie'**
  String get categoryInsurance;

  /// No description provided for @categoryParking.
  ///
  /// In pl, this message translates to:
  /// **'Parking'**
  String get categoryParking;

  /// No description provided for @categoryRoadTolls.
  ///
  /// In pl, this message translates to:
  /// **'Opłaty drogowe'**
  String get categoryRoadTolls;

  /// No description provided for @categoryCarWash.
  ///
  /// In pl, this message translates to:
  /// **'Myjnia'**
  String get categoryCarWash;

  /// No description provided for @categoryEnergy.
  ///
  /// In pl, this message translates to:
  /// **'Energia'**
  String get categoryEnergy;

  /// No description provided for @mileageReadingLabel.
  ///
  /// In pl, this message translates to:
  /// **'Odczyt przebiegu'**
  String get mileageReadingLabel;

  /// No description provided for @newEntryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy wpis'**
  String get newEntryTitle;

  /// No description provided for @amountField.
  ///
  /// In pl, this message translates to:
  /// **'Kwota ({currency})'**
  String amountField(Object currency);

  /// No description provided for @fuelFieldLabel.
  ///
  /// In pl, this message translates to:
  /// **'Paliwo'**
  String get fuelFieldLabel;

  /// No description provided for @quantityFuelField.
  ///
  /// In pl, this message translates to:
  /// **'Ilość paliwa (l)'**
  String get quantityFuelField;

  /// No description provided for @quantityEnergyField.
  ///
  /// In pl, this message translates to:
  /// **'Energia (kWh)'**
  String get quantityEnergyField;

  /// No description provided for @validationAmountPositive.
  ///
  /// In pl, this message translates to:
  /// **'Podaj dodatnią kwotę, maks. 2 miejsca po przecinku'**
  String get validationAmountPositive;

  /// No description provided for @validationQuantityPositive.
  ///
  /// In pl, this message translates to:
  /// **'Podaj ilość większą od zera'**
  String get validationQuantityPositive;

  /// No description provided for @dateFieldLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get dateFieldLabel;

  /// No description provided for @fullTankSwitch.
  ///
  /// In pl, this message translates to:
  /// **'Pełny bak'**
  String get fullTankSwitch;

  /// No description provided for @fullTankSwitchSub.
  ///
  /// In pl, this message translates to:
  /// **'Potrzebny do obliczania spalania'**
  String get fullTankSwitchSub;

  /// No description provided for @missedTankSwitch.
  ///
  /// In pl, this message translates to:
  /// **'Pominięto wcześniejsze tankowanie'**
  String get missedTankSwitch;

  /// No description provided for @missedTankSwitchSub.
  ///
  /// In pl, this message translates to:
  /// **'Przerwij obliczanie spalania na tym odcinku'**
  String get missedTankSwitchSub;

  /// No description provided for @detailsSection.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły (opcjonalnie)'**
  String get detailsSection;

  /// No description provided for @placeFuelField.
  ///
  /// In pl, this message translates to:
  /// **'Stacja lub miejsce'**
  String get placeFuelField;

  /// No description provided for @placeField.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce'**
  String get placeField;

  /// No description provided for @noteField.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get noteField;

  /// No description provided for @saveEntryAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz wpis'**
  String get saveEntryAction;

  /// No description provided for @entrySaveFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać wpisu. Dane formularza zostały zachowane.'**
  String get entrySaveFailed;

  /// No description provided for @duplicateEntryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podobny wpis już istnieje'**
  String get duplicateEntryTitle;

  /// No description provided for @duplicateEntryBody.
  ///
  /// In pl, this message translates to:
  /// **'Znaleziono taki sam tytuł, dzień i kwotę. Zapisać kolejny?'**
  String get duplicateEntryBody;

  /// Etykieta pola nazwy auta; przykładowa nazwa zostaje typowa dla języka
  ///
  /// In pl, this message translates to:
  /// **'Nazwa (np. Moje BMW)'**
  String get vehicleNameField;

  /// No description provided for @vehicleMakeField.
  ///
  /// In pl, this message translates to:
  /// **'Marka'**
  String get vehicleMakeField;

  /// No description provided for @vehicleModelField.
  ///
  /// In pl, this message translates to:
  /// **'Model'**
  String get vehicleModelField;

  /// No description provided for @vehicleYearField.
  ///
  /// In pl, this message translates to:
  /// **'Rok'**
  String get vehicleYearField;

  /// No description provided for @vehiclePlateField.
  ///
  /// In pl, this message translates to:
  /// **'Rejestracja'**
  String get vehiclePlateField;

  /// No description provided for @vehicleMileageField.
  ///
  /// In pl, this message translates to:
  /// **'Aktualny przebieg (km)'**
  String get vehicleMileageField;

  /// No description provided for @validationInvalidYear.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy rok'**
  String get validationInvalidYear;

  /// No description provided for @validationVinLength.
  ///
  /// In pl, this message translates to:
  /// **'VIN powinien mieć 17 znaków'**
  String get validationVinLength;

  /// No description provided for @powertrainField.
  ///
  /// In pl, this message translates to:
  /// **'Napęd'**
  String get powertrainField;

  /// No description provided for @powertrainPetrolLpg.
  ///
  /// In pl, this message translates to:
  /// **'Benzyna + LPG'**
  String get powertrainPetrolLpg;

  /// No description provided for @powertrainHybrid.
  ///
  /// In pl, this message translates to:
  /// **'Hybryda'**
  String get powertrainHybrid;

  /// No description provided for @powertrainPlugInHybrid.
  ///
  /// In pl, this message translates to:
  /// **'Hybryda plug-in'**
  String get powertrainPlugInHybrid;

  /// No description provided for @vehicleTechSection.
  ///
  /// In pl, this message translates to:
  /// **'Dane techniczne i zakup'**
  String get vehicleTechSection;

  /// No description provided for @techDataSection.
  ///
  /// In pl, this message translates to:
  /// **'Dane techniczne'**
  String get techDataSection;

  /// No description provided for @technicalNotesField.
  ///
  /// In pl, this message translates to:
  /// **'Notatki techniczne'**
  String get technicalNotesField;

  /// No description provided for @purchaseDateField.
  ///
  /// In pl, this message translates to:
  /// **'Data zakupu'**
  String get purchaseDateField;

  /// No description provided for @notSetLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nie ustawiono'**
  String get notSetLabel;

  /// No description provided for @saveChangesAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get saveChangesAction;

  /// No description provided for @newCarTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowe auto'**
  String get newCarTitle;

  /// No description provided for @editCarTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj auto'**
  String get editCarTitle;

  /// No description provided for @editCarTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj auto'**
  String get editCarTooltip;

  /// No description provided for @deleteCarAction.
  ///
  /// In pl, this message translates to:
  /// **'Usuń auto'**
  String get deleteCarAction;

  /// No description provided for @deleteCarBody.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć „{name}”? Wszystkie wpisy serwisowe zostaną usunięte.'**
  String deleteCarBody(Object name);

  /// No description provided for @vehicleSaveFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać auta. Spróbuj ponownie.'**
  String get vehicleSaveFailed;

  /// No description provided for @addPhotoDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie'**
  String get addPhotoDialogTitle;

  /// No description provided for @addCarPhotoHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie auta'**
  String get addCarPhotoHint;

  /// No description provided for @cameraSource.
  ///
  /// In pl, this message translates to:
  /// **'Aparat'**
  String get cameraSource;

  /// No description provided for @gallerySource.
  ///
  /// In pl, this message translates to:
  /// **'Galeria'**
  String get gallerySource;

  /// No description provided for @emptyVehiclesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak aut'**
  String get emptyVehiclesTitle;

  /// No description provided for @emptyVehiclesBody.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj swoje pierwsze auto, żeby śledzić serwisy'**
  String get emptyVehiclesBody;

  /// No description provided for @remindersSectionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia'**
  String get remindersSectionTitle;

  /// No description provided for @serviceHistoryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Historia serwisów'**
  String get serviceHistoryTitle;

  /// No description provided for @noServiceRecordsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak wpisów serwisowych'**
  String get noServiceRecordsTitle;

  /// No description provided for @noServiceRecordsBody.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy wpis używając przycisku poniżej'**
  String get noServiceRecordsBody;

  /// No description provided for @serviceCostsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Koszty serwisów'**
  String get serviceCostsTitle;

  /// Liczebnik wpisów bez kwoty, do stopki karty kosztów
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{{count} wpis} few{{count} wpisy} many{{count} wpisów} other{{count} wpisów}}'**
  String entriesCountShort(num count);

  /// No description provided for @lastServiceShortLabel.
  ///
  /// In pl, this message translates to:
  /// **'ostatni: {date}'**
  String lastServiceShortLabel(Object date);

  /// No description provided for @kmRemainingLabel.
  ///
  /// In pl, this message translates to:
  /// **'za {km} km'**
  String kmRemainingLabel(Object km);

  /// No description provided for @overdueAtMileageLabel.
  ///
  /// In pl, this message translates to:
  /// **'po terminie ({km} km)'**
  String overdueAtMileageLabel(Object km);

  /// No description provided for @newReminderTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy termin'**
  String get newReminderTitle;

  /// No description provided for @editReminderTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj termin'**
  String get editReminderTitle;

  /// No description provided for @reminderPresetInspection.
  ///
  /// In pl, this message translates to:
  /// **'Badanie techniczne'**
  String get reminderPresetInspection;

  /// No description provided for @reminderPresetOc.
  ///
  /// In pl, this message translates to:
  /// **'Ubezpieczenie OC'**
  String get reminderPresetOc;

  /// No description provided for @reminderPresetAc.
  ///
  /// In pl, this message translates to:
  /// **'Ubezpieczenie AC'**
  String get reminderPresetAc;

  /// No description provided for @reminderPresetTires.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana opon'**
  String get reminderPresetTires;

  /// No description provided for @reminderTitleField.
  ///
  /// In pl, this message translates to:
  /// **'O czym przypomnieć?'**
  String get reminderTitleField;

  /// No description provided for @selectDateAction.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz termin'**
  String get selectDateAction;

  /// No description provided for @removeDateTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Usuń datę'**
  String get removeDateTooltip;

  /// No description provided for @targetMileageField.
  ///
  /// In pl, this message translates to:
  /// **'Przebieg docelowy (km)'**
  String get targetMileageField;

  /// No description provided for @reminderConditionsHint.
  ///
  /// In pl, this message translates to:
  /// **'Gdy ustawisz oba warunki, obowiązuje wcześniejszy. Przebieg jest sprawdzany po zapisaniu nowego odczytu.'**
  String get reminderConditionsHint;

  /// No description provided for @repeatSection.
  ///
  /// In pl, this message translates to:
  /// **'Powtarzanie'**
  String get repeatSection;

  /// No description provided for @repeatSectionSub.
  ///
  /// In pl, this message translates to:
  /// **'Nowy termin po oznaczeniu jako wykonane'**
  String get repeatSectionSub;

  /// No description provided for @everyMonthsField.
  ///
  /// In pl, this message translates to:
  /// **'Co ile miesięcy?'**
  String get everyMonthsField;

  /// No description provided for @everyKmField.
  ///
  /// In pl, this message translates to:
  /// **'Co ile kilometrów?'**
  String get everyKmField;

  /// No description provided for @noteOptionalField.
  ///
  /// In pl, this message translates to:
  /// **'Notatka (opcjonalnie)'**
  String get noteOptionalField;

  /// No description provided for @saveReminderAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz termin'**
  String get saveReminderAction;

  /// No description provided for @reminderNeedsDateOrMileage.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw datę lub przebieg docelowy.'**
  String get reminderNeedsDateOrMileage;

  /// No description provided for @reminderSaveFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać terminu. Spróbuj ponownie.'**
  String get reminderSaveFailed;

  /// No description provided for @validationPositiveNumber.
  ///
  /// In pl, this message translates to:
  /// **'Podaj dodatnią liczbę'**
  String get validationPositiveNumber;

  /// No description provided for @validationPositiveNumberUpTo.
  ///
  /// In pl, this message translates to:
  /// **'Podaj dodatnią liczbę do {max}'**
  String validationPositiveNumberUpTo(Object max);

  /// No description provided for @validationNonNegativeNumber.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nieujemną liczbę'**
  String get validationNonNegativeNumber;

  /// No description provided for @errorBackupTooLarge.
  ///
  /// In pl, this message translates to:
  /// **'Kopia przekracza 200 MB.'**
  String get errorBackupTooLarge;

  /// No description provided for @errorArchiveBroken.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowa zawartość archiwum.'**
  String get errorArchiveBroken;

  /// No description provided for @errorUnpackedTooLarge.
  ///
  /// In pl, this message translates to:
  /// **'Rozpakowana kopia przekracza 500 MB.'**
  String get errorUnpackedTooLarge;

  /// No description provided for @errorArchiveVersion.
  ///
  /// In pl, this message translates to:
  /// **'Nieobsługiwana wersja kopii.'**
  String get errorArchiveVersion;

  /// No description provided for @errorArchiveIncomplete.
  ///
  /// In pl, this message translates to:
  /// **'Niepełna kopia.'**
  String get errorArchiveIncomplete;

  /// No description provided for @errorArchiveCorrupted.
  ///
  /// In pl, this message translates to:
  /// **'Kopia jest uszkodzona.'**
  String get errorArchiveCorrupted;

  /// No description provided for @errorArchiveDataset.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy zestaw danych.'**
  String get errorArchiveDataset;

  /// No description provided for @errorArchiveColumns.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowe kolumny.'**
  String get errorArchiveColumns;

  /// No description provided for @errorMissingBackupFile.
  ///
  /// In pl, this message translates to:
  /// **'Brakuje pliku w kopii.'**
  String get errorMissingBackupFile;

  /// No description provided for @errorMissingDraftFile.
  ///
  /// In pl, this message translates to:
  /// **'Brakuje pliku szkicu.'**
  String get errorMissingDraftFile;

  /// No description provided for @errorArchiveRelations.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowe powiązania.'**
  String get errorArchiveRelations;

  /// No description provided for @errorAttachmentMissing.
  ///
  /// In pl, this message translates to:
  /// **'Brakuje załącznika. Przywróć plik lub usuń brakujący załącznik przed wykonaniem pełnej kopii.'**
  String get errorAttachmentMissing;

  /// No description provided for @errorCsvUnclosedQuote.
  ///
  /// In pl, this message translates to:
  /// **'Niezamknięty cudzysłów w pliku CSV.'**
  String get errorCsvUnclosedQuote;

  /// No description provided for @errorCsvNoHeader.
  ///
  /// In pl, this message translates to:
  /// **'Brak nagłówka lub powtórzone nazwy kolumn.'**
  String get errorCsvNoHeader;

  /// No description provided for @csvErrorKind.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany rodzaj wpisu'**
  String get csvErrorKind;

  /// No description provided for @csvErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak tytułu'**
  String get csvErrorTitle;

  /// Format daty w pliku CSV jest zawsze ISO, bez względu na język
  ///
  /// In pl, this message translates to:
  /// **'Data: wymagany format RRRR-MM-DD'**
  String get csvErrorDate;

  /// No description provided for @csvErrorAmount.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowa kwota'**
  String get csvErrorAmount;

  /// No description provided for @csvErrorMileage.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy przebieg'**
  String get csvErrorMileage;

  /// No description provided for @csvErrorMileageRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wymagany przebieg'**
  String get csvErrorMileageRequired;

  /// No description provided for @csvErrorQuantity.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowa ilość'**
  String get csvErrorQuantity;

  /// W pliku zostają wartości słownikowe, więc nazwy paliw nie są tłumaczone
  ///
  /// In pl, this message translates to:
  /// **'Paliwo: Benzyna, Diesel lub LPG'**
  String get csvErrorFuel;

  /// No description provided for @csvErrorBoolean.
  ///
  /// In pl, this message translates to:
  /// **'Wartość logiczna: true lub false'**
  String get csvErrorBoolean;

  /// No description provided for @draftSaveTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zachować szkic?'**
  String get draftSaveTitle;

  /// No description provided for @draftSaveBody.
  ///
  /// In pl, this message translates to:
  /// **'Możesz wrócić do formularza i dokończyć wpis później.'**
  String get draftSaveBody;

  /// No description provided for @draftStayAction.
  ///
  /// In pl, this message translates to:
  /// **'Zostań'**
  String get draftStayAction;

  /// No description provided for @draftDiscardAction.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get draftDiscardAction;

  /// No description provided for @draftSaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz szkic'**
  String get draftSaveAction;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
