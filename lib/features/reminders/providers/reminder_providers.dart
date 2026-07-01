import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../vehicles/providers/vehicle_providers.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(ref.watch(databaseProvider));
});

// All reminders (incl. done) for a vehicle
final remindersProvider =
    StreamProvider.family<List<Reminder>, int>((ref, vehicleId) {
  return ref.watch(reminderRepositoryProvider).watchByVehicle(vehicleId);
});

// Active (not done) reminders for a vehicle
final activeRemindersProvider =
    StreamProvider.family<List<Reminder>, int>((ref, vehicleId) {
  return ref.watch(reminderRepositoryProvider).watchActive(vehicleId);
});
