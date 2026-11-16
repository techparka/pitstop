import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/vehicle_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(ref.watch(databaseProvider));
});

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(vehicleRepositoryProvider).watchAll();
});

// B3: returns Vehicle? (null when deleted)
final vehicleProvider = StreamProvider.family<Vehicle?, int>((ref, id) {
  return ref.watch(vehicleRepositoryProvider).watchById(id);
});
