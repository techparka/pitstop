import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_errors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/garage_repository.dart';
import '../vehicles/providers/vehicle_providers.dart';

final garageRepositoryProvider =
    Provider((ref) => GarageRepository(ref.watch(databaseProvider)));
final garageChangesProvider =
    StreamProvider((ref) => ref.watch(garageRepositoryProvider).changes());
final appThemeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);
/// Kod ostatniego błędu kopii; tekst wybiera interfejs w swoim języku.
final backupErrorProvider = StateProvider<AppError?>((ref) => null);

class GarageSnapshot {
  final List<Vehicle> vehicles;
  final Vehicle? vehicle;
  final List<TimelineEntry> timeline;
  final List<Reminder> reminders;
  final List<LedgerEntry> ledger;
  final bool backupDue;
  const GarageSnapshot(
      this.vehicles, this.vehicle, this.timeline, this.reminders, this.ledger,
      {this.backupDue = true});
}

final garageSnapshotProvider =
    FutureProvider.family<GarageSnapshot, int?>((ref, id) async {
  ref.watch(garageChangesProvider);
  final repo = ref.watch(garageRepositoryProvider), db = repo.db;
  final vehicles = await (db.select(db.vehicles)
        ..orderBy([(v) => OrderingTerm.desc(v.createdAt)]))
      .get();
  final selected =
      id ?? int.tryParse(await repo.setting('selectedVehicle') ?? '');
  final vehicle = vehicles.isEmpty
      ? null
      : vehicles.firstWhere((v) => v.id == selected,
          orElse: () => vehicles.first);
  if (vehicle == null) return GarageSnapshot(vehicles, null, [], [], []);
  final external =
      DateTime.tryParse(await repo.setting('lastExternalBackup') ?? '');
  return GarageSnapshot(
      vehicles,
      vehicle,
      await repo.timeline(vehicle.id),
      await (db.select(db.reminders)
            ..where((r) => r.vehicleId.equals(vehicle.id))
            ..orderBy([(r) => OrderingTerm.asc(r.dueDate)]))
          .get(),
      await (db.select(db.ledgerEntries)
            ..where((l) => l.vehicleId.equals(vehicle.id))
            ..orderBy([(l) => OrderingTerm.asc(l.date)]))
          .get(),
      backupDue:
          external == null || DateTime.now().difference(external).inDays >= 7);
});
