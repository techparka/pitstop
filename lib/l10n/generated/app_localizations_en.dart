import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Everything about your car';

  @override
  String get backupErrorDatabaseOpen => 'Couldn\'t open the database.';

  @override
  String get backupErrorAutomaticFailed => 'The automatic backup did not run. Check the free space and missing attachments.';

  @override
  String get languageSetting => 'Language';

  @override
  String get languageSystem => 'Match system';

  @override
  String get currencySetting => 'Currency';

  @override
  String get currencyRateSetting => 'Rate for PLN 1';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navHistory => 'History';

  @override
  String get navReminders => 'Due dates';

  @override
  String get navGarage => 'Garage';

  @override
  String get errorOperationFailed => 'The operation failed. Your data stays unchanged. Check the file and the free space.';

  @override
  String get errorPdfAndroidOnly => 'PDF export is available in the Android version.';

  @override
  String get errorCsvUnreadable => 'Couldn\'t read the CSV. Use UTF-8 encoding and a ; or , separator.';

  @override
  String get errorCsvImportFailed => 'The import failed. No rows were added.';

  @override
  String get errorRestoreFailed => 'Couldn\'t restore the backup. Check the file and the free space.';

  @override
  String get notifDueToday => 'Due today';

  @override
  String get notifDueOverdue => 'Overdue — check the details';

  @override
  String notifDueInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Due in $days days',
      one: 'Due in 1 day',
    );
    return '$_temp0';
  }

  @override
  String notifMileageReached(Object mileage) {
    return 'Reached $mileage km';
  }

  @override
  String notifMileageRemaining(Object remaining) {
    return '$remaining km left according to the last reading';
  }

  @override
  String get categoryFuel => 'Fuel';

  @override
  String get categoryService => 'Service';

  @override
  String get categoryRepair => 'Repair';

  @override
  String get categoryAccessory => 'Accessory';

  @override
  String get categoryAdministrative => 'Fees';

  @override
  String get serviceTypeOilChange => 'Oil change';

  @override
  String get serviceTypeBrakes => 'Brakes';

  @override
  String get serviceTypeFilters => 'Filters';

  @override
  String get serviceTypeTiming => 'Timing';

  @override
  String get serviceTypeBattery => 'Battery';

  @override
  String get serviceTypeFluids => 'Fluids';

  @override
  String get serviceTypeAirConditioning => 'Air conditioning';

  @override
  String get serviceTypeSuspension => 'Suspension';

  @override
  String get serviceTypeRepair => 'Repair';

  @override
  String get serviceTypeInspection => 'Service inspection';

  @override
  String get serviceTypeTires => 'Tyres';

  @override
  String get serviceTypeOther => 'Other';

  @override
  String get powertrainPetrol => 'Petrol';

  @override
  String get powertrainDiesel => 'Diesel';

  @override
  String get powertrainLpg => 'LPG';

  @override
  String get powertrainHybridPetrol => 'Hybrid (petrol)';

  @override
  String get powertrainHybridDiesel => 'Hybrid (diesel)';

  @override
  String get powertrainElectric => 'Electric';

  @override
  String get unitKm => 'km';

  @override
  String get unitL => 'l';

  @override
  String get unitKmPerL => 'km/l';

  @override
  String get unitLPer100km => 'l/100 km';

  @override
  String get loadFailed => 'Couldn\'t read your data.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get titleGarageTab => 'Your garage';

  @override
  String get settingsTooltip => 'Settings and backups';

  @override
  String get addCarAction => 'Add car';

  @override
  String get addEntryAction => 'Add entry';

  @override
  String get emptyGarageTitle => 'A good history starts here';

  @override
  String get emptyGarageBody => 'Add a car. Services, costs and important dates stay at hand — even offline.';

  @override
  String get addFirstCar => 'Add your first car';

  @override
  String get haveBackup => 'I have a backup';

  @override
  String get yourCarBadge => 'YOUR CAR';

  @override
  String get carProfileTooltip => 'Car profile and editing';

  @override
  String get lastKnownMileage => 'Last recorded mileage';

  @override
  String get metricMonthExpenses => 'Spent this month';

  @override
  String get metricActiveReminders => 'Active reminders';

  @override
  String get analyticsCardTitle => 'See what your car costs';

  @override
  String get analyticsCardSubtitle => 'Costs, trends and fuel consumption';

  @override
  String get backupCardTitle => 'Back up your car history';

  @override
  String get backupCardSubtitle => 'Save a full copy outside the phone.';

  @override
  String get sectionUpcoming => 'Upcoming dates';

  @override
  String get actionAll => 'All';

  @override
  String get hintCalmTitle => 'Nothing due';

  @override
  String get hintCalmBody => 'Add an inspection, insurance or the next service.';

  @override
  String get sectionRecentActivity => 'Recent activity';

  @override
  String get hintFirstEntryTitle => 'Your first entry is ahead';

  @override
  String get hintFirstEntryBody => 'Record a service, a refuel or another expense.';

  @override
  String get privacyNote => 'Your data. Only on your device.';

  @override
  String get searchEntriesHint => 'Search entry, description, workshop…';

  @override
  String get filterAll => 'All';

  @override
  String get filterServices => 'Services';

  @override
  String get filterCharges => 'Charging';

  @override
  String get filterExpenses => 'Expenses';

  @override
  String get filterMileage => 'Mileage';

  @override
  String get filterAnyCategory => 'Any category';

  @override
  String get filterDatesTooltip => 'Filter by date';

  @override
  String get removeDateRangeTooltip => 'Remove date range';

  @override
  String entriesSummary(num count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries · $total',
      one: '$count entry · $total',
    );
    return '$_temp0';
  }

  @override
  String get noMatchingEntries => 'No matching entries';

  @override
  String get termsRuleTitle => 'Date or mileage, whichever comes first';

  @override
  String get termsRuleBody => 'The earlier condition applies. Mileage reminders use the last recorded reading.';

  @override
  String get notificationsConsentHint => 'You can also change notification permission in phone settings.';

  @override
  String get enableNotifications => 'Turn on notifications';

  @override
  String get noActiveRemindersTitle => 'No active reminders';

  @override
  String get noActiveRemindersBody => 'Add a reminder with the button below.';

  @override
  String doneRemindersSection(Object count) {
    return 'Completed ($count)';
  }

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteReminderTitle => 'Delete this reminder?';

  @override
  String get markDoneTitle => 'Mark as done';

  @override
  String get markDoneBody => 'Also save an entry in the service history?';

  @override
  String get markDoneOnly => 'Mark only';

  @override
  String get addServiceAction => 'Add service';

  @override
  String get reminderDoneAction => 'Done';

  @override
  String get reminderOptionsTooltip => 'Reminder options';

  @override
  String get urgencyAttention => 'Needs attention';

  @override
  String get urgencySoon => 'Coming up';

  @override
  String get urgencyPlanned => 'Planned';

  @override
  String kmRemaining(Object remaining) {
    return '$remaining km left';
  }

  @override
  String repeatLabel(Object rules) {
    return 'Repeats: $rules';
  }

  @override
  String repeatEveryMonths(num months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'every $months months',
      one: 'every month',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryKm(Object km) {
    return 'every $km';
  }

  @override
  String get repeatOr => 'or';

  @override
  String get garageTabTitle => 'Every car has its own history';

  @override
  String get addSheetTitle => 'What do you want to record?';

  @override
  String get addServiceEntry => 'Service';

  @override
  String get addRefuel => 'Refuel';

  @override
  String get addCharge => 'Charge';

  @override
  String get addExpense => 'Expense';

  @override
  String get addReminder => 'Reminder';

  @override
  String get analyticsTitle => 'Costs and consumption';

  @override
  String get statsLoadFailed => 'Couldn\'t read the statistics';

  @override
  String get periodAll => 'Full history';

  @override
  String get periodMonth => 'This month';

  @override
  String get periodYear => 'This year';

  @override
  String get periodCustom => 'Custom range';

  @override
  String amountsInCurrency(Object currency) {
    return 'All amounts in $currency. Each cost is counted once.';
  }

  @override
  String get metricTotalExpenses => 'Total spending';

  @override
  String get metricCostedEntries => 'Entries with a cost';

  @override
  String get metricCostPerKm => 'Cost per kilometre';

  @override
  String costPerKmRange(Object from, Object km, Object to) {
    return 'Cost per km: $from – $to, $km. Costs outside this span are not included.';
  }

  @override
  String get costPerKmNeedsReadings => 'Cost per km needs two mileage readings with different values in the selected period.';

  @override
  String get fuelConsumptionTitle => 'Fuel consumption';

  @override
  String get fuelNeedsMoreData => 'Not enough data. Add at least two full tanks of the same fuel. Partial fills are summed, a missed tank breaks the span.';

  @override
  String fuelCalculatedOver(Object fuel, Object km) {
    return '$fuel · calculated over $km';
  }

  @override
  String get fuelSplitNote => 'Petrol and LPG are counted separately. With two fuels the results show each fuel share, not the engine consumption on its own.';

  @override
  String get expensesByCategory => 'Spending by category';

  @override
  String get monthByMonth => 'Month by month';

  @override
  String get addFirstEntryForStats => 'Add a first entry to see statistics.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get restoreDialogTitle => 'Restore this backup?';

  @override
  String restoreVehiclesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cars',
      one: '$count car',
    );
    return '$_temp0';
  }

  @override
  String restoreEntriesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String restoreCreatedAt(Object created) {
    return 'Backup from $created';
  }

  @override
  String get restoreDialogWarning => 'It replaces current data. A safety backup of the current state is saved first.';

  @override
  String get restoreDone => 'Data and attachments restored. The previous state is in local backups.';

  @override
  String reportGeneratedOn(Object date) {
    return 'Generated $date';
  }

  @override
  String reportVin(Object vin) {
    return 'VIN: $vin';
  }

  @override
  String reportRegistration(Object plate) {
    return 'Registration: $plate';
  }

  @override
  String get reportServiceItems => 'Service items (included in service amounts):';

  @override
  String get reportPreviewTitle => 'Report preview';

  @override
  String get createPdfAction => 'Create PDF';

  @override
  String get yourDataHeader => 'YOUR DATA';

  @override
  String get privacyBadge => 'No account. No ads. No fees.';

  @override
  String get privacyBody => 'Everything works on the device. A local backup will not protect your data after you lose the phone — regularly save the ZIP elsewhere.';

  @override
  String get saveFullBackup => 'Save a full ZIP backup';

  @override
  String get saveFullBackupSub => 'Data, settings, photos and documents';

  @override
  String get backupSaved => 'Backup saved in the location you chose. Keep a copy outside the phone regularly.';

  @override
  String get backupSaveCancelled => 'External save cancelled. The backup is available in local backups.';

  @override
  String get restoreFromFile => 'Restore from a ZIP file';

  @override
  String get restoreFromFileSub => 'Backup integrity is checked first';

  @override
  String get localBackups => 'Local backups';

  @override
  String get localBackupsSub => 'Last 5 automatic plus manual copies';

  @override
  String get chooseBackup => 'Choose a backup to restore';

  @override
  String get noBackups => 'No backups';

  @override
  String get appearanceSection => 'Appearance and notifications';

  @override
  String get themeSetting => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notificationsOn => 'Notifications on';

  @override
  String get notificationsOff => 'Notifications off';

  @override
  String get notificationsExplain => 'Date reminders: 7 days, 1 day before and on the due date. Android may delay notifications in battery saver mode.';

  @override
  String get languageSection => 'Language and currency';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageEnglish => 'English';

  @override
  String currencyRateHint(Object currency) {
    return 'How many $currency equal 1 zł. Amounts stay stored in złoty.';
  }

  @override
  String get currencyRateInvalid => 'Enter a positive rate, e.g. 0.24';

  @override
  String get customCategoriesSection => 'Custom categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get addCategorySub => 'Available in services and expenses';

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get addAction => 'Add';

  @override
  String categoryAdded(Object name) {
    return 'Added category $name.';
  }

  @override
  String get exportImportSection => 'Export and import for the selected car';

  @override
  String get addCarFirst => 'Add a car or restore a backup first.';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportCsvSub => 'History, refuels and expenses';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importCsvSub => 'Column mapping and preview before saving';

  @override
  String get pdfReportCosts => 'Amounts in the PDF report';

  @override
  String get pdfReportPrivate => 'Private data in the report';

  @override
  String get pdfReportPrivateSub => 'VIN, registration, workshops, descriptions and notes';

  @override
  String get historyReportPdf => 'History PDF report';

  @override
  String get historyReportPdfSub => 'With a preview before saving the file';

  @override
  String get appFooter => 'PitStop 2.0 · Offline, always on your side.';

  @override
  String get csvFieldKind => 'Kind (SERVICE, FUEL, CHARGE, EXPENSE, MILEAGE)';

  @override
  String get csvFieldTitle => 'Title';

  @override
  String get csvFieldDate => 'Date (YYYY-MM-DD)';

  @override
  String get csvFieldMileage => 'Mileage (km)';

  @override
  String get csvFieldAmount => 'Amount (zł)';

  @override
  String get csvFieldCategory => 'Category';

  @override
  String get csvFieldQuantity => 'Litres / kWh';

  @override
  String get csvFieldFuel => 'Fuel';

  @override
  String get csvFieldFullTank => 'Full tank (true/false)';

  @override
  String get csvFieldMissed => 'Missed tank (true/false)';

  @override
  String get csvFieldPlace => 'Workshop / place';

  @override
  String get csvFieldNote => 'Note';

  @override
  String get csvImportIntro => 'Import into the selected car. Re-importing identical rows is skipped. Invalid rows are not saved.';

  @override
  String get chooseCsvFile => 'Choose CSV';

  @override
  String csvMapColumns(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Match columns ($count rows)',
      one: 'Match columns ($count row)',
    );
    return '$_temp0';
  }

  @override
  String get csvSkipColumn => 'Skip / default value';

  @override
  String get csvCheckPreview => 'Validate and show preview';

  @override
  String csvPreviewSummary(Object correct, Object faulty) {
    return '$correct valid · $faulty invalid';
  }

  @override
  String csvRowLabel(Object line, Object title) {
    return 'Row $line: $title';
  }

  @override
  String get csvPreviewLimited => 'Preview shows the first 200 rows. Validation covers the whole file.';

  @override
  String get csvChangeMapping => 'Change mapping';

  @override
  String csvImportDone(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count entries. Duplicates were skipped.',
      one: 'Imported $count entry. Duplicates were skipped.',
    );
    return '$_temp0';
  }

  @override
  String get csvImporting => 'Importing…';

  @override
  String get csvImportValidRows => 'Import valid rows';

  @override
  String get restoreConfirmAction => 'Restore';

  @override
  String get statsCostsTitle => 'Cost statistics';

  @override
  String errorWithDetails(Object error) {
    return 'Error: $error';
  }

  @override
  String get noDataTitle => 'No data';

  @override
  String get statsEmptyBody => 'Add service entries with a cost\nto see statistics.';

  @override
  String get statsTotalCost => 'Total cost';

  @override
  String get statsEntryCount => 'Entry count';

  @override
  String get statsAverageCost => 'Avg. cost/entry';

  @override
  String get statsLastService => 'Last service';

  @override
  String get statsCostByType => 'Cost by service type';

  @override
  String get editServiceTooltip => 'Edit service';

  @override
  String get deleteServiceTooltip => 'Delete service';

  @override
  String get serviceItemsSection => 'Parts and labour';

  @override
  String get mileageLabel => 'Mileage';

  @override
  String get costLabel => 'Cost';

  @override
  String get workshopLabel => 'Workshop';

  @override
  String get descriptionSection => 'Description';

  @override
  String get photosSection => 'Photos';

  @override
  String get invoicesSection => 'Invoices';

  @override
  String get deleteEntryTitle => 'Delete entry';

  @override
  String get deleteServiceConfirmBody => 'Delete this service entry? This cannot be undone.';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get imageUnavailable => 'Cannot show the photo. The file is missing or damaged.';

  @override
  String get invoiceFileMissing => 'The invoice file does not exist.';

  @override
  String get noPdfApp => 'No app available to open PDF files.';

  @override
  String get invoiceAccessDenied => 'No access to the invoice file.';

  @override
  String get pdfOpenFailed => 'Could not open the PDF file.';

  @override
  String get newServiceTitle => 'New service';

  @override
  String get editServiceTitle => 'Edit service';

  @override
  String get templateTooltip => 'Fill from a template';

  @override
  String get templateOilChange => 'Oil and filter change';

  @override
  String get templateTires => 'Tyre change';

  @override
  String get templateInspection => 'Technical inspection';

  @override
  String get useTemplateAction => 'Use a template or a previous service';

  @override
  String get serviceTitleField => 'What was done?';

  @override
  String get categoryField => 'Category';

  @override
  String get serviceDateField => 'Service date';

  @override
  String get mileageField => 'Mileage (km)';

  @override
  String costField(Object currency) {
    return 'Total cost ($currency, optional)';
  }

  @override
  String get partsTotalLabel => 'Sum of parts and labour';

  @override
  String get partsSectionSub => 'Optional breakdown of the total amount';

  @override
  String get itemKindPart => 'Part';

  @override
  String get itemKindLabour => 'Labour';

  @override
  String get removeItemTooltip => 'Remove item';

  @override
  String get itemNameField => 'Item name';

  @override
  String itemCostField(Object currency) {
    return 'Item cost ($currency)';
  }

  @override
  String get addItemAction => 'Add item';

  @override
  String get workshopAndDescription => 'Workshop and description';

  @override
  String get descriptionField => 'Description and notes';

  @override
  String get photosAndInvoices => 'Photos and invoices';

  @override
  String get removeAttachmentTooltip => 'Remove attachment';

  @override
  String get photoAction => 'Photo';

  @override
  String get invoiceAction => 'Invoice (PDF or photo)';

  @override
  String get savingLabel => 'Saving…';

  @override
  String get saveServiceAction => 'Save service';

  @override
  String get takePhotoAction => 'Take a photo';

  @override
  String get fromGalleryAction => 'Choose from gallery';

  @override
  String get photoAddFailed => 'Could not add the photo. Check camera or gallery permissions.';

  @override
  String get invoiceAddFailed => 'Could not add the invoice.';

  @override
  String get serviceLoadFailed => 'Could not load the service. Go back and try again.';

  @override
  String get duplicateServiceTitle => 'A similar service already exists';

  @override
  String get duplicateServiceBody => 'Same title, day and amount. Save another entry?';

  @override
  String get goBackAction => 'Go back';

  @override
  String get saveAnotherAction => 'Save another';

  @override
  String get serviceSaveFailed => 'Could not save the service. The form and attachments are kept.';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationTitleRequired => 'Enter a service title';

  @override
  String get validationMileageNonNegative => 'Enter a non-negative mileage';

  @override
  String get validationAmount => 'Enter an amount, max 2 decimal places';

  @override
  String get validationAmountRequired => 'Enter an amount';

  @override
  String get validationMileageNumber => 'Enter the mileage in kilometres';

  @override
  String get categoryInsurance => 'Insurance';

  @override
  String get categoryParking => 'Parking';

  @override
  String get categoryRoadTolls => 'Road tolls';

  @override
  String get categoryCarWash => 'Car wash';

  @override
  String get categoryEnergy => 'Energy';

  @override
  String get mileageReadingLabel => 'Mileage reading';

  @override
  String get newEntryTitle => 'New entry';

  @override
  String amountField(Object currency) {
    return 'Amount ($currency)';
  }

  @override
  String get fuelFieldLabel => 'Fuel';

  @override
  String get quantityFuelField => 'Fuel quantity (l)';

  @override
  String get quantityEnergyField => 'Energy (kWh)';

  @override
  String get validationAmountPositive => 'Enter a positive amount, max 2 decimal places';

  @override
  String get validationQuantityPositive => 'Enter a quantity greater than zero';

  @override
  String get dateFieldLabel => 'Date';

  @override
  String get fullTankSwitch => 'Full tank';

  @override
  String get fullTankSwitchSub => 'Needed to calculate fuel consumption';

  @override
  String get missedTankSwitch => 'A previous refuel was skipped';

  @override
  String get missedTankSwitchSub => 'Breaks the consumption calculation for this stretch';

  @override
  String get detailsSection => 'Details (optional)';

  @override
  String get placeFuelField => 'Station or place';

  @override
  String get placeField => 'Place';

  @override
  String get noteField => 'Note';

  @override
  String get saveEntryAction => 'Save entry';

  @override
  String get entrySaveFailed => 'Could not save the entry. The form data is kept.';

  @override
  String get duplicateEntryTitle => 'A similar entry already exists';

  @override
  String get duplicateEntryBody => 'The same title, day and amount was found. Save another one?';

  @override
  String get vehicleNameField => 'Name (e.g. My BMW)';

  @override
  String get vehicleMakeField => 'Make';

  @override
  String get vehicleModelField => 'Model';

  @override
  String get vehicleYearField => 'Year';

  @override
  String get vehiclePlateField => 'Registration';

  @override
  String get vehicleMileageField => 'Current mileage (km)';

  @override
  String get validationInvalidYear => 'Invalid year';

  @override
  String get validationVinLength => 'VIN must be 17 characters';

  @override
  String get powertrainField => 'Powertrain';

  @override
  String get powertrainPetrolLpg => 'Petrol + LPG';

  @override
  String get powertrainHybrid => 'Hybrid';

  @override
  String get powertrainPlugInHybrid => 'Plug-in hybrid';

  @override
  String get vehicleTechSection => 'Technical details and purchase';

  @override
  String get techDataSection => 'Technical details';

  @override
  String get technicalNotesField => 'Technical notes';

  @override
  String get purchaseDateField => 'Purchase date';

  @override
  String get notSetLabel => 'Not set';

  @override
  String get saveChangesAction => 'Save changes';

  @override
  String get newCarTitle => 'New car';

  @override
  String get editCarTitle => 'Edit car';

  @override
  String get editCarTooltip => 'Edit car';

  @override
  String get deleteCarAction => 'Delete car';

  @override
  String deleteCarBody(Object name) {
    return 'Delete $name? All its service records will be deleted too.';
  }

  @override
  String get vehicleSaveFailed => 'Could not save the car. Try again.';

  @override
  String get addPhotoDialogTitle => 'Add photo';

  @override
  String get addCarPhotoHint => 'Add a car photo';

  @override
  String get cameraSource => 'Camera';

  @override
  String get gallerySource => 'Gallery';

  @override
  String get emptyVehiclesTitle => 'No cars yet';

  @override
  String get emptyVehiclesBody => 'Add your first car to keep track of services';

  @override
  String get remindersSectionTitle => 'Reminders';

  @override
  String get serviceHistoryTitle => 'Service history';

  @override
  String get noServiceRecordsTitle => 'No service records';

  @override
  String get noServiceRecordsBody => 'Add the first record with the button below';

  @override
  String get serviceCostsTitle => 'Service costs';

  @override
  String entriesCountShort(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String lastServiceShortLabel(Object date) {
    return 'last: $date';
  }

  @override
  String kmRemainingLabel(Object km) {
    return 'in $km km';
  }

  @override
  String overdueAtMileageLabel(Object km) {
    return 'overdue ($km km)';
  }

  @override
  String get newReminderTitle => 'New due date';

  @override
  String get editReminderTitle => 'Edit due date';

  @override
  String get reminderPresetInspection => 'Vehicle inspection';

  @override
  String get reminderPresetOc => 'Third-party liability insurance';

  @override
  String get reminderPresetAc => 'Comprehensive insurance';

  @override
  String get reminderPresetTires => 'Tyre change';

  @override
  String get reminderTitleField => 'What should we remind you about?';

  @override
  String get selectDateAction => 'Choose a date';

  @override
  String get removeDateTooltip => 'Remove date';

  @override
  String get targetMileageField => 'Target mileage (km)';

  @override
  String get reminderConditionsHint => 'If you set both conditions, the earlier one applies. Mileage is checked once a new reading is saved.';

  @override
  String get repeatSection => 'Repeating';

  @override
  String get repeatSectionSub => 'A new due date appears after you mark it done';

  @override
  String get everyMonthsField => 'Every how many months?';

  @override
  String get everyKmField => 'Every how many kilometres?';

  @override
  String get noteOptionalField => 'Note (optional)';

  @override
  String get saveReminderAction => 'Save due date';

  @override
  String get reminderNeedsDateOrMileage => 'Set a date or a target mileage.';

  @override
  String get reminderSaveFailed => 'Could not save the due date. Try again.';

  @override
  String get validationPositiveNumber => 'Enter a positive number';

  @override
  String validationPositiveNumberUpTo(Object max) {
    return 'Enter a positive number up to $max';
  }

  @override
  String get validationNonNegativeNumber => 'Enter a non-negative number';

  @override
  String get errorBackupTooLarge => 'The backup exceeds 200 MB.';

  @override
  String get errorArchiveBroken => 'The archive contents are invalid.';

  @override
  String get errorUnpackedTooLarge => 'The unpacked backup exceeds 500 MB.';

  @override
  String get errorArchiveVersion => 'Unsupported backup version.';

  @override
  String get errorArchiveIncomplete => 'The backup is incomplete.';

  @override
  String get errorArchiveCorrupted => 'The backup is corrupted.';

  @override
  String get errorArchiveDataset => 'The backup holds an invalid data set.';

  @override
  String get errorArchiveColumns => 'The backup has invalid database columns.';

  @override
  String get errorMissingBackupFile => 'A file is missing from the backup.';

  @override
  String get errorMissingDraftFile => 'The draft file is missing from the backup.';

  @override
  String get errorArchiveRelations => 'The backup has invalid database relations.';

  @override
  String get errorAttachmentMissing => 'An attachment is missing. Restore the file or remove the missing attachment before making a full backup.';

  @override
  String get errorCsvUnclosedQuote => 'Unclosed quote in the CSV file.';

  @override
  String get errorCsvNoHeader => 'Missing header or duplicated column names.';

  @override
  String get csvErrorKind => 'Unknown entry type';

  @override
  String get csvErrorTitle => 'Missing title';

  @override
  String get csvErrorDate => 'Date: YYYY-MM-DD format required';

  @override
  String get csvErrorAmount => 'Invalid amount';

  @override
  String get csvErrorMileage => 'Invalid mileage';

  @override
  String get csvErrorMileageRequired => 'Mileage is required';

  @override
  String get csvErrorQuantity => 'Invalid quantity';

  @override
  String get csvErrorFuel => 'Fuel: Benzyna, Diesel or LPG';

  @override
  String get csvErrorBoolean => 'Boolean value: true or false';

  @override
  String get draftSaveTitle => 'Save this draft?';

  @override
  String get draftSaveBody => 'You can return to the form and finish the entry later.';

  @override
  String get draftStayAction => 'Stay';

  @override
  String get draftDiscardAction => 'Discard';

  @override
  String get draftSaveAction => 'Save draft';
}
