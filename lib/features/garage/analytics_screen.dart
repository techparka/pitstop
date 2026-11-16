import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_formats.dart';
import '../../core/l10n/labels.dart';
import '../../domain/calculations.dart';
import 'garage_providers.dart';
import 'garage_shell.dart' show Metric;

class AnalyticsScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  const AnalyticsScreen({super.key, required this.vehicleId});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String period = 'ALL';
  DateTimeRange? custom;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(context.l10n.analyticsTitle)),
      body: ref.watch(garageSnapshotProvider(widget.vehicleId)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) =>
              Center(child: Text(context.l10n.statsLoadFailed)),
          data: (s) {
            final now = DateTime.now();
            final start = period == 'MONTH'
                ? DateTime(now.year, now.month)
                : period == 'YEAR'
                    ? DateTime(now.year)
                    : period == 'CUSTOM'
                        ? custom?.start
                        : null;
            final end = period == 'CUSTOM'
                ? custom?.end.add(const Duration(days: 1))
                : null;
            final entries = s.timeline
                .where((e) =>
                    (start == null || !e.date.isBefore(start)) &&
                    (end == null || e.date.isBefore(end)))
                .toList();
            final total = entries.fold<int>(0, (a, e) => a + (e.cents ?? 0));
            final categories = <String, int>{}, months = <String, int>{};
            for (final e in entries.where((e) => e.cents != null)) {
              final label = categoryLabel(context, e.category);
              categories[label] = (categories[label] ?? 0) + e.cents!;
              final month = AppFormats.monthKey(e.date);
              months[month] = (months[month] ?? 0) + e.cents!;
            }
            final anchors = entries.where((e) => e.mileage != null).toList()
              ..sort((a, b) => a.date.compareTo(b.date));
            final first = anchors.isEmpty ? null : anchors.first,
                last = anchors.isEmpty ? null : anchors.last;
            final distance = first == null || last == null
                ? 0
                : last.mileage! - first.mileage!;
            final intervalCost = first == null || last == null
                ? 0
                : entries
                    .where((e) =>
                        !e.date.isBefore(first.date) &&
                        !e.date.isAfter(last.date))
                    .fold<int>(0, (a, e) => a + (e.cents ?? 0));
            final fuel = consumption(s.ledger
                .where((e) =>
                    e.kind == 'FUEL' &&
                    e.mileage != null &&
                    e.quantity != null &&
                    (start == null || !e.date.isBefore(start)) &&
                    (end == null || e.date.isBefore(end)))
                .map((e) => FillUp(e.mileage!, e.quantity!,
                    full: e.fullTank,
                    missed: e.missed,
                    fuel: e.fuel ?? 'Benzyna'))
                .toList());
            return ListView(padding: const EdgeInsets.all(20), children: [
              Wrap(spacing: 8, children: [
                for (final p in [
                  ('ALL', context.l10n.periodAll),
                  ('MONTH', context.l10n.periodMonth),
                  ('YEAR', context.l10n.periodYear),
                  ('CUSTOM', context.l10n.periodCustom)
                ])
                  ChoiceChip(
                      label: Text(p.$2),
                      selected: period == p.$1,
                      onSelected: (_) async {
                        if (p.$1 == 'CUSTOM') {
                          final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(1990),
                              lastDate: now,
                              initialDateRange: custom);
                          if (range == null) return;
                          custom = range;
                        }
                        setState(() => period = p.$1);
                      })
              ]),
              const SizedBox(height: 20),
              Text(s.vehicle?.name ?? '',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(period == 'CUSTOM' && custom != null
                  ? '${context.fmt.dateNum(custom!.start)} – ${context.fmt.dateNum(custom!.end)}'
                  : context.l10n.amountsInCurrency(context.fmt.currency.code)),
              const SizedBox(height: 20),
              Wrap(spacing: 12, runSpacing: 12, children: [
                Metric(
                    label: context.l10n.metricTotalExpenses,
                    value: context.fmt.money(total),
                    icon: Icons.payments_outlined),
                Metric(
                    label: context.l10n.metricCostedEntries,
                    value: context.fmt
                        .number(entries.where((e) => e.cents != null).length),
                    icon: Icons.receipt_long_outlined),
                if (distance > 0)
                  Metric(
                      label: context.l10n.metricCostPerKm,
                      value:
                          '${context.fmt.decimal(context.fmt.toDisplay(intervalCost) / distance)} ${context.fmt.currencySymbol}/km',
                      icon: Icons.speed)
              ]),
              const SizedBox(height: 16),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(distance > 0
                          ? context.l10n.costPerKmRange(
                              context.fmt.dateNum(first!.date),
                              context.km(distance),
                              context.fmt.dateNum(last!.date))
                          : context.l10n.costPerKmNeedsReadings))),
              const SizedBox(height: 12),
              Text(context.l10n.fuelConsumptionTitle,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (fuel.isEmpty)
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(context.l10n.fuelNeedsMoreData)))
              else
                ...fuel.map((f) => Card(
                    child: ListTile(
                        leading: const Icon(Icons.local_gas_station_outlined),
                        title: Text(
                            '${context.fmt.decimal(f.per100)} ${context.l10n.unitLPer100km}'),
                        subtitle: Text(context.l10n.fuelCalculatedOver(
                            fuelLabel(context, f.fuel),
                            context.km(f.distance)))))),
              if (fuel.length > 1)
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(context.l10n.fuelSplitNote)),
              const SizedBox(height: 20),
              Text(context.l10n.expensesByCategory,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ..._bars(categories, total),
              const SizedBox(height: 20),
              Text(context.l10n.monthByMonth,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ..._bars(
                  Map.fromEntries(months.entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key))),
                  months.values.fold<int>(0, (a, b) => a > b ? a : b),
                  monthLabels: true),
              if (entries.isEmpty)
                Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(context.l10n.addFirstEntryForStats)),
              const SizedBox(height: 30)
            ]);
          }));
  /// Słupki wydatków; `monthLabels` zamienia klucze `YYYY-MM` na nazwy miesięcy.
  List<Widget> _bars(Map<String, int> data, int max,
          {bool monthLabels = false}) =>
      data.entries
      .map((e) => Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 16, runSpacing: 4, children: [
                      Text(monthLabels
                          ? context.fmt.monthLabelFromKey(e.key)
                          : e.key,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(context.fmt.money(e.value))
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            minHeight: 7,
                            value: max <= 0
                                ? 0
                                : (e.value / max).clamp(0, 1).toDouble(),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(.08)))
                  ]))))
      .toList();
}
