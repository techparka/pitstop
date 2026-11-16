import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTagline => 'Wszystko o Twoim aucie';

  @override
  String get backupErrorDatabaseOpen => 'Nie udało się otworzyć bazy danych.';

  @override
  String get backupErrorAutomaticFailed => 'Automatyczna kopia nie powstała. Sprawdź dostępne miejsce i brakujące załączniki.';

  @override
  String get languageSetting => 'Język';

  @override
  String get languageSystem => 'Zgodnie z systemem';

  @override
  String get currencySetting => 'Waluta';

  @override
  String get currencyRateSetting => 'Kurs 1 zł';

  @override
  String get navDashboard => 'Pulpit';

  @override
  String get navHistory => 'Historia';

  @override
  String get navReminders => 'Terminy';

  @override
  String get navGarage => 'Garaż';

  @override
  String get errorOperationFailed => 'Operacja nie powiodła się. Dane pozostają bez zmian. Sprawdź plik i dostępne miejsce.';

  @override
  String get errorPdfAndroidOnly => 'Eksport PDF jest dostępny w wersji Android.';

  @override
  String get errorCsvUnreadable => 'Nie udało się odczytać CSV. Użyj kodowania UTF-8 oraz separatora ; lub ,';

  @override
  String get errorCsvImportFailed => 'Import nie powiódł się. Nie dodano żadnych wierszy.';

  @override
  String get errorRestoreFailed => 'Nie udało się przywrócić kopii. Sprawdź plik i dostępne miejsce.';

  @override
  String get notifDueToday => 'Termin dzisiaj';

  @override
  String get notifDueOverdue => 'Termin minął — sprawdź szczegóły';

  @override
  String notifDueInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Termin za $days dni',
      one: 'Termin za 1 dzień',
    );
    return '$_temp0';
  }

  @override
  String notifMileageReached(Object mileage) {
    return 'Osiągnięto przebieg $mileage km';
  }

  @override
  String notifMileageRemaining(Object remaining) {
    return 'Pozostało $remaining km według ostatniego odczytu';
  }

  @override
  String get categoryFuel => 'Paliwo';

  @override
  String get categoryService => 'Serwis';

  @override
  String get categoryRepair => 'Naprawa';

  @override
  String get categoryAccessory => 'Wyposażenie';

  @override
  String get categoryAdministrative => 'Opłaty';

  @override
  String get serviceTypeOilChange => 'Wymiana oleju';

  @override
  String get serviceTypeBrakes => 'Hamulce';

  @override
  String get serviceTypeFilters => 'Filtry';

  @override
  String get serviceTypeTiming => 'Rozrząd';

  @override
  String get serviceTypeBattery => 'Akumulator';

  @override
  String get serviceTypeFluids => 'Płyny';

  @override
  String get serviceTypeAirConditioning => 'Klimatyzacja';

  @override
  String get serviceTypeSuspension => 'Zawieszenie';

  @override
  String get serviceTypeRepair => 'Naprawa';

  @override
  String get serviceTypeInspection => 'Przegląd';

  @override
  String get serviceTypeTires => 'Opony';

  @override
  String get serviceTypeOther => 'Inne';

  @override
  String get powertrainPetrol => 'Benzyna';

  @override
  String get powertrainDiesel => 'Diesel';

  @override
  String get powertrainLpg => 'LPG';

  @override
  String get powertrainHybridPetrol => 'Hybryda (benzyna)';

  @override
  String get powertrainHybridDiesel => 'Hybryda (diesel)';

  @override
  String get powertrainElectric => 'Elektryczny';

  @override
  String get unitKm => 'km';

  @override
  String get unitL => 'l';

  @override
  String get unitKmPerL => 'km/l';

  @override
  String get unitLPer100km => 'l/100 km';

  @override
  String get loadFailed => 'Nie udało się odczytać danych.';

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get titleGarageTab => 'Twój garaż';

  @override
  String get settingsTooltip => 'Ustawienia i kopie danych';

  @override
  String get addCarAction => 'Dodaj auto';

  @override
  String get addEntryAction => 'Dodaj wpis';

  @override
  String get emptyGarageTitle => 'Dobra historia zaczyna się tutaj';

  @override
  String get emptyGarageBody => 'Dodaj auto. Serwisy, koszty i ważne terminy będą zawsze pod ręką — również bez internetu.';

  @override
  String get addFirstCar => 'Dodaj pierwsze auto';

  @override
  String get haveBackup => 'Mam kopię danych';

  @override
  String get yourCarBadge => 'TWOJE AUTO';

  @override
  String get carProfileTooltip => 'Profil i edycja auta';

  @override
  String get lastKnownMileage => 'Ostatni znany przebieg';

  @override
  String get metricMonthExpenses => 'Wydatki w tym miesiącu';

  @override
  String get metricActiveReminders => 'Aktywne terminy';

  @override
  String get analyticsCardTitle => 'Zobacz, ile kosztuje Twoje auto';

  @override
  String get analyticsCardSubtitle => 'Koszty, trendy i zużycie paliwa';

  @override
  String get backupCardTitle => 'Zabezpiecz historię auta';

  @override
  String get backupCardSubtitle => 'Zapisz pełną kopię poza telefonem.';

  @override
  String get sectionUpcoming => 'Najbliższe terminy';

  @override
  String get actionAll => 'Wszystkie';

  @override
  String get hintCalmTitle => 'Spokojna głowa';

  @override
  String get hintCalmBody => 'Dodaj badanie techniczne, polisę lub następny serwis.';

  @override
  String get sectionRecentActivity => 'Ostatnia aktywność';

  @override
  String get hintFirstEntryTitle => 'Pierwszy wpis przed Tobą';

  @override
  String get hintFirstEntryBody => 'Zapisz serwis, tankowanie lub inny wydatek.';

  @override
  String get privacyNote => 'Twoje dane. Tylko na Twoim urządzeniu.';

  @override
  String get searchEntriesHint => 'Szukaj wpisu, opisu, warsztatu…';

  @override
  String get filterAll => 'Wszystko';

  @override
  String get filterServices => 'Serwisy';

  @override
  String get filterCharges => 'Ładowania';

  @override
  String get filterExpenses => 'Wydatki';

  @override
  String get filterMileage => 'Przebieg';

  @override
  String get filterAnyCategory => 'Każda kategoria';

  @override
  String get filterDatesTooltip => 'Filtruj daty';

  @override
  String get removeDateRangeTooltip => 'Usuń zakres dat';

  @override
  String entriesSummary(num count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wpisów · $total',
      many: '$count wpisów · $total',
      few: '$count wpisy · $total',
      one: '$count wpis · $total',
    );
    return '$_temp0';
  }

  @override
  String get noMatchingEntries => 'Brak pasujących wpisów';

  @override
  String get termsRuleTitle => 'Najpierw data lub przebieg';

  @override
  String get termsRuleBody => 'Obowiązuje wcześniejszy warunek. Przebiegowe terminy korzystają z ostatniego wpisanego odczytu.';

  @override
  String get notificationsConsentHint => 'Zgodę na powiadomienia możesz też zmienić w ustawieniach telefonu.';

  @override
  String get enableNotifications => 'Włącz powiadomienia';

  @override
  String get noActiveRemindersTitle => 'Brak aktywnych terminów';

  @override
  String get noActiveRemindersBody => 'Dodaj przypomnienie przyciskiem poniżej.';

  @override
  String doneRemindersSection(Object count) {
    return 'Wykonane ($count)';
  }

  @override
  String get editAction => 'Edytuj';

  @override
  String get deleteAction => 'Usuń';

  @override
  String get cancelAction => 'Anuluj';

  @override
  String get deleteReminderTitle => 'Usunąć termin?';

  @override
  String get markDoneTitle => 'Oznacz jako wykonane';

  @override
  String get markDoneBody => 'Czy zapisać również wpis w historii serwisów?';

  @override
  String get markDoneOnly => 'Tylko wykonaj';

  @override
  String get addServiceAction => 'Dodaj serwis';

  @override
  String get reminderDoneAction => 'Wykonane';

  @override
  String get reminderOptionsTooltip => 'Opcje przypomnienia';

  @override
  String get urgencyAttention => 'Wymaga uwagi';

  @override
  String get urgencySoon => 'Już niedługo';

  @override
  String get urgencyPlanned => 'Zaplanowane';

  @override
  String kmRemaining(Object remaining) {
    return '$remaining km pozostało';
  }

  @override
  String repeatLabel(Object rules) {
    return 'Powtarzaj: $rules';
  }

  @override
  String repeatEveryMonths(num months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'co $months miesięcy',
      many: 'co $months miesięcy',
      few: 'co $months miesiące',
      one: 'co $months miesiąc',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryKm(Object km) {
    return 'co $km';
  }

  @override
  String get repeatOr => 'lub';

  @override
  String get garageTabTitle => 'Każde auto ma swoją historię';

  @override
  String get addSheetTitle => 'Co chcesz zapisać?';

  @override
  String get addServiceEntry => 'Serwis';

  @override
  String get addRefuel => 'Tankowanie';

  @override
  String get addCharge => 'Ładowanie';

  @override
  String get addExpense => 'Wydatek';

  @override
  String get addReminder => 'Przypomnienie';

  @override
  String get analyticsTitle => 'Koszty i zużycie';

  @override
  String get statsLoadFailed => 'Nie udało się odczytać statystyk';

  @override
  String get periodAll => 'Cała historia';

  @override
  String get periodMonth => 'Ten miesiąc';

  @override
  String get periodYear => 'Ten rok';

  @override
  String get periodCustom => 'Własny okres';

  @override
  String amountsInCurrency(Object currency) {
    return 'Wszystkie kwoty w $currency. Każdy koszt liczony tylko raz.';
  }

  @override
  String get metricTotalExpenses => 'Łączne wydatki';

  @override
  String get metricCostedEntries => 'Wpisy z kosztem';

  @override
  String get metricCostPerKm => 'Koszt kilometra';

  @override
  String costPerKmRange(Object from, Object km, Object to) {
    return 'Koszt/km: $from – $to, $km. Koszty poza tym odcinkiem nie wchodzą do wskaźnika.';
  }

  @override
  String get costPerKmNeedsReadings => 'Koszt/km wymaga dwóch odczytów przebiegu z różnymi wartościami w wybranym okresie.';

  @override
  String get fuelConsumptionTitle => 'Zużycie paliwa';

  @override
  String get fuelNeedsMoreData => 'Za mało danych. Dodaj co najmniej dwa pełne tankowania tego samego paliwa. Częściowe tankowania są sumowane, a pominięte przerywają odcinek.';

  @override
  String fuelCalculatedOver(Object fuel, Object km) {
    return '$fuel · obliczono dla $km';
  }

  @override
  String get fuelSplitNote => 'Benzyna i LPG są liczone osobno. Przy jeździe na dwóch paliwach wyniki opisują udział każdego paliwa, nie samodzielne spalanie silnika.';

  @override
  String get expensesByCategory => 'Wydatki według kategorii';

  @override
  String get monthByMonth => 'Miesiąc po miesiącu';

  @override
  String get addFirstEntryForStats => 'Dodaj pierwszy wpis, aby zobaczyć statystyki.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get restoreDialogTitle => 'Przywrócić kopię?';

  @override
  String restoreVehiclesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aut',
      many: '$count aut',
      few: '$count auta',
      one: '$count auto',
    );
    return '$_temp0';
  }

  @override
  String restoreEntriesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wpisów',
      many: '$count wpisów',
      few: '$count wpisy',
      one: '$count wpis',
    );
    return '$_temp0';
  }

  @override
  String restoreCreatedAt(Object created) {
    return 'Kopia z $created';
  }

  @override
  String get restoreDialogWarning => 'Zastąpi aktualne dane. Najpierw zapiszemy kopię bezpieczeństwa obecnego stanu.';

  @override
  String get restoreDone => 'Przywrócono dane i załączniki. Poprzedni stan jest w kopiach lokalnych.';

  @override
  String reportGeneratedOn(Object date) {
    return 'Wygenerowano $date';
  }

  @override
  String reportVin(Object vin) {
    return 'VIN: $vin';
  }

  @override
  String reportRegistration(Object plate) {
    return 'Rejestracja: $plate';
  }

  @override
  String get reportServiceItems => 'Pozycje serwisowe (zawarte w kwotach serwisów):';

  @override
  String get reportPreviewTitle => 'Podgląd raportu';

  @override
  String get createPdfAction => 'Utwórz PDF';

  @override
  String get yourDataHeader => 'TWOJE DANE';

  @override
  String get privacyBadge => 'Bez konta. Bez reklam. Bez opłat.';

  @override
  String get privacyBody => 'Wszystko działa na urządzeniu. Kopia lokalna nie ochroni danych po utracie telefonu — regularnie zapisz ZIP poza nim.';

  @override
  String get saveFullBackup => 'Zapisz pełną kopię ZIP';

  @override
  String get saveFullBackupSub => 'Dane, ustawienia, zdjęcia i dokumenty';

  @override
  String get backupSaved => 'Kopia zapisana w wybranym miejscu. Regularnie przechowuj ją także poza telefonem.';

  @override
  String get backupSaveCancelled => 'Anulowano zapis zewnętrzny. Kopia jest dostępna w kopiach lokalnych.';

  @override
  String get restoreFromFile => 'Przywróć z pliku ZIP';

  @override
  String get restoreFromFileSub => 'Najpierw sprawdzimy integralność kopii';

  @override
  String get localBackups => 'Kopie lokalne';

  @override
  String get localBackupsSub => '5 ostatnich automatycznych + kopie ręczne';

  @override
  String get chooseBackup => 'Wybierz kopię do przywrócenia';

  @override
  String get noBackups => 'Brak kopii';

  @override
  String get appearanceSection => 'Wygląd i powiadomienia';

  @override
  String get themeSetting => 'Motyw';

  @override
  String get themeSystem => 'Zgodnie z systemem';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get notificationsOn => 'Powiadomienia włączone';

  @override
  String get notificationsOff => 'Powiadomienia wyłączone';

  @override
  String get notificationsExplain => 'Terminy dat: 7 dni wcześniej, dzień wcześniej i w dniu terminu. Android może opóźnić powiadomienie w trybie oszczędzania energii.';

  @override
  String get languageSection => 'Język i waluta';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageEnglish => 'English';

  @override
  String currencyRateHint(Object currency) {
    return 'Ile $currency wypada za 1 zł. Kwoty w bazie zostają w złotych.';
  }

  @override
  String get currencyRateInvalid => 'Podaj dodatni kurs, np. 0,24';

  @override
  String get customCategoriesSection => 'Kategorie własne';

  @override
  String get addCategory => 'Dodaj kategorię';

  @override
  String get addCategorySub => 'Dostępna w serwisach i wydatkach';

  @override
  String get newCategoryTitle => 'Nowa kategoria';

  @override
  String get categoryNameLabel => 'Nazwa';

  @override
  String get addAction => 'Dodaj';

  @override
  String categoryAdded(Object name) {
    return 'Dodano kategorię $name.';
  }

  @override
  String get exportImportSection => 'Eksport i import wybranego auta';

  @override
  String get addCarFirst => 'Najpierw dodaj auto lub przywróć kopię.';

  @override
  String get exportCsv => 'Eksport CSV';

  @override
  String get exportCsvSub => 'Historia, tankowania i wydatki';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importCsvSub => 'Mapowanie kolumn i podgląd przed zapisem';

  @override
  String get pdfReportCosts => 'Kwoty w raporcie PDF';

  @override
  String get pdfReportPrivate => 'Dane prywatne w raporcie';

  @override
  String get pdfReportPrivateSub => 'VIN, rejestracja, warsztaty, opisy i notatki';

  @override
  String get historyReportPdf => 'Raport historii PDF';

  @override
  String get historyReportPdfSub => 'Z podglądem przed zapisaniem pliku';

  @override
  String get appFooter => 'PitStop 2.0 · Offline, zawsze po Twojej stronie.';

  @override
  String get csvFieldKind => 'Rodzaj (SERVICE, FUEL, CHARGE, EXPENSE, MILEAGE)';

  @override
  String get csvFieldTitle => 'Tytuł';

  @override
  String get csvFieldDate => 'Data (RRRR-MM-DD)';

  @override
  String get csvFieldMileage => 'Przebieg (km)';

  @override
  String get csvFieldAmount => 'Kwota (zł)';

  @override
  String get csvFieldCategory => 'Kategoria';

  @override
  String get csvFieldQuantity => 'Litry / kWh';

  @override
  String get csvFieldFuel => 'Paliwo';

  @override
  String get csvFieldFullTank => 'Pełny bak (true/false)';

  @override
  String get csvFieldMissed => 'Pominięte tankowanie (true/false)';

  @override
  String get csvFieldPlace => 'Warsztat / miejsce';

  @override
  String get csvFieldNote => 'Opis';

  @override
  String get csvImportIntro => 'Import do wybranego auta. Powtórny import identycznych wierszy zostanie pominięty. Błędne wiersze nie będą zapisane.';

  @override
  String get chooseCsvFile => 'Wybierz CSV';

  @override
  String csvMapColumns(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dopasuj kolumny ($count wierszy)',
      many: 'Dopasuj kolumny ($count wierszy)',
      few: 'Dopasuj kolumny ($count wiersze)',
      one: 'Dopasuj kolumny ($count wiersz)',
    );
    return '$_temp0';
  }

  @override
  String get csvSkipColumn => 'Pomiń / wartość domyślna';

  @override
  String get csvCheckPreview => 'Sprawdź i pokaż podgląd';

  @override
  String csvPreviewSummary(Object correct, Object faulty) {
    return '$correct poprawnych · $faulty błędnych';
  }

  @override
  String csvRowLabel(Object line, Object title) {
    return 'Wiersz $line: $title';
  }

  @override
  String get csvPreviewLimited => 'Podgląd pokazuje pierwsze 200 wierszy. Walidacja obejmuje cały plik.';

  @override
  String get csvChangeMapping => 'Zmień mapowanie';

  @override
  String csvImportDone(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zaimportowano $count wpisów. Duplikaty pominięto.',
      many: 'Zaimportowano $count wpisów. Duplikaty pominięto.',
      few: 'Zaimportowano $count wpisy. Duplikaty pominięto.',
      one: 'Zaimportowano $count wpis. Duplikaty pominięto.',
    );
    return '$_temp0';
  }

  @override
  String get csvImporting => 'Importowanie…';

  @override
  String get csvImportValidRows => 'Importuj poprawne wiersze';

  @override
  String get restoreConfirmAction => 'Przywróć';

  @override
  String get statsCostsTitle => 'Statystyki kosztów';

  @override
  String errorWithDetails(Object error) {
    return 'Błąd: $error';
  }

  @override
  String get noDataTitle => 'Brak danych';

  @override
  String get statsEmptyBody => 'Dodaj wpisy serwisowe z kosztem,\naby zobaczyć statystyki.';

  @override
  String get statsTotalCost => 'Suma kosztów';

  @override
  String get statsEntryCount => 'Liczba wpisów';

  @override
  String get statsAverageCost => 'Śr. koszt/wpis';

  @override
  String get statsLastService => 'Ostatni serwis';

  @override
  String get statsCostByType => 'Koszty wg typu serwisu';

  @override
  String get editServiceTooltip => 'Edytuj serwis';

  @override
  String get deleteServiceTooltip => 'Usuń serwis';

  @override
  String get serviceItemsSection => 'Części i robocizna';

  @override
  String get mileageLabel => 'Przebieg';

  @override
  String get costLabel => 'Koszt';

  @override
  String get workshopLabel => 'Warsztat';

  @override
  String get descriptionSection => 'Opis';

  @override
  String get photosSection => 'Zdjęcia';

  @override
  String get invoicesSection => 'Faktury';

  @override
  String get deleteEntryTitle => 'Usuń wpis';

  @override
  String get deleteServiceConfirmBody => 'Czy na pewno chcesz usunąć ten wpis serwisowy?';

  @override
  String get tapToOpen => 'Dotknij, żeby otworzyć';

  @override
  String get imageUnavailable => 'Nie można wyświetlić zdjęcia. Plik jest niedostępny lub uszkodzony.';

  @override
  String get invoiceFileMissing => 'Plik faktury nie istnieje.';

  @override
  String get noPdfApp => 'Brak aplikacji do otwierania plików PDF.';

  @override
  String get invoiceAccessDenied => 'Brak dostępu do pliku faktury.';

  @override
  String get pdfOpenFailed => 'Nie udało się otworzyć pliku PDF.';

  @override
  String get newServiceTitle => 'Nowy serwis';

  @override
  String get editServiceTitle => 'Edytuj serwis';

  @override
  String get templateTooltip => 'Wypełnij z szablonu';

  @override
  String get templateOilChange => 'Wymiana oleju i filtrów';

  @override
  String get templateTires => 'Wymiana opon';

  @override
  String get templateInspection => 'Przegląd techniczny';

  @override
  String get useTemplateAction => 'Użyj szablonu lub poprzedniego serwisu';

  @override
  String get serviceTitleField => 'Co zostało zrobione?';

  @override
  String get categoryField => 'Kategoria';

  @override
  String get serviceDateField => 'Data serwisu';

  @override
  String get mileageField => 'Przebieg (km)';

  @override
  String costField(Object currency) {
    return 'Łączny koszt ($currency, opcjonalnie)';
  }

  @override
  String get partsTotalLabel => 'Suma części i robocizny';

  @override
  String get partsSectionSub => 'Opcjonalne rozbicie łącznej kwoty';

  @override
  String get itemKindPart => 'Część';

  @override
  String get itemKindLabour => 'Robocizna';

  @override
  String get removeItemTooltip => 'Usuń pozycję';

  @override
  String get itemNameField => 'Nazwa pozycji';

  @override
  String itemCostField(Object currency) {
    return 'Koszt pozycji ($currency)';
  }

  @override
  String get addItemAction => 'Dodaj pozycję';

  @override
  String get workshopAndDescription => 'Warsztat i opis';

  @override
  String get descriptionField => 'Opis i notatki';

  @override
  String get photosAndInvoices => 'Zdjęcia i faktury';

  @override
  String get removeAttachmentTooltip => 'Usuń załącznik';

  @override
  String get photoAction => 'Zdjęcie';

  @override
  String get invoiceAction => 'Faktura (PDF lub zdjęcie)';

  @override
  String get savingLabel => 'Zapisywanie…';

  @override
  String get saveServiceAction => 'Zapisz serwis';

  @override
  String get takePhotoAction => 'Zrób zdjęcie';

  @override
  String get fromGalleryAction => 'Wybierz z galerii';

  @override
  String get photoAddFailed => 'Nie udało się dodać zdjęcia. Sprawdź uprawnienia aparatu lub galerii.';

  @override
  String get invoiceAddFailed => 'Nie udało się dodać faktury.';

  @override
  String get serviceLoadFailed => 'Nie udało się wczytać serwisu. Wróć i spróbuj ponownie.';

  @override
  String get duplicateServiceTitle => 'Podobny serwis już istnieje';

  @override
  String get duplicateServiceBody => 'Ten sam tytuł, dzień i kwota. Zapisać kolejny wpis?';

  @override
  String get goBackAction => 'Wróć';

  @override
  String get saveAnotherAction => 'Zapisz kolejny';

  @override
  String get serviceSaveFailed => 'Nie udało się zapisać serwisu. Formularz i załączniki zostały zachowane.';

  @override
  String get validationRequired => 'Wymagane';

  @override
  String get validationTitleRequired => 'Wpisz tytuł serwisu';

  @override
  String get validationMileageNonNegative => 'Podaj nieujemny przebieg';

  @override
  String get validationAmount => 'Podaj kwotę, maks. 2 miejsca po przecinku';

  @override
  String get validationAmountRequired => 'Podaj kwotę';

  @override
  String get validationMileageNumber => 'Podaj przebieg w kilometrach';

  @override
  String get categoryInsurance => 'Ubezpieczenie';

  @override
  String get categoryParking => 'Parking';

  @override
  String get categoryRoadTolls => 'Opłaty drogowe';

  @override
  String get categoryCarWash => 'Myjnia';

  @override
  String get categoryEnergy => 'Energia';

  @override
  String get mileageReadingLabel => 'Odczyt przebiegu';

  @override
  String get newEntryTitle => 'Nowy wpis';

  @override
  String amountField(Object currency) {
    return 'Kwota ($currency)';
  }

  @override
  String get fuelFieldLabel => 'Paliwo';

  @override
  String get quantityFuelField => 'Ilość paliwa (l)';

  @override
  String get quantityEnergyField => 'Energia (kWh)';

  @override
  String get validationAmountPositive => 'Podaj dodatnią kwotę, maks. 2 miejsca po przecinku';

  @override
  String get validationQuantityPositive => 'Podaj ilość większą od zera';

  @override
  String get dateFieldLabel => 'Data';

  @override
  String get fullTankSwitch => 'Pełny bak';

  @override
  String get fullTankSwitchSub => 'Potrzebny do obliczania spalania';

  @override
  String get missedTankSwitch => 'Pominięto wcześniejsze tankowanie';

  @override
  String get missedTankSwitchSub => 'Przerwij obliczanie spalania na tym odcinku';

  @override
  String get detailsSection => 'Szczegóły (opcjonalnie)';

  @override
  String get placeFuelField => 'Stacja lub miejsce';

  @override
  String get placeField => 'Miejsce';

  @override
  String get noteField => 'Notatka';

  @override
  String get saveEntryAction => 'Zapisz wpis';

  @override
  String get entrySaveFailed => 'Nie udało się zapisać wpisu. Dane formularza zostały zachowane.';

  @override
  String get duplicateEntryTitle => 'Podobny wpis już istnieje';

  @override
  String get duplicateEntryBody => 'Znaleziono taki sam tytuł, dzień i kwotę. Zapisać kolejny?';

  @override
  String get vehicleNameField => 'Nazwa (np. Moje BMW)';

  @override
  String get vehicleMakeField => 'Marka';

  @override
  String get vehicleModelField => 'Model';

  @override
  String get vehicleYearField => 'Rok';

  @override
  String get vehiclePlateField => 'Rejestracja';

  @override
  String get vehicleMileageField => 'Aktualny przebieg (km)';

  @override
  String get validationInvalidYear => 'Nieprawidłowy rok';

  @override
  String get validationVinLength => 'VIN powinien mieć 17 znaków';

  @override
  String get powertrainField => 'Napęd';

  @override
  String get powertrainPetrolLpg => 'Benzyna + LPG';

  @override
  String get powertrainHybrid => 'Hybryda';

  @override
  String get powertrainPlugInHybrid => 'Hybryda plug-in';

  @override
  String get vehicleTechSection => 'Dane techniczne i zakup';

  @override
  String get techDataSection => 'Dane techniczne';

  @override
  String get technicalNotesField => 'Notatki techniczne';

  @override
  String get purchaseDateField => 'Data zakupu';

  @override
  String get notSetLabel => 'Nie ustawiono';

  @override
  String get saveChangesAction => 'Zapisz zmiany';

  @override
  String get newCarTitle => 'Nowe auto';

  @override
  String get editCarTitle => 'Edytuj auto';

  @override
  String get editCarTooltip => 'Edytuj auto';

  @override
  String get deleteCarAction => 'Usuń auto';

  @override
  String deleteCarBody(Object name) {
    return 'Czy na pewno chcesz usunąć „$name”? Wszystkie wpisy serwisowe zostaną usunięte.';
  }

  @override
  String get vehicleSaveFailed => 'Nie udało się zapisać auta. Spróbuj ponownie.';

  @override
  String get addPhotoDialogTitle => 'Dodaj zdjęcie';

  @override
  String get addCarPhotoHint => 'Dodaj zdjęcie auta';

  @override
  String get cameraSource => 'Aparat';

  @override
  String get gallerySource => 'Galeria';

  @override
  String get emptyVehiclesTitle => 'Brak aut';

  @override
  String get emptyVehiclesBody => 'Dodaj swoje pierwsze auto, żeby śledzić serwisy';

  @override
  String get remindersSectionTitle => 'Przypomnienia';

  @override
  String get serviceHistoryTitle => 'Historia serwisów';

  @override
  String get noServiceRecordsTitle => 'Brak wpisów serwisowych';

  @override
  String get noServiceRecordsBody => 'Dodaj pierwszy wpis używając przycisku poniżej';

  @override
  String get serviceCostsTitle => 'Koszty serwisów';

  @override
  String entriesCountShort(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wpisów',
      many: '$count wpisów',
      few: '$count wpisy',
      one: '$count wpis',
    );
    return '$_temp0';
  }

  @override
  String lastServiceShortLabel(Object date) {
    return 'ostatni: $date';
  }

  @override
  String kmRemainingLabel(Object km) {
    return 'za $km km';
  }

  @override
  String overdueAtMileageLabel(Object km) {
    return 'po terminie ($km km)';
  }

  @override
  String get newReminderTitle => 'Nowy termin';

  @override
  String get editReminderTitle => 'Edytuj termin';

  @override
  String get reminderPresetInspection => 'Badanie techniczne';

  @override
  String get reminderPresetOc => 'Ubezpieczenie OC';

  @override
  String get reminderPresetAc => 'Ubezpieczenie AC';

  @override
  String get reminderPresetTires => 'Zmiana opon';

  @override
  String get reminderTitleField => 'O czym przypomnieć?';

  @override
  String get selectDateAction => 'Wybierz termin';

  @override
  String get removeDateTooltip => 'Usuń datę';

  @override
  String get targetMileageField => 'Przebieg docelowy (km)';

  @override
  String get reminderConditionsHint => 'Gdy ustawisz oba warunki, obowiązuje wcześniejszy. Przebieg jest sprawdzany po zapisaniu nowego odczytu.';

  @override
  String get repeatSection => 'Powtarzanie';

  @override
  String get repeatSectionSub => 'Nowy termin po oznaczeniu jako wykonane';

  @override
  String get everyMonthsField => 'Co ile miesięcy?';

  @override
  String get everyKmField => 'Co ile kilometrów?';

  @override
  String get noteOptionalField => 'Notatka (opcjonalnie)';

  @override
  String get saveReminderAction => 'Zapisz termin';

  @override
  String get reminderNeedsDateOrMileage => 'Ustaw datę lub przebieg docelowy.';

  @override
  String get reminderSaveFailed => 'Nie udało się zapisać terminu. Spróbuj ponownie.';

  @override
  String get validationPositiveNumber => 'Podaj dodatnią liczbę';

  @override
  String validationPositiveNumberUpTo(Object max) {
    return 'Podaj dodatnią liczbę do $max';
  }

  @override
  String get validationNonNegativeNumber => 'Podaj nieujemną liczbę';

  @override
  String get errorBackupTooLarge => 'Kopia przekracza 200 MB.';

  @override
  String get errorArchiveBroken => 'Nieprawidłowa zawartość archiwum.';

  @override
  String get errorUnpackedTooLarge => 'Rozpakowana kopia przekracza 500 MB.';

  @override
  String get errorArchiveVersion => 'Nieobsługiwana wersja kopii.';

  @override
  String get errorArchiveIncomplete => 'Niepełna kopia.';

  @override
  String get errorArchiveCorrupted => 'Kopia jest uszkodzona.';

  @override
  String get errorArchiveDataset => 'Nieprawidłowy zestaw danych.';

  @override
  String get errorArchiveColumns => 'Nieprawidłowe kolumny.';

  @override
  String get errorMissingBackupFile => 'Brakuje pliku w kopii.';

  @override
  String get errorMissingDraftFile => 'Brakuje pliku szkicu.';

  @override
  String get errorArchiveRelations => 'Nieprawidłowe powiązania.';

  @override
  String get errorAttachmentMissing => 'Brakuje załącznika. Przywróć plik lub usuń brakujący załącznik przed wykonaniem pełnej kopii.';

  @override
  String get errorCsvUnclosedQuote => 'Niezamknięty cudzysłów w pliku CSV.';

  @override
  String get errorCsvNoHeader => 'Brak nagłówka lub powtórzone nazwy kolumn.';

  @override
  String get csvErrorKind => 'Nieznany rodzaj wpisu';

  @override
  String get csvErrorTitle => 'Brak tytułu';

  @override
  String get csvErrorDate => 'Data: wymagany format RRRR-MM-DD';

  @override
  String get csvErrorAmount => 'Nieprawidłowa kwota';

  @override
  String get csvErrorMileage => 'Nieprawidłowy przebieg';

  @override
  String get csvErrorMileageRequired => 'Wymagany przebieg';

  @override
  String get csvErrorQuantity => 'Nieprawidłowa ilość';

  @override
  String get csvErrorFuel => 'Paliwo: Benzyna, Diesel lub LPG';

  @override
  String get csvErrorBoolean => 'Wartość logiczna: true lub false';

  @override
  String get draftSaveTitle => 'Zachować szkic?';

  @override
  String get draftSaveBody => 'Możesz wrócić do formularza i dokończyć wpis później.';

  @override
  String get draftStayAction => 'Zostań';

  @override
  String get draftDiscardAction => 'Odrzuć';

  @override
  String get draftSaveAction => 'Zapisz szkic';
}
