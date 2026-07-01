import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:drift/drift.dart' show Value;

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

  String? _photoPath;
  bool _saving = false;
  Vehicle? _existing;

  bool get _isEdit => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(vehicleRepositoryProvider);
    final v = await repo.getById(widget.vehicleId!);
    setState(() {
      _existing = v;
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
      setState(() => _photoPath = picked.path);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dodaj zdjęcie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Aparat'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final repo = ref.read(vehicleRepositoryProvider);
      String? savedPhotoPath;

      if (_isEdit) {
        // Copy photo only if a new one was picked (path changed)
        if (_photoPath != null && _photoPath != _existing?.photoPath) {
          savedPhotoPath =
              await FileHelper.copyVehiclePhoto(_photoPath!, widget.vehicleId!);
        } else {
          savedPhotoPath = _existing?.photoPath;
        }
        await repo.update(VehiclesCompanion(
          id: Value(widget.vehicleId!),
          name: Value(_nameCtrl.text.trim()),
          make: Value(_makeCtrl.text.trim()),
          model: Value(_modelCtrl.text.trim()),
          year: Value(int.parse(_yearCtrl.text)),
          licensePlate: Value(_plateCtrl.text.trim().isEmpty
              ? null
              : _plateCtrl.text.trim()),
          photoPath: Value(savedPhotoPath),
          currentMileage: Value(int.parse(_mileageCtrl.text)),
        ));
      } else {
        final id = await repo.insert(VehiclesCompanion.insert(
          name: _nameCtrl.text.trim(),
          make: _makeCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          year: int.parse(_yearCtrl.text),
          licensePlate: Value(_plateCtrl.text.trim().isEmpty
              ? null
              : _plateCtrl.text.trim()),
          currentMileage:
              Value(int.tryParse(_mileageCtrl.text) ?? 0),
        ));
        if (_photoPath != null) {
          savedPhotoPath =
              await FileHelper.copyVehiclePhoto(_photoPath!, id);
          await repo.updateFields(
            id,
            VehiclesCompanion(photoPath: Value(savedPhotoPath)),
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
        title: Text(_isEdit ? 'Edytuj auto' : 'Nowe auto'),
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
            _field(_nameCtrl, 'Nazwa (np. Moje BMW)',
                icon: Icons.label_outline,
                validator: _required),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(_makeCtrl, 'Marka',
                      icon: Icons.business, validator: _required),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_modelCtrl, 'Model',
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
                    'Rok',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wymagane';
                      final y = int.tryParse(v);
                      if (y == null || y < 1886 || y > 2100) {
                        return 'Nieprawidłowy rok';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _plateCtrl,
                    'Rejestracja',
                    icon: Icons.credit_card,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              _mileageCtrl,
              'Aktualny przebieg (km)',
              icon: Icons.speed,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wymagane';
                if (int.tryParse(v) == null) return 'Podaj liczbę';
                return null;
              },
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
              label: Text(_isEdit ? 'Zapisz zmiany' : 'Dodaj auto'),
            ),
          ],
        ),
      ),
    );
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

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wymagane' : null;
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
                  Text('Dodaj zdjęcie auta',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
      ),
    );
  }
}
