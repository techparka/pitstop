import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/widgets/service_type_chip.dart';
import '../providers/reminder_providers.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  final int? reminderId;
  const AddReminderScreen(
      {super.key, required this.vehicleId, this.reminderId});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();

  DateTime? _dueDate;
  ServiceType _type = ServiceType.other;
  bool _saving = false;

  bool get _isEdit => widget.reminderId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(reminderRepositoryProvider);
    final r = await repo.getById(widget.reminderId!);
    if (r == null) return;
    setState(() {
      _titleCtrl.text = r.title;
      _noteCtrl.text = r.note ?? '';
      _mileageCtrl.text = r.dueMileage?.toString() ?? '';
      _dueDate = r.dueDate;
      _type = ServiceType.fromValue(r.serviceType);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final repo = ref.read(reminderRepositoryProvider);
      final mileage = int.tryParse(_mileageCtrl.text);

      if (_isEdit) {
        await repo.update(RemindersCompanion(
          id: Value(widget.reminderId!),
          vehicleId: Value(widget.vehicleId),
          title: Value(_titleCtrl.text.trim()),
          note: Value(_noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()),
          dueDate: Value(_dueDate),
          dueMileage: Value(mileage),
          serviceType: Value(_type.value),
        ));
      } else {
        await repo.insert(RemindersCompanion.insert(
          vehicleId: widget.vehicleId,
          title: _titleCtrl.text.trim(),
          note: Value(_noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()),
          dueDate: Value(_dueDate),
          dueMileage: Value(mileage),
          serviceType: Value(_type.value),
        ));
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edytuj przypomnienie' : 'Nowe przypomnienie'),
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
            Text('Termin (opcjonalnie)',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        prefixIcon: Icon(Icons.event),
                      ),
                      child: Text(
                        _dueDate != null
                            ? DateFormat('d MMM yyyy', 'pl_PL').format(_dueDate!)
                            : 'Brak',
                        style: TextStyle(
                            color: _dueDate != null
                                ? null
                                : cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
                if (_dueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Wyczyść datę',
                    onPressed: () => setState(() => _dueDate = null),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mileageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Przebieg docelowy (km, opcjonalnie)',
                prefixIcon: Icon(Icons.speed),
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty && int.tryParse(v) == null) {
                  return 'Podaj liczbę';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notatka (opcjonalnie)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
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
              label: Text(_isEdit ? 'Zapisz zmiany' : 'Dodaj przypomnienie'),
            ),
          ],
        ),
      ),
    );
  }
}
