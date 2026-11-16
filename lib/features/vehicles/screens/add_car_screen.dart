import 'dart:io';
import '../../../core/utils/form_draft.dart';
import '../../garage/garage_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:drift/drift.dart' show Value;

import '../../../core/l10n/app_formats.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/utils/file_helper.dart';
import '../../../data/database/app_database.dart';
import '../providers/vehicle_providers.dart';

class AddCarScreen extends ConsumerStatefulWidget {
  final int? vehicleId;
  const AddCarScreen({super.key, this.vehicleId});

  @override
  ConsumerState<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends ConsumerState<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController(text: '0');

  final _vinCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  /// Napęd jest zapisywany jako wartość słownikowa, patrz `powertrainLabel`.
  String _powertrain = 'Benzyna';
  DateTime? _purchaseDate;
  FormDraft? _draft;
  String? _photoPath;
  bool _saving = false;
  Vehicle? _existing;

  bool get _isEdit => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isEdit) await _loadExisting();
    if (!mounted) return;
    _draft = FormDraft(
        ref.read(garageRepositoryProvider),
        'vehicle:${widget.vehicleId}',
        {
          'name': _nameCtrl,
          'make': _makeCtrl,
          'model': _modelCtrl,
          'year': _yearCtrl,
          'plate': _plateCtrl,
          'mileage': _mileageCtrl,
          'vin': _vinCtrl,
          'notes': _notesCtrl
        },
        extra: () => {
              'powertrain': _powertrain,
              'purchaseDate': _purchaseDate?.toIso8601String(),
              'photo': _photoPath
            },
        restoreExtra: (d) {
          _powertrain = d['powertrain'] as String? ?? _powertrain;
          _purchaseDate = DateTime.tryParse(d['purchaseDate'] as String? ?? '');
          _photoPath = d['photo'] as String? ?? _photoPath;
        });
    await _draft!.init();
    if (mounted) setState(() {});
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(vehicleRepositoryProvider);
    final v = await repo.getById(widget.vehicleId!);
    if (!mounted) return;
    setState(() {
      _existing = v;
      _vinCtrl.text = v.vin ?? '';
      _notesCtrl.text = v.technicalNotes ?? '';
      _powertrain = v.powertrain;
      _purchaseDate = v.purchaseDate;
      _nameCtrl.text = v.name;
      _makeCtrl.text = v.make;
      _modelCtrl.text = v.model;
      _yearCtrl.text = v.year.toString();
      _plateCtrl.text = v.licensePlate ?? '';
      _mileageCtrl.text = v.currentMileage.toString();
      _photoPath = v.photoPath;
    });
  }

  @override
  void dispose() {
    _draft?.dispose();
    _vinCtrl.dispose();
    _notesCtrl.dispose();
    _nameCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog();
    if (source == null) return;
    final picked = await picker.pickImage(
        source: source, maxWidth: 1200, imageQuality: 85);
    if (picked != null) {
      final path = await FileHelper.prepareAttachment(picked.path);
      if (mounted) {
        setState(() => _photoPath = path);
        _draft?.changed();
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.addPhotoDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(ctx.l10n.cameraSource),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(ctx.l10n.gallerySource),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l = context.l10n;
    setState(() => _saving = true);
    try {
      final db = ref.read(garageRepositoryProvider).db;
      final value = int.parse(_mileageCtrl.text);
      final entry = VehiclesCompanion(
          name: Value(_nameCtrl.text.trim()),
          make: Value(_makeCtrl.text.trim()),
          model: Value(_modelCtrl.text.trim()),
          year: Value(int.parse(_yearCtrl.text)),
          licensePlate: Value(
              _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim()),
          photoPath: Value(_photoPath),
          currentMileage: Value(value),
          vin: Value(_vinCtrl.text.trim().isEmpty
              ? null
              : _vinCtrl.text.trim().toUpperCase()),
          powertrain: Value(_powertrain),
          purchaseDate: Value(_purchaseDate),
          technicalNotes: Value(_notesCtrl.text.trim()));
      await db.transaction(() async {
        final id = widget.vehicleId ?? await db.into(db.vehicles).insert(entry);
        if (_isEdit) {
          await (db.update(db.vehicles)..where((v) => v.id.equals(id)))
              .write(entry);
        }
        if (!_isEdit || value != _existing?.currentMileage) {
          await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
              vehicleId: id,
              kind: 'MILEAGE',
              title: l.mileageReadingLabel,
              // 'Przebieg' to wartość słownikowa kategorii, nie tekst UI.
              category: 'Przebieg',
              date: DateTime.now(),
              mileage: Value(value)));
        }
      });
      await _draft?.finish();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.vehicleSaveFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraftExit(
        busy: _saving,
        onLeave: () async =>
            _saving ? false : await _draft?.leave(context) ?? true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                _isEdit ? context.l10n.editCarTitle : context.l10n.newCarTitle),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PhotoPicker(
                  photoPath: _photoPath,
                  onTap: _pickPhoto,
                ),
                const SizedBox(height: 24),
                _field(_nameCtrl, context.l10n.vehicleNameField,
                    icon: Icons.label_outline, validator: _required),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(_makeCtrl, context.l10n.vehicleMakeField,
                          icon: Icons.business, validator: _required),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_modelCtrl, context.l10n.vehicleModelField,
                          icon: Icons.directions_car, validator: _required),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _yearCtrl,
                        context.l10n.vehicleYearField,
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return context.l10n.validationRequired;
                          }
                          final y = int.tryParse(v);
                          if (y == null || y < 1886 || y > 2100) {
                            return context.l10n.validationInvalidYear;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        _plateCtrl,
                        context.l10n.vehiclePlateField,
                        icon: Icons.credit_card,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(
                  _mileageCtrl,
                  context.l10n.vehicleMileageField,
                  icon: Icons.speed,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return context.l10n.validationRequired;
                    }
                    if (int.tryParse(v) == null) {
                      return context.l10n.validationMileageNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                    value: _powertrain,
                    decoration:
                        InputDecoration(labelText: context.l10n.powertrainField),
                    // Wyborem jest surowa wartość z bazy, etykieta jest tłumaczona.
                    items: powertrainValues
                        .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(powertrainLabel(context, v))))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _powertrain = v!);
                      _draft?.changed();
                    }),
                const SizedBox(height: 16),
                ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(context.l10n.vehicleTechSection),
                    children: [
                      _field(_vinCtrl, 'VIN',
                          icon: Icons.fingerprint,
                          validator: (v) => (v ?? '').isEmpty ||
                                  RegExp(r'^[A-HJ-NPR-Z0-9]{17}$')
                                      .hasMatch(v!.toUpperCase())
                              ? null
                              : context.l10n.validationVinLength),
                      const SizedBox(height: 12),
                      _field(_notesCtrl, context.l10n.technicalNotesField,
                          icon: Icons.notes),
                      ListTile(
                          title: Text(context.l10n.purchaseDateField),
                          subtitle: Text(_purchaseDate == null
                              ? context.l10n.notSetLabel
                              : context.fmt.dateNum(_purchaseDate!)),
                          onTap: () async {
                            final d = await showDatePicker(
                                context: context,
                                initialDate: _purchaseDate ?? DateTime.now(),
                                firstDate: DateTime(1990),
                                lastDate: DateTime.now());
                            if (d != null) {
                              setState(() => _purchaseDate = d);
                              _draft?.changed();
                            }
                          }),
                    ]),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_isEdit
                      ? context.l10n.saveChangesAction
                      : context.l10n.addCarAction),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        validator: validator,
      );

  String? _required(String? v) => (v == null || v.trim().isEmpty)
      ? context.l10n.validationRequired
      : null;
}

class _PhotoPicker extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onTap;
  const _PhotoPicker({this.photoPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(photoPath!), fit: BoxFit.cover),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'photo_fab',
                      onPressed: onTap,
                      child: const Icon(Icons.edit),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      size: 40, color: cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(context.l10n.addCarPhotoHint,
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
      ),
    );
  }
}
