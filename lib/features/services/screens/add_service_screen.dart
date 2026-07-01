import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/file_helper.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/service_type_chip.dart';
import '../../services/providers/service_providers.dart';
import '../../vehicles/providers/vehicle_providers.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  final int? serviceId;
  const AddServiceScreen(
      {super.key, required this.vehicleId, this.serviceId});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _workshopCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  ServiceType _type = ServiceType.other;
  bool _saving = false;

  // Pending attachments to add (before save)
  final List<_PendingAttachment> _pending = [];
  // Existing attachments (edit mode)
  List<Attachment> _existing = [];
  // IDs to delete (edit mode)
  final Set<int> _toDelete = {};

  bool get _isEdit => widget.serviceId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(serviceRepositoryProvider);
    final s = await repo.getById(widget.serviceId!);
    final atts = await repo.getAttachments(widget.serviceId!);
    setState(() {
      _titleCtrl.text = s.title;
      _descCtrl.text = s.description ?? '';
      _mileageCtrl.text = s.mileage?.toString() ?? '';
      _costCtrl.text = s.cost?.toStringAsFixed(2) ?? '';
      _workshopCtrl.text = s.workshop ?? '';
      _date = s.serviceDate;
      _type = ServiceType.fromValue(s.serviceType);
      _existing = atts;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _mileageCtrl.dispose();
    _costCtrl.dispose();
    _workshopCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _addPhoto() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dodaj zdjęcie'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Aparat'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (picked != null) {
      setState(() => _pending.add(_PendingAttachment(
          path: picked.path,
          name: picked.name,
          type: 'IMAGE')));
    }
  }

  Future<void> _addPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final f = result.files.single;
      setState(() => _pending.add(_PendingAttachment(
          path: f.path!, name: f.name, type: 'PDF')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final svcRepo = ref.read(serviceRepositoryProvider);
      final vehRepo = ref.read(vehicleRepositoryProvider);

      final mileage = int.tryParse(_mileageCtrl.text);
      final cost = double.tryParse(_costCtrl.text.replaceAll(',', '.'));

      int serviceId;

      if (_isEdit) {
        serviceId = widget.serviceId!;
        await svcRepo.update(ServiceRecordsCompanion(
          id: Value(serviceId),
          vehicleId: Value(widget.vehicleId),
          title: Value(_titleCtrl.text.trim()),
          description: Value(_descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim()),
          serviceDate: Value(_date),
          mileage: Value(mileage),
          cost: Value(cost),
          serviceType: Value(_type.value),
          workshop: Value(_workshopCtrl.text.trim().isEmpty
              ? null
              : _workshopCtrl.text.trim()),
        ));
        // Delete marked attachments
        for (final id in _toDelete) {
          final att = _existing.firstWhere((a) => a.id == id);
          await FileHelper.deleteFile(att.filePath);
          await svcRepo.deleteAttachment(id);
        }
      } else {
        serviceId = await svcRepo.insert(ServiceRecordsCompanion.insert(
          vehicleId: widget.vehicleId,
          title: _titleCtrl.text.trim(),
          description: Value(_descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim()),
          serviceDate: _date,
          mileage: Value(mileage),
          cost: Value(cost),
          serviceType: Value(_type.value),
          workshop: Value(_workshopCtrl.text.trim().isEmpty
              ? null
              : _workshopCtrl.text.trim()),
        ));
      }

      // Copy pending attachments
      for (final att in _pending) {
        final dest = await FileHelper.copyServiceAttachment(
            att.path, serviceId, att.name);
        await svcRepo.insertAttachment(AttachmentsCompanion.insert(
          serviceRecordId: serviceId,
          filePath: dest,
          fileType: att.type,
          fileName: att.name,
        ));
      }

      // Update vehicle mileage if new mileage is higher
      if (mileage != null) {
        final v = await vehRepo.getById(widget.vehicleId);
        if (mileage > v.currentMileage) {
          await vehRepo.updateFields(
            widget.vehicleId,
            VehiclesCompanion(currentMileage: Value(mileage)),
          );
        }
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Błąd: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edytuj serwis' : 'Nowy serwis'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tytuł',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wymagane' : null,
            ),
            const SizedBox(height: 16),
            Text('Typ serwisu',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ServiceType.values.map((t) {
                final selected = _type == t;
                return FilterChip(
                  avatar: Icon(t.icon, size: 16),
                  label: Text(t.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _type = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data serwisu',
                  prefixIcon: Icon(Icons.event),
                ),
                child: Text(DateFormat('d MMMM yyyy', 'pl_PL').format(_date)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mileageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Przebieg (km)',
                      prefixIcon: Icon(Icons.speed),
                    ),
                    validator: (v) {
                      if (v != null && v.isNotEmpty && int.tryParse(v) == null) {
                        return 'Podaj liczbę';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Koszt (zł)',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final d = double.tryParse(v.replaceAll(',', '.'));
                        if (d == null) return 'Nieprawidłowa kwota';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _workshopCtrl,
              decoration: const InputDecoration(
                labelText: 'Warsztat (opcjonalnie)',
                prefixIcon: Icon(Icons.store_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Opis (opcjonalnie)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Text('Załączniki',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // Existing attachments (edit mode)
            ..._existing
                .where((a) => !_toDelete.contains(a.id))
                .map((a) => _AttachmentTile(
                      name: a.fileName,
                      type: a.fileType,
                      onDelete: () =>
                          setState(() => _toDelete.add(a.id)),
                    )),
            // Pending new attachments
            ..._pending.asMap().entries.map((e) => _AttachmentTile(
                  name: e.value.name,
                  type: e.value.type,
                  onDelete: () =>
                      setState(() => _pending.removeAt(e.key)),
                )),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addPhoto,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Zdjęcie'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addPdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('PDF / Faktura'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isEdit ? 'Zapisz zmiany' : 'Dodaj wpis'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingAttachment {
  final String path;
  final String name;
  final String type;
  const _PendingAttachment(
      {required this.path, required this.name, required this.type});
}

class _AttachmentTile extends StatelessWidget {
  final String name;
  final String type;
  final VoidCallback onDelete;

  const _AttachmentTile(
      {required this.name, required this.type, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        type == 'PDF' ? Icons.picture_as_pdf : Icons.image_outlined,
        color: type == 'PDF' ? Colors.red : Colors.blue,
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onDelete,
      ),
    );
  }
}
