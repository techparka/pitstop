import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/vehicle_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PitStop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
        data: (vehicles) => vehicles.isEmpty
            ? EmptyState(
                icon: Icons.directions_car_outlined,
                title: 'Brak aut',
                subtitle: 'Dodaj swoje pierwsze auto, żeby śledzić serwisy',
                action: FilledButton.icon(
                  onPressed: () => context.push('/vehicle/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj auto'),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: vehicles.length,
                itemBuilder: (context, i) =>
                    _VehicleCard(vehicle: vehicles[i]),
              ),
      ),
      floatingActionButton: vehiclesAsync.maybeWhen(
        data: (vehicles) => vehicles.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.push('/vehicle/add'),
                icon: const Icon(Icons.add),
                label: const Text('Dodaj auto'),
              ),
        orElse: () => FloatingActionButton.extended(
          onPressed: () => context.push('/vehicle/add'),
          icon: const Icon(Icons.add),
          label: const Text('Dodaj auto'),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PitStop',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.car_repair, size: 48),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/vehicle/${vehicle.id}'),
        child: Row(
          children: [
            _CarPhoto(photoPath: vehicle.photoPath, size: 110),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle.name,
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${vehicle.make} ${vehicle.model}',
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(vehicle.year.toString(),
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.speed, size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${NumberFormat('#,###').format(vehicle.currentMileage)} km',
                          style: tt.labelMedium
                              ?.copyWith(color: cs.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarPhoto extends StatelessWidget {
  final String? photoPath;
  final double size;
  const _CarPhoto({this.photoPath, required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (photoPath != null) {
      final f = File(photoPath!);
      if (f.existsSync()) {
        return SizedBox(
          width: size,
          height: size,
          child: Image.file(f, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      width: size,
      height: size,
      color: cs.surfaceVariant,
      child:
          Icon(Icons.directions_car, size: size * 0.45, color: cs.onSurfaceVariant),
    );
  }
}
