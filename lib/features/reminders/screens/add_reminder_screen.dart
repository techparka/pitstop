import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_formats.dart';
import '../../../core/utils/form_draft.dart';
import '../../../data/database/app_database.dart';
import '../../garage/garage_providers.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  final int? reminderId;
  const AddReminderScreen(
      {super.key, required this.vehicleId, this.reminderId});
  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      note = TextEditingController(),
      mileage = TextEditingController(),
      months = TextEditingController(),
      interval = TextEditingController();
  DateTime? date;
  bool saving = false, loading = true;
  String type = 'OTHER';
  FormDraft? draft;
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final repo = ref.read(garageRepositoryProvider), db = repo.db;
    if (widget.reminderId != null) {
      final r = await (db.select(db.reminders)
            ..where((r) => r.id.equals(widget.reminderId!)))
          .getSingleOrNull();
      if (!mounted) return;
      if (r == null) {
        context.pop();
        return;
      }
      title.text = r.title;
      note.text = r.note ?? '';
      mileage.text = r.dueMileage?.toString() ?? '';
      months.text = r.intervalMonths?.toString() ?? '';
      interval.text = r.intervalKm?.toString() ?? '';
      date = r.dueDate;
      type = r.serviceType;
    }
    if (!mounted) return;
    draft = FormDraft(
        repo,
        'reminder:${widget.vehicleId}:${widget.reminderId}',
        {
          'title': title,
          'note': note,
          'mileage': mileage,
          'months': months,
          'interval': interval
        },
        extra: () => {'date': date?.toIso8601String(), 'type': type},
        restoreExtra: (d) {
          date = DateTime.tryParse(d['date'] as String? ?? '');
          type = d['type'] as String? ?? type;
        });
    await draft!.init();
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    draft?.dispose();
    for (final c in [title, note, mileage, months, interval]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    final l = context.l10n;
    if (date == null && mileage.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.reminderNeedsDateOrMileage)));
      return;
    }
    setState(() => saving = true);
    try {
      final db = ref.read(garageRepositoryProvider).db;
      final entry = RemindersCompanion(
          vehicleId: Value(widget.vehicleId),
          title: Value(title.text.trim()),
          note: Value(note.text.trim()),
          dueDate: Value(date),
          dueMileage: Value(int.tryParse(mileage.text.trim())),
          intervalMonths: Value(int.tryParse(months.text.trim())),
          intervalKm: Value(int.tryParse(interval.text.trim())),
          serviceType: Value(type));
      if (widget.reminderId == null) {
        await db.into(db.reminders).insert(entry);
      } else {
        await (db.update(db.reminders)
              ..where((r) => r.id.equals(widget.reminderId!)))
            .write(entry);
      }
      await draft?.finish();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.reminderSaveFailed)));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget field(TextEditingController c, String label,
          {bool number = false,
          bool positive = false,
          int lines = 1,
          bool required = false}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
              controller: c,
              maxLines: lines,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(labelText: label),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) {
                  return required ? context.l10n.validationRequired : null;
                }
                if (number) {
                  final n = int.tryParse(v!.trim());
                  if (n == null ||
                      n < (positive ? 1 : 0) ||
                      (c == months && n > 120)) {
                    if (!positive) {
                      return context.l10n.validationNonNegativeNumber;
                    }
                    return c == months
                        ? context.l10n.validationPositiveNumberUpTo(120)
                        : context.l10n.validationPositiveNumber;
                  }
                }
                return null;
              }));
  @override
  Widget build(BuildContext context) => DraftExit(
      busy: saving,
      onLeave: () async => saving ? false : await draft?.leave(context) ?? true,
      child: Scaffold(
          appBar: AppBar(
              title: Text(widget.reminderId == null
                  ? context.l10n.newReminderTitle
                  : context.l10n.editReminderTitle)),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: form,
                  child: ListView(padding: const EdgeInsets.all(20), children: [
                    Wrap(
                        spacing: 8,
                        children: [
                          // Gotowe tytuły to dane terminu, więc wolno je tłumaczyć.
                          context.l10n.serviceTypeOilChange,
                          context.l10n.reminderPresetInspection,
                          context.l10n.reminderPresetOc,
                          context.l10n.reminderPresetAc,
                          context.l10n.reminderPresetTires
                        ]
                            .map((t) => ActionChip(
                                label: Text(t),
                                onPressed: () => title.text = t))
                            .toList()),
                    const SizedBox(height: 16),
                    field(title, context.l10n.reminderTitleField,
                        required: true),
                    Card(
                        child: ListTile(
                            leading: const Icon(Icons.event_outlined),
                            title: Text(context.l10n.dateFieldLabel),
                            subtitle: Text(date == null
                                ? context.l10n.selectDateAction
                                : context.fmt.dateLong(date!)),
                            trailing: date == null
                                ? null
                                : IconButton(
                                    tooltip:
                                        context.l10n.removeDateTooltip,
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() => date = null);
                                      draft?.changed();
                                    }),
                            onTap: () async {
                              final d = await showDatePicker(
                                  context: context,
                                  initialDate: date ??
                                      DateTime.now()
                                          .add(const Duration(days: 30)),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365 * 10)));
                              if (d != null) {
                                setState(() => date = d);
                                draft?.changed();
                              }
                            })),
                    const SizedBox(height: 8),
                    field(mileage, context.l10n.targetMileageField,
                        number: true),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child:
                            Text(context.l10n.reminderConditionsHint)),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        initiallyExpanded:
                            months.text.isNotEmpty || interval.text.isNotEmpty,
                        title: Text(context.l10n.repeatSection),
                        subtitle: Text(context.l10n.repeatSectionSub),
                        children: [
                          field(months, context.l10n.everyMonthsField,
                              number: true, positive: true),
                          field(interval, context.l10n.everyKmField,
                              number: true, positive: true)
                        ]),
                    const SizedBox(height: 16),
                    field(note, context.l10n.noteOptionalField, lines: 3),
                    FilledButton.icon(
                        onPressed: saving ? null : save,
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: Text(saving
                            ? context.l10n.savingLabel
                            : context.l10n.saveReminderAction)),
                    const SizedBox(height: 24)
                  ]))));
}
