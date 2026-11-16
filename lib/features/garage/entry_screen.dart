import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_formats.dart';
import '../../core/l10n/labels.dart';
import '../../data/database/app_database.dart';
import '../../core/utils/form_draft.dart';
import 'garage_providers.dart';

class EntryScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  final String kind;
  final int? id;
  const EntryScreen(
      {super.key, required this.vehicleId, required this.kind, this.id});
  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      amount = TextEditingController(),
      mileage = TextEditingController(),
      quantity = TextEditingController(),
      place = TextEditingController(),
      note = TextEditingController();
  DateTime date = DateTime.now();

  /// Wartości w bazie — stąd polskie. Tłumaczone są tylko etykiety
  /// (`fuelLabel`, `ledgerCategoryLabel`), nigdy dane w słupkach `fuel`
  /// i `category`, bo po nich liczone jest spalanie i grupowane wydatki.
  String fuel = 'Benzyna', category = 'Inne';
  bool full = true, missed = false, saving = false, loading = true;
  List<String> categories = [...expenseCategoryValues];
  FormDraft? draft;
  bool get fuelEntry => widget.kind == 'FUEL' || widget.kind == 'CHARGE';
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final l = context.l10n, fmt = context.fmt;
    final repo = ref.read(garageRepositoryProvider);
    categories = <String>{
      ...categories,
      ...(await repo.db.select(repo.db.customCategories).get())
          .map((c) => c.name)
    }.toList();
    if (widget.id != null) {
      final row = await (repo.db.select(repo.db.ledgerEntries)
            ..where((e) => e.id.equals(widget.id!)))
          .getSingle();
      if (!mounted) return;
      title.text = row.title;
      amount.text = row.amountCents == null
          ? ''
          : fmt.moneyInput(row.amountCents!);
      mileage.text = row.mileage?.toString() ?? '';
      quantity.text = row.quantity?.toString() ?? '';
      place.text = row.place ?? '';
      note.text = row.note ?? '';
      date = row.date;
      fuel = row.fuel ?? 'Benzyna';
      category = row.category;
      full = row.fullTank;
      missed = row.missed;
      if (!categories.contains(category)) categories.add(category);
    } else {
      // Domyślny tytuł to dane wpisu, więc wolno go przetłumaczyć.
      title.text = switch (widget.kind) {
        'FUEL' => l.addRefuel,
        'CHARGE' => l.addCharge,
        'MILEAGE' => l.mileageReadingLabel,
        _ => ''
      };
    }
    if (!mounted) return;
    draft = FormDraft(
        repo,
        'entry:${widget.vehicleId}:${widget.kind}:${widget.id}',
        {
          'title': title,
          'amount': amount,
          'mileage': mileage,
          'quantity': quantity,
          'place': place,
          'note': note
        },
        extra: () => {
              'date': date.toIso8601String(),
              'fuel': fuel,
              'category': category,
              'full': full,
              'missed': missed
            },
        restoreExtra: (d) {
          date = DateTime.tryParse(d['date'] as String? ?? '') ?? date;
          fuel = d['fuel'] as String? ?? fuel;
          category = d['category'] as String? ?? category;
          full = d['full'] as bool? ?? full;
          missed = d['missed'] as bool? ?? missed;
          if (!categories.contains(category)) categories.add(category);
        });
    await draft!.init();
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    draft?.dispose();
    for (final c in [title, amount, mileage, quantity, place, note]) {
      c.dispose();
    }
    super.dispose();
  }

  void change(VoidCallback fn) {
    setState(fn);
    draft?.changed();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    // Tekst i format pobrane przed `await`ami.
    final l = context.l10n;
    setState(() => saving = true);
    try {
      final fmt = context.fmt;
      final repo = ref.read(garageRepositoryProvider),
          cents = amount.text.trim().isEmpty
              ? null
              : fmt.parseMoney(amount.text);
      final duplicate = await repo.duplicate(
          widget.vehicleId, title.text, date, cents,
          excludeId: widget.id, kind: widget.kind);
      if (duplicate && mounted) {
        final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
                    title: Text(c.l10n.duplicateEntryTitle),
                    content: Text(c.l10n.duplicateEntryBody),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: Text(c.l10n.goBackAction)),
                      FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: Text(c.l10n.saveAnotherAction))
                    ]));
        if (ok != true) return;
      }
      await repo.saveLedger(
          LedgerEntriesCompanion.insert(
              vehicleId: widget.vehicleId,
              kind: widget.kind,
              title: title.text.trim(),
              // Stawki w bazie: 'Energia' i 'Przebieg' to wartości słownikowe.
              category: widget.kind == 'FUEL'
                  ? fuel
                  : widget.kind == 'CHARGE'
                      ? 'Energia'
                      : widget.kind == 'MILEAGE'
                          ? 'Przebieg'
                          : category,
              date: date,
              mileage: Value(int.tryParse(mileage.text.trim())),
              amountCents: Value(cents),
              quantity: Value(fuelEntry
                  ? double.parse(quantity.text.replaceAll(',', '.'))
                  : null),
              fuel: Value(widget.kind == 'FUEL' ? fuel : null),
              fullTank: Value(full),
              missed: Value(missed),
              place: Value(place.text.trim()),
              note: Value(note.text.trim())),
          id: widget.id);
      await draft?.finish();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.entrySaveFailed)));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> remove() async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(context.l10n.deleteEntryTitle),
                content: Text(title.text),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(context.l10n.cancelAction)),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(context.l10n.deleteAction))
                ]));
    if (ok == true) {
      final db = ref.read(garageRepositoryProvider).db;
      await (db.delete(db.ledgerEntries)..where((e) => e.id.equals(widget.id!)))
          .go();
      await draft?.finish();
      if (mounted) context.pop();
    }
  }

  Widget field(TextEditingController c, String label,
          {bool number = false,
          bool decimal = false,
          bool required = false,
          int lines = 1,
          String? Function(String?)? validate}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
              controller: c,
              maxLines: lines,
              keyboardType: number
                  ? TextInputType.numberWithOptions(decimal: decimal)
                  : TextInputType.text,
              decoration: InputDecoration(labelText: label),
              validator: validate ??
                  (v) => required && (v ?? '').trim().isEmpty
                      ? context.l10n.validationRequired
                      : null));
  @override
  Widget build(BuildContext context) {
    final name = switch (widget.kind) {
      'FUEL' => context.l10n.addRefuel,
      'CHARGE' => context.l10n.addCharge,
      'MILEAGE' => context.l10n.mileageLabel,
      _ => context.l10n.addExpense
    };
    return DraftExit(
        busy: saving,
        onLeave: () async =>
            saving ? false : await draft?.leave(context) ?? true,
        child: Scaffold(
            appBar: AppBar(
                title: Text(
                    '${widget.id == null ? context.l10n.newEntryTitle : context.l10n.editAction} · $name'),
                actions: [
                  if (widget.id != null)
                    IconButton(
                        tooltip: context.l10n.deleteEntryTitle,
                        onPressed: saving ? null : remove,
                        icon: const Icon(Icons.delete_outline))
                ]),
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: form,
                    child:
                        ListView(padding: const EdgeInsets.all(20), children: [
                      field(title, context.l10n.csvFieldTitle,
                          required: true),
                      if (widget.kind == 'FUEL')
                        Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField(
                                value: fuel,
                                decoration: InputDecoration(
                                    labelText:
                                        context.l10n.fuelFieldLabel),
                                // Wyborami są surowe wartości z bazy; po polsku
                                // brzmią też po angielsku, więc nie zmieniają danych.
                                items: fuelValues
                                    .map((f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(fuelLabel(context, f))))
                                    .toList(),
                                onChanged: (v) => change(() => fuel = v!))),
                      if (widget.kind == 'EXPENSE')
                        Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField(
                                value: category,
                                isExpanded: true,
                                decoration: InputDecoration(
                                    labelText: context.l10n.categoryField),
                                items: categories
                                    .map((f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(ledgerCategoryLabel(
                                            context, f))))
                                    .toList(),
                                onChanged: (v) => change(() => category = v!))),
                      if (widget.kind != 'MILEAGE')
                        field(
                            amount,
                            context.l10n.amountField(
                                context.fmt.currency.code),
                            number: true,
                            decimal: true,
                            validate: (v) => (v ?? '').trim().isEmpty ||
                                    context.fmt.parseMoney(v!) != null
                                ? null
                                : context
                                    .l10n
                                    .validationAmountPositive),
                      if (fuelEntry)
                        field(
                            quantity,
                            widget.kind == 'FUEL'
                                ? context.l10n.quantityFuelField
                                : context.l10n.quantityEnergyField,
                            number: true,
                            decimal: true, validate: (v) {
                          final n = context.fmt.parseDecimal(v ?? '');
                          return n == null
                              ? context.l10n.validationQuantityPositive
                              : null;
                        }),
                      field(mileage, context.l10n.mileageField,
                          number: true,
                          validate: (v) {
                        if ((v ?? '').trim().isEmpty) {
                          return widget.kind == 'EXPENSE'
                              ? null
                              : context.l10n.validationRequired;
                        }
                        final n = int.tryParse(v!.trim());
                        return n == null || n < 0
                            ? context.l10n.validationMileageNonNegative
                            : null;
                      }),
                      Card(
                          child: ListTile(
                              leading: const Icon(Icons.event_outlined),
                              title: Text(context.l10n.dateFieldLabel),
                              subtitle:
                                  Text(context.fmt.dateLong(date)),
                              onTap: () async {
                                final d = await showDatePicker(
                                    context: context,
                                    initialDate: date,
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime.now());
                                if (d != null) change(() => date = d);
                              })),
                      if (widget.kind == 'FUEL') ...[
                        SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(context.l10n.fullTankSwitch),
                            subtitle:
                                Text(context.l10n.fullTankSwitchSub),
                            value: full,
                            onChanged: (v) => change(() => full = v)),
                        SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title:
                                Text(context.l10n.missedTankSwitch),
                            subtitle:
                                Text(context.l10n.missedTankSwitchSub),
                            value: missed,
                            onChanged: (v) => change(() => missed = v))
                      ],
                      ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(context.l10n.detailsSection),
                          children: [
                            field(
                                place,
                                fuelEntry
                                    ? context.l10n.placeFuelField
                                    : context.l10n.placeField),
                            field(note, context.l10n.noteField, lines: 3)
                          ]),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                          onPressed: saving ? null : save,
                          icon: const Icon(Icons.check),
                          label: Text(saving
                              ? context.l10n.savingLabel
                              : context.l10n.saveEntryAction)),
                      const SizedBox(height: 24)
                    ]))));
  }
}
