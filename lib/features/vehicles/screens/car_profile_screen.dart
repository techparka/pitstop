import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_formats.dart';
import '../../../core/l10n/labels.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/service_type_chip.dart';
import '../../reminders/providers/reminder_providers.dart';
import '../../services/providers/service_providers.dart';
import '../../stats/providers/stats_providers.dart';
import '../providers/vehicle_providers.dart';

class CarProfileScreen extends ConsumerWidget {
  final int vehicleId;
  const CarProfileScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleProvider(vehicleId));

    return vehicleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
            body: Center(child: Text(context.l10n.errorWithDetails('$e')))),
      data: (vehicle) {
        // B3: null means deleted — pop without showing error
        if (vehicle == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && context.canPop()) context.pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return _ProfileBody(vehicle: vehicle);
      },
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final Vehicle vehicle;
  const _ProfileBody({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(serviceRecordsProvider(vehicle.id));
    final remindersAsync = ref.watch(activeRemindersProvider(vehicle.id));
    final statsAsync = ref.watch(vehicleStatsProvider(vehicle.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _CarSliverAppBar(vehicle: vehicle),
          SliverToBoxAdapter(
            child: _InfoRow(vehicle: vehicle),
          ),
          SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                      child: ExpansionTile(
                          title: Text(context.l10n.techDataSection),
                          children: [
                        ListTile(
                            title: Text(context.l10n.powertrainField),
                            subtitle: Text(powertrainLabel(
                                context, vehicle.powertrain))),
                        if (vehicle.vin != null)
                          ListTile(
                              title: const Text('VIN'),
                              subtitle: SelectableText(vehicle.vin!)),
                        if (vehicle.purchaseDate != null)
                          ListTile(
                              title: Text(context.l10n.purchaseDateField),
                              subtitle: Text(
                                  context.fmt.dateNum(vehicle.purchaseDate!))),
                        if ((vehicle.technicalNotes ?? '').isNotEmpty)
                          ListTile(
                              title: Text(context.l10n.technicalNotesField),
                              subtitle: Text(vehicle.technicalNotes!))
                      ])))),
          // Stats summary card
          SliverToBoxAdapter(
            child: statsAsync.whenData((stats) {
                  if (stats.entryCount == 0) return const SizedBox.shrink();
                  return _StatsSummaryCard(stats: stats, vehicleId: vehicle.id);
                }).valueOrNull ??
                const SizedBox.shrink(),
          ),
          // Reminders section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.remindersSectionTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(context.l10n.addAction),
                    onPressed: () =>
                        context.push('/vehicle/${vehicle.id}/reminder/add'),
                  ),
                ],
              ),
            ),
          ),
          remindersAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (reminders) => reminders.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Text(context.l10n.noActiveRemindersTitle,
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  )
                : SliverList.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, i) => _ReminderTile(
                      reminder: reminders[i],
                      currentMileage: vehicle.currentMileage,
                    ),
                  ),
          ),
          // Service history section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text(context.l10n.serviceHistoryTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
          servicesAsync.when(
            loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text(context.l10n.errorWithDetails('$e')))),
            data: (records) => records.isEmpty
                ? SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.build_outlined,
                      title: context.l10n.noServiceRecordsTitle,
                      subtitle: context.l10n.noServiceRecordsBody,
                    ),
                  )
                : SliverList.separated(
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, i) =>
                        _ServiceTile(record: records[i]),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicle/${vehicle.id}/service/add'),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addServiceAction),
      ),
    );
  }
}

class _StatsSummaryCard extends StatelessWidget {
  final VehicleStats stats;
  final int vehicleId;
  const _StatsSummaryCard({required this.stats, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final fmt = context.fmt, l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/vehicle/$vehicleId/stats'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.serviceCostsTitle,
                          style: tt.labelLarge
                              ?.copyWith(color: cs.onSurfaceVariant)),
                      Text(fmt.moneyFromZloty(stats.totalCost),
                          style: tt.titleMedium?.copyWith(
                              color: cs.primary, fontWeight: FontWeight.bold)),
                      Text(
                        stats.lastServiceDate == null
                            ? l.entriesCountShort(stats.entryCount)
                            : '${l.entriesCountShort(stats.entryCount)} · '
                                '${l.lastServiceShortLabel(fmt.dateMonth(stats.lastServiceDate!))}',
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  final Reminder reminder;
  final int currentMileage;
  const _ReminderTile({required this.reminder, required this.currentMileage});

  _ReminderUrgency _urgency() {
    final now = DateTime.now();
    bool overdue = false;
    bool soon = false;

    if (reminder.dueDate != null) {
      if (reminder.dueDate!.isBefore(now)) {
        overdue = true;
      } else if (reminder.dueDate!.difference(now).inDays <= 30) {
        soon = true;
      }
    }
    if (reminder.dueMileage != null) {
      final diff = reminder.dueMileage! - currentMileage;
      if (diff <= 0) {
        overdue = true;
      } else if (diff <= 1000) {
        soon = true;
      }
    }

    if (overdue) return _ReminderUrgency.overdue;
    if (soon) return _ReminderUrgency.soon;
    return _ReminderUrgency.normal;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final type = ServiceType.fromValue(reminder.serviceType);
    final urgency = _urgency();

    final urgencyColor = switch (urgency) {
      _ReminderUrgency.overdue => cs.error,
      _ReminderUrgency.soon => Colors.amber.shade700,
      _ReminderUrgency.normal => cs.primary,
    };

    final fmt = context.fmt, l = context.l10n;
    final parts = <String>[];
    if (reminder.dueDate != null) {
      parts.add(fmt.dateMonth(reminder.dueDate!));
    }
    if (reminder.dueMileage != null) {
      final diff = reminder.dueMileage! - currentMileage;
      if (diff > 0) {
        parts.add(l.kmRemainingLabel(fmt.number(diff)));
      } else {
        parts.add(l.overdueAtMileageLabel(fmt.number(reminder.dueMileage!)));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: urgency == _ReminderUrgency.normal
                ? cs.outlineVariant
                : urgencyColor.withOpacity(0.4),
          ),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(type.icon, color: urgencyColor, size: 20),
          title: Text(reminder.title,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: parts.isEmpty
              ? null
              : Text(parts.join(' · '),
                  style: tt.bodySmall?.copyWith(color: urgencyColor)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: context.l10n.editAction,
                onPressed: () => context.push(
                    '/reminder/${reminder.id}/edit?vehicleId=${reminder.vehicleId}'),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline,
                    size: 18, color: Colors.green),
                tooltip: context.l10n.reminderDoneAction,
                onPressed: () async {
                  await ref
                      .read(reminderRepositoryProvider)
                      .markDone(reminder.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ReminderUrgency { overdue, soon, normal }

class _CarSliverAppBar extends ConsumerWidget {
  final Vehicle vehicle;
  const _CarSliverAppBar({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final hasPhoto =
        vehicle.photoPath != null && File(vehicle.photoPath!).existsSync();

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      actions: [
        IconButton(
          tooltip: context.l10n.editCarTooltip,
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.push('/vehicle/${vehicle.id}/edit'),
        ),
        IconButton(
          tooltip: context.l10n.deleteCarAction,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(vehicle.name,
            style: const TextStyle(
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
        background: hasPhoto
            ? Image.file(File(vehicle.photoPath!), fit: BoxFit.cover)
            : Container(
                color: cs.primaryContainer,
                child: Icon(Icons.directions_car,
                    size: 80, color: cs.onPrimaryContainer),
              ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteCarAction),
        content: Text(context.l10n.deleteCarBody(vehicle.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancelAction)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // B2: delete with files; B3: stream emits null → auto-pop
              await ref
                  .read(vehicleRepositoryProvider)
                  .deleteWithFiles(vehicle.id);
            },
            child: Text(context.l10n.deleteAction),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Vehicle vehicle;
  const _InfoRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoCell(
                icon: Icons.calendar_today,
                label: context.l10n.vehicleYearField,
                value: vehicle.year.toString(),
              ),
              _divider(),
              _InfoCell(
                icon: Icons.speed,
                label: context.l10n.mileageLabel,
                value: context.km(vehicle.currentMileage),
              ),
              if (vehicle.licensePlate != null) ...[
                _divider(),
                _InfoCell(
                  icon: Icons.credit_card,
                  label: context.l10n.vehiclePlateField,
                  value: vehicle.licensePlate!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const SizedBox(height: 40, child: VerticalDivider());
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCell(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(height: 4),
        Text(value,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final ServiceRecord record;
  const _ServiceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final type = ServiceType.fromValue(record.serviceType);

    return InkWell(
      onTap: () => context.push('/service/${record.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 2,
                  height: 12,
                  color: cs.outlineVariant,
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(type.icon, size: 18, color: cs.onPrimaryContainer),
                ),
                Container(
                  width: 2,
                  height: 12,
                  color: cs.outlineVariant,
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record.title,
                                style: tt.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              context.fmt.dateMonth(record.serviceDate),
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            if (record.mileage != null)
                              Text(
                                context.km(record.mileage!),
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      if (record.cost != null)
                        Text(
                          context.fmt.moneyFromZloty(record.cost!),
                          style: tt.labelLarge?.copyWith(color: cs.primary),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
