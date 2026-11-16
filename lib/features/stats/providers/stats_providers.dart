import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/widgets/service_type_chip.dart';
import '../../services/providers/service_providers.dart';

class VehicleStats {
  final double totalCost;
  final int entryCount;
  final double? avgCostPerEntry;
  final DateTime? lastServiceDate;
  final Map<ServiceType, double> costByType;

  const VehicleStats({
    required this.totalCost,
    required this.entryCount,
    required this.avgCostPerEntry,
    required this.lastServiceDate,
    required this.costByType,
  });

  factory VehicleStats.fromRecords(List<ServiceRecord> records) {
    if (records.isEmpty) {
      return const VehicleStats(
        totalCost: 0,
        entryCount: 0,
        avgCostPerEntry: null,
        lastServiceDate: null,
        costByType: {},
      );
    }

    double total = 0;
    final byType = <ServiceType, double>{};

    for (final r in records) {
      if (r.cost != null) {
        total += r.cost!;
        final type = ServiceType.fromValue(r.serviceType);
        byType[type] = (byType[type] ?? 0) + r.cost!;
      }
    }

    // Find latest service date
    final sorted = [...records]
      ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

    return VehicleStats(
      totalCost: total,
      entryCount: records.length,
      avgCostPerEntry: records.isEmpty ? null : total / records.length,
      lastServiceDate: sorted.first.serviceDate,
      costByType: byType,
    );
  }
}

final vehicleStatsProvider =
    Provider.family<AsyncValue<VehicleStats>, int>((ref, vehicleId) {
  final recordsAsync = ref.watch(serviceRecordsProvider(vehicleId));
  return recordsAsync.whenData(VehicleStats.fromRecords);
});
