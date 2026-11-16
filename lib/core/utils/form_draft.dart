import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/app_formats.dart';
import '../../data/repositories/garage_repository.dart';

class FormDraft {
  final GarageRepository repo;
  final String key;
  final Map<String, TextEditingController> fields;
  final Map<String, dynamic> Function() extra;
  final void Function(Map<String, dynamic>) restoreExtra;
  bool dirty = false, finished = false, _loading = true, _disposed = false;
  Timer? _timer;
  FormDraft(this.repo, this.key, this.fields,
      {required this.extra, required this.restoreExtra});
  Future<void> init() async {
    final saved = await repo.setting('draft:$key');
    if (_disposed) return;
    if (saved != null) {
      try {
        final data = jsonDecode(saved) as Map<String, dynamic>;
        for (final e in fields.entries) {
          if (data[e.key] is String) e.value.text = data[e.key] as String;
        }
        restoreExtra(Map<String, dynamic>.from(data['_extra'] as Map? ?? {}));
        dirty = true;
      } on FormatException {/* old incomplete draft */}
    }
    _loading = false;
    for (final ctrl in fields.values) {
      ctrl.addListener(changed);
    }
  }

  void changed() {
    if (_loading || finished) return;
    dirty = true;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 600), save);
  }

  Future<void> save() async {
    if (!dirty || finished) return;
    try {
      await repo.setSetting(
          'draft:$key',
          jsonEncode({
            ...fields.map((k, v) => MapEntry(k, v.text)),
            '_extra': extra()
          }));
    } catch (_) {/* keep the live form if storage is temporarily unavailable */}
  }

  Future<void> finish() async {
    finished = true;
    dirty = false;
    _timer?.cancel();
    try {
      await (repo.db.delete(repo.db.appSettings)
            ..where((s) => s.key.equals('draft:$key')))
          .go();
    } catch (_) {
      /* main record is already committed; never report it as a failed save */
    }
  }

  Future<bool> leave(BuildContext context) async {
    if (!dirty || finished) return true;
    final result = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(c.l10n.draftSaveTitle),
                content: Text(c.l10n.draftSaveBody),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, 'stay'),
                      child: Text(c.l10n.draftStayAction)),
                  TextButton(
                      onPressed: () => Navigator.pop(c, 'discard'),
                      child: Text(c.l10n.draftDiscardAction)),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, 'save'),
                      child: Text(c.l10n.draftSaveAction))
                ]));
    if (result == 'save') {
      await save();
      return true;
    }
    if (result == 'discard') {
      await finish();
      return true;
    }
    return false;
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    for (final c in fields.values) {
      c.removeListener(changed);
    }
  }
}

/// Intercept system and toolbar back navigation while an async draft decision runs.
class DraftExit extends StatefulWidget {
  final Future<bool> Function() onLeave;
  final Widget child;
  final bool busy;
  const DraftExit(
      {super.key,
      required this.onLeave,
      required this.child,
      this.busy = false});
  @override
  State<DraftExit> createState() => _DraftExitState();
}

class _DraftExitState extends State<DraftExit> {
  bool asking = false;
  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop || asking) return;
          asking = true;
          try {
            if (await widget.onLeave() && context.mounted) {
              Navigator.of(context).pop();
            }
          } finally {
            asking = false;
          }
        },
        child: AbsorbPointer(absorbing: widget.busy, child: widget.child),
      );
}
