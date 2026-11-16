import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_formats.dart';
import '../../core/l10n/labels.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/garage_repository.dart';
import '../../core/services/device_services.dart';
import 'garage_providers.dart';

class GarageShell extends ConsumerStatefulWidget {
  const GarageShell({super.key});
  @override
  ConsumerState<GarageShell> createState() => _GarageShellState();
}

class _GarageShellState extends ConsumerState<GarageShell> {
  int tab = 0;
  int? selected;
  String query = '', kind = 'ALL', category = 'ALL';
  DateTimeRange? range;
  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(garageSnapshotProvider(selected));
    return snapshot.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, st) => Scaffold(
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(context.l10n.loadFailed),
                      FilledButton(
                          onPressed: () =>
                              ref.invalidate(garageSnapshotProvider),
                          child: Text(context.l10n.tryAgain))
                    ])))),
        data: (s) => _build(context, s));
  }

  Widget _build(BuildContext context, GarageSnapshot s) {
    final car = s.vehicle;
    return Scaffold(
      appBar: AppBar(
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text([
              'PitStop',
              context.l10n.navHistory,
              context.l10n.navReminders,
              context.l10n.titleGarageTab
            ][tab]),
            if (tab == 0)
              Text(context.l10n.appTagline,
                  style: Theme.of(context).textTheme.bodySmall)
          ]),
          actions: [
            IconButton(
                tooltip: context.l10n.settingsTooltip,
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.tune_rounded))
          ],
          bottom: car == null || tab == 3
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(68),
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: DropdownButtonFormField<int>(
                          value: car.id,
                          isExpanded: true,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.directions_car_rounded),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10)),
                          items: s.vehicles
                              .map((v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Text(v.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (id) {
                            setState(() => selected = id);
                            ref
                                .read(garageRepositoryProvider)
                                .setSetting('selectedVehicle', id.toString());
                          })))),
      body: car == null
          ? _emptyGarage()
          : switch (tab) {
              0 => _dashboard(s),
              1 => _history(s),
              2 => _terms(s),
              _ => _garage(s)
            },
      floatingActionButton: car == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  tab == 3 ? context.push('/vehicle/add') : _add(car.id),
              icon: const Icon(Icons.add),
              label: Text(tab == 3
                  ? context.l10n.addCarAction
                  : context.l10n.addEntryAction)),
      bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.space_dashboard_outlined),
                selectedIcon: const Icon(Icons.space_dashboard_rounded),
                label: context.l10n.navDashboard),
            NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: context.l10n.navHistory),
            NavigationDestination(
                icon: const Icon(Icons.event_outlined),
                selectedIcon: const Icon(Icons.event),
                label: context.l10n.navReminders),
            NavigationDestination(
                icon: const Icon(Icons.garage_outlined),
                selectedIcon: const Icon(Icons.garage),
                label: context.l10n.navGarage)
          ]),
    );
  }

  Widget _emptyGarage() => Center(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.garage_outlined,
                size: 84, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(context.l10n.emptyGarageTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(context.l10n.emptyGarageBody, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            FilledButton.icon(
                onPressed: () => context.push('/vehicle/add'),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addFirstCar)),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () => context.push('/settings'),
                child: Text(context.l10n.haveBackup))
          ])));
  Widget _dashboard(GarageSnapshot s) {
    final car = s.vehicle!, now = DateTime.now();
    final month = s.timeline
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<int>(0, (a, e) => a + (e.cents ?? 0));
    final active = s.reminders.where((r) => !r.isDone).toList()
      ..sort((a, b) => urgency(a, car.currentMileage)
          .compareTo(urgency(b, car.currentMileage)));
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                      colors: [Color(0xFF252D3C), Color(0xFF111923)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFF7A3D).withOpacity(.16),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(context.l10n.yourCarBadge,
                              style: const TextStyle(
                                  color: Color(0xFFFFAA7C),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5))),
                      const Spacer(),
                      IconButton(
                          tooltip: context.l10n.carProfileTooltip,
                          onPressed: () => context.push('/vehicle/${car.id}'),
                          icon: const Icon(Icons.north_east,
                              color: Colors.white70))
                    ]),
                    const SizedBox(height: 18),
                    Text(car.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 29,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(
                        '${car.make} ${car.model} · ${car.year} · ${powertrainLabel(context, car.powertrain)}',
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 28),
                    Text(context.km(car.currentMileage),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.7)),
                    Text(context.l10n.lastKnownMileage,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12))
                  ])),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: [
            Metric(
                label: context.l10n.metricMonthExpenses,
                value: context.fmt.money(month),
                icon: Icons.account_balance_wallet_outlined),
            Metric(
                label: context.l10n.metricActiveReminders,
                value: context.fmt.number(active.length),
                icon: Icons.event_available_outlined)
          ]),
          const SizedBox(height: 12),
          Card(
              child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  leading: Icon(Icons.insights_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(context.l10n.analyticsCardTitle),
                  subtitle: Text(context.l10n.analyticsCardSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/vehicle/${car.id}/analytics'))),
          if (s.backupDue)
            Card(
                child: ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: Text(context.l10n.backupCardTitle),
                    subtitle: Text(context.l10n.backupCardSubtitle),
                    onTap: () => context.push('/settings'))),
          _section(context.l10n.sectionUpcoming,
              action: context.l10n.actionAll,
              onTap: () => setState(() => tab = 2)),
          if (active.isEmpty)
            _hint(context.l10n.hintCalmTitle, context.l10n.hintCalmBody,
                Icons.verified_outlined)
          else
            ...active.take(3).map(
                (r) => ReminderCard(reminder: r, mileage: car.currentMileage)),
          _section(context.l10n.sectionRecentActivity,
              action: context.l10n.navHistory,
              onTap: () => setState(() => tab = 1)),
          if (s.timeline.isEmpty)
            _hint(context.l10n.hintFirstEntryTitle,
                context.l10n.hintFirstEntryBody, Icons.receipt_long_outlined)
          else
            ...s.timeline.take(4).map(_entry),
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.lock_outline, size: 14),
                const SizedBox(width: 6),
                Text(context.l10n.privacyNote,
                    style: const TextStyle(fontSize: 11))
              ]))
        ]);
  }

  Widget _section(String title, {String? action, VoidCallback? onTap}) =>
      Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Row(children: [
            Expanded(
                child:
                    Text(title, style: Theme.of(context).textTheme.titleLarge)),
            if (action != null)
              TextButton(onPressed: onTap, child: Text(action))
          ]));
  Widget _hint(String title, String subtitle, IconData icon) => Card(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium)
          ])));
  Widget _history(GarageSnapshot s) {
    final categories = s.timeline.map((e) => e.category).toSet().toList()
      ..sort();
    if (category != 'ALL' && !categories.contains(category)) category = 'ALL';
    final rows = s.timeline
        .where((e) =>
            (kind == 'ALL' || e.kind == kind) &&
            (category == 'ALL' || e.category == category) &&
            (range == null ||
                (!e.date.isBefore(range!.start) &&
                    e.date
                        .isBefore(range!.end.add(const Duration(days: 1))))) &&
            '${e.title} ${e.note} ${e.place}'
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
    return Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(children: [
            TextField(
                decoration: InputDecoration(
                    hintText: context.l10n.searchEntriesHint,
                    prefixIcon: const Icon(Icons.search)),
                onChanged: (v) => setState(() => query = v)),
            const SizedBox(height: 12),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final item in [
                    ('ALL', context.l10n.filterAll),
                    ('SERVICE', context.l10n.filterServices),
                    ('FUEL', context.l10n.categoryFuel),
                    ('CHARGE', context.l10n.filterCharges),
                    ('EXPENSE', context.l10n.filterExpenses),
                    ('MILEAGE', context.l10n.filterMileage)
                  ])
                    Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(item.$2),
                            selected: kind == item.$1,
                            onSelected: (_) => setState(() => kind = item.$1)))
                ])),
            Row(children: [
              Expanded(
                  child: DropdownButton<String>(
                      isExpanded: true,
                      value: category,
                      items: [
                        DropdownMenuItem(
                            value: 'ALL',
                            child: Text(context.l10n.filterAnyCategory)),
                        ...categories.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(categoryLabel(context, c),
                                overflow: TextOverflow.ellipsis)))
                      ],
                      onChanged: (v) => setState(() => category = v!))),
              IconButton(
                  tooltip: context.l10n.filterDatesTooltip,
                  icon: Icon(Icons.date_range,
                      color: range == null
                          ? null
                          : Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    final dates = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(1990),
                        lastDate: DateTime.now(),
                        initialDateRange: range);
                    if (dates != null) setState(() => range = dates);
                  }),
              if (range != null)
                IconButton(
                    tooltip: context.l10n.removeDateRangeTooltip,
                    onPressed: () => setState(() => range = null),
                    icon: const Icon(Icons.filter_alt_off))
            ]),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    context.l10n.entriesSummary(
                        rows.length,
                        context.fmt
                            .money(rows.fold(0, (a, e) => a + (e.cents ?? 0)))),
                    style: Theme.of(context).textTheme.labelLarge))
          ])),
      Expanded(
          child: rows.isEmpty
              ? Center(child: Text(context.l10n.noMatchingEntries))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: rows.length,
                  itemBuilder: (c, i) => _entry(rows[i])))
    ]);
  }

  Widget _entry(TimelineEntry e) {
    final icon = switch (e.kind) {
      'SERVICE' => Icons.build_outlined,
      'FUEL' => Icons.local_gas_station_outlined,
      'CHARGE' => Icons.ev_station_outlined,
      'MILEAGE' => Icons.speed,
      _ => Icons.payments_outlined
    };
    return Card(
        child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(.09),
                    borderRadius: BorderRadius.circular(14)),
                child:
                    Icon(icon, color: Theme.of(context).colorScheme.primary)),
            title: Text(e.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${context.fmt.dateMonth(e.date)}${e.mileage == null ? '' : ' · ${context.km(e.mileage!)}'}\n${categoryLabel(context, e.category)}'),
            isThreeLine: true,
            trailing: e.cents == null
                ? const Icon(Icons.chevron_right)
                : SizedBox(
                    width: 92,
                    child: Text(context.fmt.money(e.cents!),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w700))),
            onTap: () => context.push(e.kind == 'SERVICE'
                ? '/service/${e.id}'
                : '/vehicle/${e.vehicleId}/entry/${e.kind}?id=${e.id}')));
  }

  Widget _terms(GarageSnapshot s) {
    final active = s.reminders.where((r) => !r.isDone).toList()
      ..sort((a, b) => urgency(a, s.vehicle!.currentMileage)
          .compareTo(urgency(b, s.vehicle!.currentMileage)));
    final done = s.reminders.where((r) => r.isDone).toList();
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.termsRuleTitle,
                            style: const
                                TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(context.l10n.termsRuleBody),
                        TextButton.icon(
                            onPressed: () async {
                              await DeviceServices.requestNotifications();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(context
                                            .l10n.notificationsConsentHint)));
                              }
                            },
                            icon:
                                const Icon(Icons.notifications_active_outlined),
                            label: Text(context.l10n.enableNotifications))
                      ]))),
          if (active.isEmpty)
            _hint(context.l10n.noActiveRemindersTitle,
                context.l10n.noActiveRemindersBody,
                Icons.event_available_outlined),
          ...active.map((r) =>
              ReminderCard(reminder: r, mileage: s.vehicle!.currentMileage)),
          if (done.isNotEmpty)
            ExpansionTile(
                title: Text(
                    context.l10n.doneRemindersSection(done.length)),
                children: done
                    .map((r) => ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(r.title),
                        trailing: IconButton(
                            tooltip: context.l10n.editAction,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => context.push(
                                '/reminder/${r.id}/edit?vehicleId=${r.vehicleId}'))))
                    .toList())
        ]);
  }

  Widget _garage(GarageSnapshot s) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 100), children: [
        Text(context.l10n.garageTabTitle,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...s.vehicles.map((v) => Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                onTap: () => context.push('/vehicle/${v.id}'),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (v.photoPath != null &&
                          File(v.photoPath!).existsSync())
                        Image.file(File(v.photoPath!),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover),
                      ListTile(
                          contentPadding: const EdgeInsets.all(18),
                          leading: const Icon(Icons.directions_car_outlined,
                              size: 34),
                          title: Text(v.name),
                          subtitle: Text(
                              '${v.make} ${v.model} · ${v.year}\n${context.km(v.currentMileage)}'),
                          trailing: const Icon(Icons.chevron_right))
                    ]))))
      ]);
  Future<void> _add(int id) async {
    final action = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (c) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(c.l10n.addSheetTitle,
                      style: Theme.of(c).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (final item in [
                    ('service', c.l10n.addServiceEntry, Icons.build_outlined),
                    ('FUEL', c.l10n.addRefuel, Icons.local_gas_station_outlined),
                    ('CHARGE', c.l10n.addCharge, Icons.ev_station_outlined),
                    ('EXPENSE', c.l10n.addExpense, Icons.payments_outlined),
                    ('MILEAGE', c.l10n.filterMileage, Icons.speed),
                    ('reminder', c.l10n.addReminder, Icons.event_outlined)
                  ])
                    ListTile(
                        leading: Icon(item.$3),
                        title: Text(item.$2),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(c, item.$1))
                ]))));
    if (!mounted || action == null) return;
    context.push(action == 'service'
        ? '/vehicle/$id/service/add'
        : action == 'reminder'
            ? '/vehicle/$id/reminder/add'
            : '/vehicle/$id/entry/$action');
  }
}

class Metric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const Metric(
      {super.key,
      required this.label,
      required this.value,
      required this.icon});
  @override
  Widget build(BuildContext context) => Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(height: 16),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall)
      ]));
}

int urgency(Reminder r, int mileage) {
  final today = DateTime.now();
  final date = DateTime(today.year, today.month, today.day);
  if ((r.dueDate != null && r.dueDate!.isBefore(date)) ||
      (r.dueMileage != null && r.dueMileage! <= mileage)) return 0;
  if ((r.dueDate != null && r.dueDate!.difference(date).inDays <= 30) ||
      (r.dueMileage != null && r.dueMileage! - mileage <= 1000)) return 1;
  return 2;
}

class ReminderCard extends ConsumerWidget {
  final Reminder reminder;
  final int mileage;
  const ReminderCard(
      {super.key, required this.reminder, required this.mileage});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = reminder,
        status = urgency(r, mileage),
        color = [
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFFF9B9B)
              : const Color(0xFFB33131),
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFFFB95C)
              : const Color(0xFF8A5100),
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF7AD7AF)
              : const Color(0xFF247354)
        ][status];
    return Card(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        [
                          context.l10n.urgencyAttention,
                          context.l10n.urgencySoon,
                          context.l10n.urgencyPlanned
                        ][status],
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700))),
                PopupMenuButton<String>(
                    tooltip: context.l10n.reminderOptionsTooltip,
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push(
                            '/reminder/${r.id}/edit?vehicleId=${r.vehicleId}');
                        return;
                      }
                      if (value == 'delete') {
                        final ok = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                                    title: Text(c.l10n.deleteReminderTitle),
                                    content: Text(r.title),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: Text(c.l10n.cancelAction)),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: Text(c.l10n.deleteAction))
                                    ]));
                        if (ok == true) {
                          await (ref.read(garageRepositoryProvider).db.delete(
                                  ref
                                      .read(garageRepositoryProvider)
                                      .db
                                      .reminders)
                                ..where((e) => e.id.equals(r.id)))
                              .go();
                        }
                        return;
                      }
                      final result = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                                  title: Text(c.l10n.markDoneTitle),
                                  content: Text(c.l10n.markDoneBody),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: Text(c.l10n.markDoneOnly)),
                                    FilledButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: Text(c.l10n.addServiceAction))
                                  ]));
                      if (result != null) {
                        await ref
                            .read(garageRepositoryProvider)
                            .complete(r, createService: result);
                      }
                    },
                    itemBuilder: (c) => [
                          PopupMenuItem(
                              value: 'done',
                              child: Text(c.l10n.reminderDoneAction)),
                          PopupMenuItem(
                              value: 'edit', child: Text(c.l10n.editAction)),
                          PopupMenuItem(
                              value: 'delete',
                              child: Text(c.l10n.deleteAction))
                        ])
              ]),
              Text(r.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text([
                if (r.dueDate != null) context.fmt.dateMonth(r.dueDate!),
                if (r.dueMileage != null)
                  '${context.km(r.dueMileage!)} (${context.l10n.kmRemaining(context.km(r.dueMileage! - mileage))})'
              ].join(' · ')),
              if (r.intervalKm != null || r.intervalMonths != null)
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                        context.l10n.repeatLabel([
                          if (r.intervalMonths != null)
                            context.l10n.repeatEveryMonths(r.intervalMonths!),
                          if (r.intervalKm != null)
                            context.l10n.repeatEveryKm(context.km(r.intervalKm!))
                        ].join(' ${context.l10n.repeatOr} ')),
                        style: Theme.of(context).textTheme.bodySmall))
            ])));
  }
}
