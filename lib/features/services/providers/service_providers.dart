import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/service_repository.dart';
import '../../vehicles/providers/vehicle_providers.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(ref.watch(databaseProvider));
});

final serviceRecordsProvider =
    StreamProvider.family<List<ServiceRecord>, int>((ref, vehicleId) {
  return ref.watch(serviceRepositoryProvider).watchByVehicle(vehicleId);
});

// B3: returns ServiceRecord? (null when deleted)
final serviceRecordProvider =
    StreamProvider.family<ServiceRecord?, int>((ref, id) {
  return ref.watch(serviceRepositoryProvider).watchById(id);
});

final attachmentsProvider =
    StreamProvider.family<List<Attachment>, int>((ref, serviceRecordId) {
  return ref.watch(serviceRepositoryProvider).watchAttachments(serviceRecordId);
});
