import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/l10n/app_formats.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/utils/file_helper.dart';
import '../../../core/utils/form_draft.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/service_type_chip.dart';
import '../../garage/garage_providers.dart';
import '../providers/service_providers.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  final int? serviceId;
  const AddServiceScreen({super.key, required this.vehicleId, this.serviceId});
  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _Item {
  final TextEditingController name, cost;
  String kind;
  // Domyślna wartość to słownik bazy (`service_items.kind`), a nie etykieta.
  // Polskie brzmienie tłumaczy `itemKindLabel`, lista wartości: `itemKindValues`.
  _Item({String name = '', String cost = '', this.kind = 'Część'})
      : name = TextEditingController(text: name),
        cost = TextEditingController(text: cost);
  void dispose() {
    name.dispose();
    cost.dispose();
  }
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      desc = TextEditingController(),
      mileage = TextEditingController(),
      cost = TextEditingController(),
      workshop = TextEditingController();
  DateTime date = DateTime.now();
  String category = 'OTHER';
  bool saving = false, loading = true;
  List<Attachment> existing = [];
  Set<int> removed = {};
  List<({String path, String name, String type})> pending = [];
  List<_Item> items = [];
  List<ServiceRecord> previous = [];
  List<String> custom = [];
  FormDraft? draft;
  /// Kwota w groszach waluty bazowej. Pole może być w walucie pokazowej,
  /// dlatego przeliczenia dokonuje `AppFormats`, a nie `Money` wprost.
  int? get cents => items.isEmpty
      ? context.fmt.parseMoney(cost.text)
      : items.fold<int>(
          0, (sum, i) => sum + (context.fmt.parseMoney(i.cost.text) ?? 0));
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // Formaty i teksty brane przed `await`ami — po nich kontekst może już
    // nie należeć do żywego widżetu.
    final fmt = context.fmt, l = context.l10n;
    final repo = ref.read(garageRepositoryProvider),
        svc = ref.read(serviceRepositoryProvider),
        db = repo.db;
    try {
      previous = await (db.select(db.serviceRecords)
            ..where((s) => s.vehicleId.equals(widget.vehicleId)))
          .get();
      custom = (await db.select(db.customCategories).get())
          .map((c) => c.name)
          .toList();
      if (widget.serviceId != null) {
        final s = await svc.getById(widget.serviceId!);
        if (!mounted) return;
        title.text = s.title;
        desc.text = s.description ?? '';
        mileage.text = s.mileage?.toString() ?? '';
        cost.text =
            s.costCents == null ? '' : fmt.moneyInput(s.costCents!);
        workshop.text = s.workshop ?? '';
        date = s.serviceDate;
        category = s.serviceType;
        existing = await svc.getAttachments(s.id);
        final rows = await (db.select(db.serviceItems)
              ..where((i) => i.serviceId.equals(s.id)))
            .get();
        items = rows
            .map((i) => _Item(
                name: i.name,
                cost: fmt.moneyInput(i.amountCents),
                kind: i.kind))
            .toList();
      }
      if (!mounted) return;
      draft = FormDraft(
          repo,
          'service:${widget.vehicleId}:${widget.serviceId}',
          {
            'title': title,
            'desc': desc,
            'mileage': mileage,
            'cost': cost,
            'workshop': workshop
          },
          extra: () => {
                'date': date.toIso8601String(),
                'category': category,
                'pending': pending
                    .map(
                        (a) => {'path': a.path, 'name': a.name, 'type': a.type})
                    .toList(),
                'removed': removed.toList(),
                'items': items
                    .map((i) => {
                          'name': i.name.text,
                          'cost': i.cost.text,
                          'kind': i.kind
                        })
                    .toList()
              },
          restoreExtra: (d) {
            date = DateTime.tryParse(d['date'] as String? ?? '') ?? date;
            category = d['category'] as String? ?? category;
            removed = (d['removed'] as List? ?? []).cast<int>().toSet();
            pending = (d['pending'] as List? ?? [])
                .map((a) => (
                      path: a['path'] as String,
                      name: a['name'] as String,
                      type: a['type'] as String
                    ))
                .where((a) => File(a.path).existsSync())
                .toList();
            for (final i in items) {
              i.dispose();
            }
            items = (d['items'] as List? ?? [])
                .map((i) => _Item(
                    name: i['name'] as String,
                    cost: i['cost'] as String,
                    kind: i['kind'] as String))
                .toList();
          });
      await draft!.init();
      for (final i in items) {
        listen(i);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.serviceLoadFailed)));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  void listen(_Item i) {
    i.name.addListener(changed);
    i.cost.addListener(changed);
  }

  void changed() {
    if (mounted) setState(() {});
    draft?.changed();
  }

  @override
  void dispose() {
    draft?.dispose();
    for (final c in [title, desc, mileage, cost, workshop]) {
      c.dispose();
    }
    for (final i in items) {
      i.dispose();
    }
    super.dispose();
  }

  Future<void> photo() async {
    final l = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
        context: context,
        showDragHandle: true,
        builder: (c) => SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(c.l10n.takePhotoAction),
                  onTap: () => Navigator.pop(c, ImageSource.camera)),
              ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(c.l10n.fromGalleryAction),
                  onTap: () => Navigator.pop(c, ImageSource.gallery))
            ])));
    if (source == null) return;
    try {
      final image = await ImagePicker()
          .pickImage(source: source, maxWidth: 1800, imageQuality: 85);
      if (image != null) {
        final path = await FileHelper.prepareAttachment(image.path);
        if (mounted) {
          pending.add((path: path, name: image.name, type: 'IMAGE'));
          changed();
        }
      }
    } catch (e) {
      failureIfMounted(l.photoAddFailed);
    }
  }

  Future<void> pickInvoice() async {
    final l = context.l10n;
    try {
      final files = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', ...FileHelper.invoiceImageExtensions],
      );
      final file = files?.files.single;
      final sourcePath = file?.path;
      if (file == null || sourcePath == null) return;

      final path = await FileHelper.prepareAttachment(sourcePath);
      if (!mounted) return;
      pending.add((
        path: path,
        name: file.name,
        type: FileHelper.isInvoiceImagePath(file.name) ||
                FileHelper.isInvoiceImagePath(sourcePath)
            ? 'INVOICE_IMAGE'
            : 'PDF',
      ));
      changed();
    } catch (e) {
      failureIfMounted(l.invoiceAddFailed);
    }
  }

  /// Komunikat tylko gdy widżet wciąż żyje — formularz przeżywa błąd zapisu.
  void failureIfMounted(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    final l = context.l10n, fmt = context.fmt;
    setState(() => saving = true);
    try {
      final repo = ref.read(garageRepositoryProvider);
      if (await repo.duplicate(widget.vehicleId, title.text, date, cents,
              excludeId: widget.serviceId) &&
          mounted) {
        final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
                    title: Text(l.duplicateServiceTitle),
                    content: Text(l.duplicateServiceBody),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: Text(l.goBackAction)),
                      FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: Text(l.saveAnotherAction))
                    ]));
        if (ok != true) return;
      }
      await ref.read(serviceRepositoryProvider).save(
          ServiceRecordsCompanion(
              id: widget.serviceId == null
                  ? const Value.absent()
                  : Value(widget.serviceId!),
              vehicleId: Value(widget.vehicleId),
              title: Value(title.text.trim()),
              description:
                  Value(desc.text.trim().isEmpty ? null : desc.text.trim()),
              serviceDate: Value(date),
              mileage: Value(int.tryParse(mileage.text.trim())),
              cost: Value(cents == null ? null : cents! / 100),
              costCents: Value(cents),
              serviceType: Value(category),
              workshop: Value(
                  workshop.text.trim().isEmpty ? null : workshop.text.trim())),
          isEdit: widget.serviceId != null,
          attachments: pending,
          deleteAttachmentIds: removed,
          items: items
              .map((i) => (
                    name: i.name.text.trim(),
                    kind: i.kind,
                    cents: fmt.parseMoney(i.cost.text)!
                  ))
              .toList());
      await draft?.finish();
      for (final a in pending) {
        try {
          await FileHelper.deleteFile(a.path);
        } on FileSystemException {/* temporary copy */}
      }
      if (mounted) context.pop();
    } catch (e) {
      failureIfMounted(l.serviceSaveFailed);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  /// Pole tekstowe; walidacja zwraca kod błędu, a tekst dopiero tu trafia do
  /// bieżącego języka — stąd `String Function(String?)?` zamiast tekstu.
  Widget field(TextEditingController c, String label,
          {bool number = false,
          bool decimal = false,
          int lines = 1,
          String? Function(String?)? validator,
          bool enabled = true}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
              controller: c,
              enabled: enabled,
              keyboardType: number
                  ? TextInputType.numberWithOptions(decimal: decimal)
                  : TextInputType.text,
              maxLines: lines,
              decoration: InputDecoration(labelText: label),
              validator: validator));
  @override
  Widget build(BuildContext context) {
    final cats = {
      for (final t in ServiceType.values) t.value: t.label(context),
      for (final c in custom) c: c
    };
    // Szablony to gotowe tytuły wraz z kategorią, jaką mają ustawić. Wcześniejsze
    // rozpoznawanie po polskich słowach w tytule ('oleju', 'opon') nie przeżyło
    // angielskiej wersji językowej.
    final templates = {
      context.l10n.templateOilChange: 'OIL_CHANGE',
      context.l10n.templateTires: 'TIRES',
      context.l10n.templateInspection: 'INSPECTION',
    };
    if (!cats.containsKey(category)) cats[category] = category;
    return DraftExit(
        busy: saving,
        onLeave: () async =>
            saving ? false : await draft?.leave(context) ?? true,
        child: Scaffold(
            appBar: AppBar(
                title: Text(widget.serviceId == null
                    ? context.l10n.newServiceTitle
                    : context.l10n.editServiceTitle)),
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: form,
                    child:
                        ListView(padding: const EdgeInsets.all(20), children: [
                      if (widget.serviceId == null)
                        PopupMenuButton<String>(
                            tooltip: context.l10n.templateTooltip,
                            onSelected: (v) {
                              final matches =
                                  previous.where((s) => s.title == v);
                              if (matches.isNotEmpty) {
                                final s = matches.last;
                                title.text = s.title;
                                desc.text = s.description ?? '';
                                workshop.text = s.workshop ?? '';
                                cost.text = s.costCents == null
                                    ? ''
                                    : context.fmt
                                        .moneyInput(s.costCents!);
                                category = s.serviceType;
                              } else {
                                title.text = v;
                                category = templates[v] ?? 'INSPECTION';
                              }
                              changed();
                            },
                            itemBuilder: (c) => {
                                  ...templates.keys,
                                  ...previous.map((s) => s.title)
                                }
                                    .take(30)
                                    .map((s) =>
                                        PopupMenuItem(value: s, child: Text(s)))
                                    .toList(),
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Row(children: [
                                  const Icon(Icons.auto_awesome_outlined),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(
                                          context.l10n.useTemplateAction))
                                ]))),
                      field(title, context.l10n.serviceTitleField,
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? context.l10n.validationTitleRequired
                              : null),
                      DropdownButtonFormField<String>(
                          value: category,
                          isExpanded: true,
                          decoration: InputDecoration(
                              labelText: context.l10n.categoryField),
                          items: cats.entries
                              .map((e) => DropdownMenuItem(
                                  value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (v) {
                            category = v!;
                            changed();
                          }),
                      const SizedBox(height: 16),
                      Card(
                          child: ListTile(
                              leading: const Icon(Icons.event_outlined),
                              title: Text(context.l10n.serviceDateField),
                              subtitle:
                                  Text(context.fmt.dateLong(date)),
                              onTap: () async {
                                final d = await showDatePicker(
                                    context: context,
                                    initialDate: date,
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime.now());
                                if (d != null) {
                                  date = d;
                                  changed();
                                }
                              })),
                      const SizedBox(height: 4),
                      field(mileage, context.l10n.mileageField,
                          number: true,
                          validator: (v) {
                        if ((v ?? '').trim().isEmpty) return null;
                        final n = int.tryParse(v!.trim());
                        return n == null || n < 0
                            ? context.l10n.validationMileageNonNegative
                            : null;
                      }),
                      if (items.isEmpty)
                        field(
                            cost,
                            context.l10n.costField(
                                context.fmt.currency.code),
                            number: true,
                            decimal: true,
                            validator: (v) => (v ?? '').trim().isEmpty ||
                                    context.fmt.parseMoney(v!) != null
                                ? null
                                : context.l10n.validationAmount)
                      else
                        Card(
                            child: ListTile(
                                title:
                                    Text(context.l10n.partsTotalLabel),
                                trailing: Text(context.fmt.money(cents ?? 0),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge))),
                      ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          initiallyExpanded: items.isNotEmpty,
                          title: Text(context.l10n.serviceItemsSection),
                          subtitle: Text(context.l10n.partsSectionSub),
                          children: [
                            ...items.asMap().entries.map((e) => Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(children: [
                                      Row(children: [
                                        Expanded(
                                            child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: e.value.kind,
                                                // Wartość w bazie zostaje polska,
                                                // tłumaczymy tylko etykietę.
                                                items: itemKindValues
                                                    .map((k) => DropdownMenuItem(
                                                        value: k,
                                                        child: Text(itemKindLabel(
                                                            context, k))))
                                                    .toList(),
                                                onChanged: (v) {
                                                  e.value.kind = v!;
                                                  changed();
                                                })),
                                        IconButton(
                                            tooltip:
                                                context.l10n.removeItemTooltip,
                                            onPressed: () {
                                              final i = items.removeAt(e.key);
                                              i.dispose();
                                              changed();
                                            },
                                            icon: const Icon(Icons.close))
                                      ]),
                                      field(e.value.name,
                                          context.l10n.itemNameField,
                                          validator: (v) =>
                                              (v ?? '').trim().isEmpty
                                                  ? context
                                                      .l10n.validationRequired
                                                  : null),
                                      field(
                                          e.value.cost,
                                          context.l10n.itemCostField(
                                              context.fmt.currency.code),
                                          number: true,
                                          decimal: true,
                                          validator: (v) =>
                                              context.fmt.parseMoney(v ?? '') ==
                                                      null
                                                  ? context.l10n
                                                      .validationAmountRequired
                                                  : null)
                                    ])))),
                            TextButton.icon(
                                onPressed: () {
                                  final i = _Item();
                                  listen(i);
                                  items.add(i);
                                  changed();
                                },
                                icon: const Icon(Icons.add),
                                label: Text(context.l10n.addItemAction))
                          ]),
                      ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(context.l10n.workshopAndDescription),
                          initiallyExpanded:
                              workshop.text.isNotEmpty || desc.text.isNotEmpty,
                          children: [
                            field(workshop, context.l10n.workshopLabel),
                            if (previous
                                .any((s) => (s.workshop ?? '').isNotEmpty))
                              Wrap(
                                  spacing: 8,
                                  children: previous
                                      .map((s) => s.workshop)
                                      .whereType<String>()
                                      .where((s) => s.isNotEmpty)
                                      .toSet()
                                      .take(6)
                                      .map((s) => ActionChip(
                                          label: Text(s),
                                          onPressed: () => workshop.text = s))
                                      .toList()),
                            field(desc, context.l10n.descriptionField,
                                lines: 3)
                          ]),
                      const SizedBox(height: 20),
                      Text(context.l10n.photosAndInvoices,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...existing.where((a) => !removed.contains(a.id)).map(
                          (a) => ListTile(
                              leading: Icon(a.fileType == 'PDF' &&
                                      !FileHelper.isInvoiceImagePath(
                                          a.fileName) &&
                                      !FileHelper.isInvoiceImagePath(a.filePath)
                                  ? Icons.picture_as_pdf_outlined
                                  : Icons.image_outlined),
                              title: Text(a.fileName),
                              trailing: IconButton(
                                  tooltip:
                                      context.l10n.removeAttachmentTooltip,
                                  onPressed: () {
                                    removed.add(a.id);
                                    changed();
                                  },
                                  icon: const Icon(Icons.close)))),
                      ...pending.asMap().entries.map((e) => ListTile(
                          leading: Icon(e.value.type == 'PDF'
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined),
                          title: Text(e.value.name),
                          trailing: IconButton(
                              tooltip:
                                  context.l10n.removeAttachmentTooltip,
                              onPressed: () {
                                pending.removeAt(e.key);
                                changed();
                              },
                              icon: const Icon(Icons.close)))),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        OutlinedButton.icon(
                            onPressed: photo,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: Text(context.l10n.photoAction)),
                        OutlinedButton.icon(
                            onPressed: pickInvoice,
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: Text(context.l10n.invoiceAction))
                      ]),
                      const SizedBox(height: 30),
                      FilledButton.icon(
                          onPressed: saving ? null : save,
                          icon: const Icon(Icons.check),
                          label: Text(saving
                              ? context.l10n.savingLabel
                              : context.l10n.saveServiceAction)),
                      const SizedBox(height: 24)
                    ]))));
  }
}
