import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../data/database/app_database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/l10n/app_currency.dart';
import '../../core/l10n/app_errors.dart';
import '../../core/l10n/app_formats.dart';
import '../../core/l10n/app_settings.dart';
import '../../core/l10n/labels.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/csv_service.dart';
import '../../core/services/device_services.dart';
import 'garage_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool busy = false;
  String? status;
  bool costs = true, private = false;
  bool allowed = false;

  /// Pole kursu waluty. Trzymane w stanie, bo po zmianie waluty trzeba wstawić
  /// kurs tej waluty, a nie kurs tej, która była wyświetlana przed chwilą.
  final _rate = TextEditingController();
  AppCurrency? _rateCurrency;

  @override
  void initState() {
    super.initState();
    DeviceServices.notificationsAllowed().then((v) {
      if (mounted) setState(() => allowed = v);
    });
  }

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() fn) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(switch (e) {
          FormatException() => e.message,
          L10nException(:final error) => error.label(context),
          _ => AppError.operationFailed.label(context),
        })));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<BackupService> backups() async => BackupService(
      ref.read(garageRepositoryProvider).db,
      await getApplicationDocumentsDirectory());
  Future<void> restore(File file) async {
    final service = await backups();
    final preview = await service.inspect(file);
    if (!mounted) return;
    final l = context.l10n;
    final fmt = context.fmt;
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(l.restoreDialogTitle),
                content: Text(
                    '${l.restoreVehiclesCount(preview.vehicles)}, ${l.restoreEntriesCount(preview.entries)}.\n${l.restoreCreatedAt(fmt.dateTime(preview.created))}.\n\n${l.restoreDialogWarning}'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(l.cancelAction)),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(l.restoreConfirmAction))
                ]));
    if (ok == true) {
      await service.restore(preview);
      final theme = await ref.read(garageRepositoryProvider).setting('theme');
      ref.read(appThemeModeProvider.notifier).state = ThemeMode.values
          .firstWhere((m) => m.name == theme, orElse: () => ThemeMode.system);
      if (mounted) {
        setState(() => status = context.l10n.restoreDone);
      }
    }
  }

  Future<void> report(int id) async {
    // Teksty i formaty pobierane przed `await`ami — potem kontekst może
    // już nie należeć do żywego widżetu.
    final l = context.l10n;
    final fmt = context.fmt;
    final repo = ref.read(garageRepositoryProvider), db = repo.db;
    final car = await (db.select(db.vehicles)..where((v) => v.id.equals(id)))
        .getSingle();
    final rows = await repo.timeline(id);
    if (!context.mounted) return;
    final lines = <String>[
      '${car.make} ${car.model} · ${car.year}',
      context.km(car.currentMileage),
      l.reportGeneratedOn(fmt.dateNum(DateTime.now())),
      if (private) ...[
        l.reportVin(car.vin ?? '—'),
        l.reportRegistration(car.licensePlate ?? '—'),
        car.technicalNotes ?? ''
      ],
      '',
      ...rows.expand((e) => [
            '${fmt.dateNum(e.date)} · ${e.title}',
            '${categoryLabel(context, e.category)}${e.mileage == null ? '' : ' · ${context.km(e.mileage!)}'}${!costs || e.cents == null ? '' : ' · ${fmt.money(e.cents!)}'}',
            if (private && e.place.isNotEmpty) e.place,
            if (private && e.note.isNotEmpty) e.note,
            ''
          ])
    ];
    final items = await db.select(db.serviceItems).get();
    if (items.isNotEmpty) {
      lines.addAll([
        '',
        l.reportServiceItems,
        ...items
            .where((i) =>
                rows.any((e) => e.kind == 'SERVICE' && e.id == i.serviceId))
            .map((i) =>
                '${rows.firstWhere((e) => e.kind == 'SERVICE' && e.id == i.serviceId).title}: ${i.kind} — ${i.name}${costs ? ' · ${fmt.money(i.amountCents)}' : ''}')
      ]);
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(l.reportPreviewTitle),
                content: SizedBox(
                    width: 500,
                    child:
                        SingleChildScrollView(child: Text(lines.join('\n')))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(l.cancelAction)),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(l.createPdfAction))
                ]));
    if (ok != true) return;
    final file = await DeviceServices.report('${car.make} ${car.model}', lines);
    if (file == null) {
      throw const L10nException(AppError.pdfAndroidOnly);
    }
    await DeviceServices.saveFile(file, 'application/pdf');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageSnapshotProvider(null));
    final repo = ref.read(garageRepositoryProvider);
    return Scaffold(
        appBar: AppBar(title: Text(context.l10n.settingsTitle)),
        body: AbsorbPointer(
            absorbing: busy,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              if (busy) const LinearProgressIndicator(),
              if (status != null)
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(status!))),
              Text(context.l10n.yourDataHeader,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_outlined),
                            const SizedBox(height: 12),
                            Text(context.l10n.privacyBadge,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(context.l10n.privacyBody),
                            if (ref.watch(backupErrorProvider) != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                      ref
                                          .watch(backupErrorProvider)!
                                          .label(context),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)))
                          ]))),
              _action(
                  context.l10n.saveFullBackup,
                  context.l10n.saveFullBackupSub,
                  Icons.backup_outlined,
                  () => run(() async {
                        final file = await (await backups()).create();
                        final saved = await DeviceServices.saveFile(
                            file.path, 'application/zip');
                        if (saved) {
                          await repo.setSetting('lastExternalBackup',
                              DateTime.now().toIso8601String());
                        }
                        if (mounted) {
                          setState(() => status = saved
                              ? context.l10n.backupSaved
                              : context.l10n.backupSaveCancelled);
                        }
                      })),
              _action(
                  context.l10n.restoreFromFile,
                  context.l10n.restoreFromFileSub,
                  Icons.restore,
                  () => run(() async {
                        final file = await FilePicker.platform.pickFiles(
                            type: FileType.custom, allowedExtensions: ['zip']);
                        if (file?.files.single.path != null) {
                          await restore(File(file!.files.single.path!));
                        }
                      })),
              _action(
                  context.l10n.localBackups,
                  context.l10n.localBackupsSub,
                  Icons.folder_outlined,
                  () => run(() async {
                        final b = await backups();
                        if (!await b.backups.exists()) return;
                        final files = await b.backups
                            .list()
                            .where((f) => f is File && f.path.endsWith('.zip'))
                            .cast<File>()
                            .toList();
                        files.sort((a, b) => b.path.compareTo(a.path));
                        if (!mounted) return;
                        final file = await showModalBottomSheet<File>(
                            context: context,
                            showDragHandle: true,
                            builder: (c) => SafeArea(
                                    child:
                                        ListView(shrinkWrap: true, children: [
                                  ListTile(
                                      title:
                                          Text(c.l10n.chooseBackup)),
                                  if (files.isEmpty)
                                    ListTile(title: Text(c.l10n.noBackups)),
                                  ...files.take(30).map((f) => ListTile(
                                      leading:
                                          const Icon(Icons.archive_outlined),
                                      title: Text(p.basename(f.path),
                                          style: const TextStyle(fontSize: 12)),
                                      onTap: () => Navigator.pop(c, f)))
                                ])));
                        if (file != null) await restore(file);
                      })),
              const SizedBox(height: 24),
              Text(context.l10n.languageSection,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _languageTile(),
              _currencyTile(),
              const SizedBox(height: 24),
              Text(context.l10n.appearanceSection,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              DropdownButtonFormField<ThemeMode>(
                  value: ref.watch(appThemeModeProvider),
                  decoration:
                      InputDecoration(labelText: context.l10n.themeSetting),
                  items: [
                    DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(context.l10n.themeSystem)),
                    DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(context.l10n.themeLight)),
                    DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(context.l10n.themeDark))
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(appThemeModeProvider.notifier).state = v;
                      repo.setSetting('theme', v.name);
                    }
                  }),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(allowed
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined),
                  title: Text(allowed
                      ? context.l10n.notificationsOn
                      : context.l10n.notificationsOff),
                  subtitle: Text(context.l10n.notificationsExplain),
                  onTap: () async {
                    await DeviceServices.requestNotifications();
                    final result = await DeviceServices.notificationsAllowed();
                    if (mounted) setState(() => allowed = result);
                  }),
              const SizedBox(height: 24),
              Text(context.l10n.customCategoriesSection,
                  style: Theme.of(context).textTheme.titleLarge),
              _action(context.l10n.addCategory,
                  context.l10n.addCategorySub, Icons.category_outlined,
                  () async {
                final ctrl = TextEditingController();
                final value = await showDialog<String>(
                    context: context,
                    builder: (c) => AlertDialog(
                            title: Text(c.l10n.newCategoryTitle),
                            content: TextField(
                                controller: ctrl,
                                maxLength: 50,
                                decoration: InputDecoration(
                                    labelText: c.l10n.categoryNameLabel)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: Text(c.l10n.cancelAction)),
                              FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(c, ctrl.text.trim()),
                                  child: Text(c.l10n.addAction))
                            ]));
                if (value != null && value.isNotEmpty) {
                  await repo.db
                      .into(repo.db.customCategories)
                      .insertOnConflictUpdate(
                          CustomCategoriesCompanion.insert(name: value));
                  if (mounted) {
                    setState(
                        () => status = context.l10n.categoryAdded('„$value”'));
                  }
                }
              }),
              const SizedBox(height: 24),
              Text(context.l10n.exportImportSection,
                  style: Theme.of(context).textTheme.titleLarge),
              state.when(
                  loading: () => const SizedBox(),
                  error: (e, s) => const SizedBox(),
                  data: (s) {
                    final car = s.vehicle;
                    if (car == null) {
                      return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(context.l10n.addCarFirst));
                    }
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(car.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium)),
                          _action(
                              context.l10n.exportCsv,
                              context.l10n.exportCsvSub,
                              Icons.table_view_outlined,
                              () => run(() async {
                                    final text = await CsvService(repo.db)
                                        .export(car.id);
                                    final file = File(p.join(
                                        (await getTemporaryDirectory()).path,
                                        'pitstop-${car.id}.csv'));
                                    await file.writeAsString(text);
                                    await DeviceServices.saveFile(
                                        file.path, 'text/csv');
                                  })),
                          _action(
                              context.l10n.importCsv,
                              context.l10n.importCsvSub,
                              Icons.file_upload_outlined,
                              () => context.push('/vehicle/${car.id}/import')),
                          SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(context.l10n.pdfReportCosts),
                              value: costs,
                              onChanged: (v) => setState(() => costs = v)),
                          SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(context.l10n.pdfReportPrivate),
                              subtitle:
                                  Text(context.l10n.pdfReportPrivateSub),
                              value: private,
                              onChanged: (v) => setState(() => private = v)),
                          _action(
                              context.l10n.historyReportPdf,
                              context.l10n.historyReportPdfSub,
                              Icons.picture_as_pdf_outlined,
                              () => run(() => report(car.id)))
                        ]);
                  }),
              const SizedBox(height: 30),
              Center(child: Text(context.l10n.appFooter)),
              const SizedBox(height: 24)
            ])));
  }

  Widget _action(
          String title, String subtitle, IconData icon, VoidCallback action) =>
      Card(
          child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: action));

  /// Język interfejsu. `languageSystem` oddaje decyzję językowi telefonu, więc
  /// zmiana w ustawieniach systemowych jest widoczna po ponownym wejściu do
  /// aplikacji.
  Widget _languageTile() {
    final l = context.l10n;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DropdownButtonFormField<AppLanguage>(
            value: ref.watch(appLanguageProvider),
            decoration: InputDecoration(labelText: l.languageSetting),
            items: [
              for (final option in AppLanguage.values)
                DropdownMenuItem(
                    value: option,
                    child: Text(switch (option) {
                      AppLanguage.system => l.languageSystem,
                      AppLanguage.polish => l.languagePolish,
                      AppLanguage.english => l.languageEnglish,
                    }))
            ],
            onChanged: (value) async {
              if (value == null) return;
              ref.read(appLanguageProvider.notifier).state = value;
              await saveLanguage(ref.read(garageRepositoryProvider).db, value);
            }));
  }

  /// Waluta pokazowa i jej kurs. Kwoty w bazie zostają w złotych — wybór zmienia
  /// tylko przeliczanie przy wyświetlaniu i wpisywaniu.
  Widget _currencyTile() {
    final l = context.l10n;
    final shown = ref.watch(displayCurrencyProvider);
    // Ustawienie tekstu w `build` jest tu celowe: pole istnieje tylko dla
    // waluty innej niż bazowa, a jego treść zmienia się razem z tą walutą.
    if (_rateCurrency != shown.currency) {
      _rateCurrency = shown.currency;
      _rate.text = shown.currency.isBase
          ? ''
          : context.fmt
              .decimal(shown.rate, digits: 4)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'[.,]$'), '');
    }
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DropdownButtonFormField<AppCurrency>(
              value: shown.currency,
              decoration: InputDecoration(labelText: l.currencySetting),
              items: [
                for (final currency in AppCurrency.values)
                  DropdownMenuItem(
                      value: currency,
                      child: Text('${currency.code} · ${currency.symbol}'))
              ],
              onChanged: (value) async {
                if (value == null) return;
                final db = ref.read(garageRepositoryProvider).db;
                final next =
                    DisplayCurrency(value, await readRate(db, value));
                ref.read(displayCurrencyProvider.notifier).state = next;
                await saveCurrency(db, next);
              })),
      if (!shown.currency.isBase)
        TextField(
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: l.currencyRateSetting,
                helperText: l.currencyRateHint(shown.currency.code),
                helperMaxLines: 3),
            onSubmitted: (value) async {
              final rate = context.fmt.parseDecimal(value);
              if (rate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.currencyRateInvalid)));
                return;
              }
              final db = ref.read(garageRepositoryProvider).db;
              final next = DisplayCurrency(shown.currency, rate);
              ref.read(displayCurrencyProvider.notifier).state = next;
              await saveCurrency(db, next);
            })
    ]);
  }
}

class CsvImportScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  const CsvImportScreen({super.key, required this.vehicleId});
  @override
  ConsumerState<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends ConsumerState<CsvImportScreen> {
  CsvData? csv;
  Map<String, String> mapping = {};
  List<ImportRow>? preview;
  bool busy = false;
  /// Etykiety pól mapowania; teksty są wybierane w bieżącym języku, a klucze
  /// pozostają surowymi nazwami kolumn eksportowanymi przez `CsvService`.
  static Map<String, String> fieldLabels(AppLocalizations l) => {
        'kind': l.csvFieldKind,
        'title': l.csvFieldTitle,
        'date': l.csvFieldDate,
        'mileage': l.csvFieldMileage,
        'amount': l.csvFieldAmount,
        'category': l.csvFieldCategory,
        'quantity': l.csvFieldQuantity,
        'fuel': l.csvFieldFuel,
        'fullTank': l.csvFieldFullTank,
        'missed': l.csvFieldMissed,
        'place': l.csvFieldPlace,
        'note': l.csvFieldNote,
      };
  Future<void> pick() async {
    try {
      final f = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (f?.files.single.path == null) return;
      final data =
          CsvData.parse(await File(f!.files.single.path!).readAsString());
      if (mounted) {
        setState(() {
          csv = data;
          preview = null;
          mapping = {
            for (final field in CsvService.fields)
              if (data.headers.contains(field)) field: field
          };
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppError.csvUnreadable.label(context))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(context.l10n.importCsv)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(context.l10n.csvImportIntro),
        const SizedBox(height: 16),
        OutlinedButton.icon(
            onPressed: busy ? null : pick,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(context.l10n.chooseCsvFile)),
        if (csv != null && preview == null) ...[
          const SizedBox(height: 12),
          Text(context.l10n.csvMapColumns(csv!.rows.length),
              style: Theme.of(context).textTheme.titleLarge),
          for (final field in CsvService.fields)
            Padding(
                padding: const EdgeInsets.only(top: 14),
                child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: mapping[field] ?? '',
                    decoration: InputDecoration(
                        labelText: fieldLabels(context.l10n)[field]),
                    items: [
                      DropdownMenuItem(
                          value: '',
                          child: Text(context.l10n.csvSkipColumn)),
                      ...csv!.headers.map((h) => DropdownMenuItem(
                          value: h,
                          child: Text(h, overflow: TextOverflow.ellipsis)))
                    ],
                    onChanged: (v) =>
                        setState(() => mapping[field] = v ?? ''))),
          const SizedBox(height: 20),
          FilledButton(
              onPressed: () => setState(() => preview =
                  CsvService(ref.read(garageRepositoryProvider).db)
                      .preview(csv!, mapping)),
              child: Text(context.l10n.csvCheckPreview))
        ],
        if (preview != null) ...[
          const SizedBox(height: 20),
          Text(
              context.l10n.csvPreviewSummary(
                  preview!.where((r) => r.error == null).length,
                  preview!.where((r) => r.error != null).length),
              style: Theme.of(context).textTheme.titleMedium),
          ...preview!.take(200).map((r) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(r.error == null
                  ? Icons.check_circle_outline
                  : Icons.error_outline),
              title: Text(context.l10n
                  .csvRowLabel(r.line.toString(), r.data['title'] ?? '')),
              // Kwota z pliku jest zawsze w PLN, więc waluta bazowa, nie pokazowa.
              subtitle: Text(r.error == null
                  ? '${r.data['date']} · '
                      '${r.data['amount']} ${AppCurrency.pln.symbol}'
                  : r.error!.label(context)))),
          if (preview!.length > 200)
            Text(context.l10n.csvPreviewLimited),
          TextButton(
              onPressed: busy ? null : () => setState(() => preview = null),
              child: Text(context.l10n.csvChangeMapping)),
          FilledButton(
              onPressed: busy || !preview!.any((r) => r.error == null)
                  ? null
                  : () async {
                      setState(() => busy = true);
                      try {
                        final count = await CsvService(
                                ref.read(garageRepositoryProvider).db)
                            .import(widget.vehicleId, preview!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  context.l10n.csvImportDone(count))));
                          context.pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  AppError.csvImportFailed.label(context))));
                        }
                      } finally {
                        if (mounted) setState(() => busy = false);
                      }
                    },
              child: Text(busy
                  ? context.l10n.csvImporting
                  : context.l10n.csvImportValidRows))
        ],
        const SizedBox(height: 40)
      ]));
}
