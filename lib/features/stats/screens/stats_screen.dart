import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_formats.dart';
import '../../../shared/widgets/service_type_chip.dart';
import '../providers/stats_providers.dart';

class StatsScreen extends ConsumerWidget {
  final int vehicleId;
  const StatsScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(vehicleStatsProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statsCostsTitle),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorWithDetails('$e'))),
        data: (stats) => _StatsBody(stats: stats),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final VehicleStats stats;
  const _StatsBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = context.l10n;

    if (stats.entryCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l.noDataTitle,
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(l.statsEmptyBody,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.payments_outlined,
                label: l.statsTotalCost,
                value: context.fmt.moneyFromZloty(stats.totalCost),
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.format_list_numbered,
                label: l.statsEntryCount,
                value: context.fmt.number(stats.entryCount),
                color: cs.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (stats.avgCostPerEntry != null)
              Expanded(
                child: _SummaryCard(
                  icon: Icons.calculate_outlined,
                  label: l.statsAverageCost,
                  value: context.fmt
                      .moneyFromZloty(stats.avgCostPerEntry!),
                  color: cs.tertiary,
                ),
              ),
            if (stats.avgCostPerEntry != null) const SizedBox(width: 12),
            if (stats.lastServiceDate != null)
              Expanded(
                child: _SummaryCard(
                  icon: Icons.event_available,
                  label: l.statsLastService,
                  value: context.fmt.dateMonth(stats.lastServiceDate!),
                  color: Colors.green,
                ),
              ),
          ],
        ),
        if (stats.costByType.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l.statsCostByType,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ..._buildTypeBreakdown(context, stats),
        ],
      ],
    );
  }

  List<Widget> _buildTypeBreakdown(BuildContext context, VehicleStats stats) {
    if (stats.costByType.isEmpty) return [];

    final maxCost = stats.costByType.values.reduce((a, b) => a > b ? a : b);

    return stats.costByType.entries.toList().sorted().map((entry) {
      final type = entry.key;
      final cost = entry.value;
      final fraction = maxCost > 0 ? cost / maxCost : 0.0;

      return _TypeBar(
        type: type,
        cost: cost,
        fraction: fraction,
        label: context.fmt.moneyFromZloty(cost),
      );
    }).toList();
  }
}

extension _SortedEntries on List<MapEntry<ServiceType, double>> {
  List<MapEntry<ServiceType, double>> sorted() {
    return this..sort((a, b) => b.value.compareTo(a.value));
  }
}

class _TypeBar extends StatelessWidget {
  final ServiceType type;
  final double cost;
  final double fraction;
  final String label;
  const _TypeBar(
      {required this.type,
      required this.cost,
      required this.fraction,
      required this.label});

  Color _typeColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (type) {
      ServiceType.oilChange => Colors.amber,
      ServiceType.repair => cs.error,
      ServiceType.inspection => Colors.green,
      ServiceType.tires => Colors.blue,
      _ => cs.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(context);
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(type.icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(type.label(context), style: tt.bodyMedium),
              const Spacer(),
              Text(label,
                  style: tt.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth * fraction,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SummaryCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: tt.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: tt.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
