import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/widgets/service_type_chip.dart';
import '../../services/providers/service_providers.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceRecordProvider(serviceId));

    return serviceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Błąd: $e'))),
      data: (service) {
        // B3: null means deleted — pop without showing error
        if (service == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && context.canPop()) context.pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return _DetailBody(service: service);
      },
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final ServiceRecord service;
  const _DetailBody({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentsAsync =
        ref.watch(attachmentsProvider(service.id));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final type = ServiceType.fromValue(service.serviceType);

    return Scaffold(
      appBar: AppBar(
        title: Text(service.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
                '/service/${service.id}/edit?vehicleId=${service.vehicleId}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type + date hero card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(type.icon,
                        color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.label,
                            style: tt.labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        Text(service.title,
                            style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600)),
                        Text(
                          DateFormat('d MMMM yyyy', 'pl_PL')
                              .format(service.serviceDate),
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              if (service.mileage != null)
                Expanded(
                  child: _StatCard(
                    icon: Icons.speed,
                    label: 'Przebieg',
                    value:
                        '${NumberFormat('#,###').format(service.mileage)} km',
                  ),
                ),
              if (service.mileage != null && service.cost != null)
                const SizedBox(width: 12),
              if (service.cost != null)
                Expanded(
                  child: _StatCard(
                    icon: Icons.payments_outlined,
                    label: 'Koszt',
                    value:
                        '${NumberFormat('#,##0.00').format(service.cost)} zł',
                  ),
                ),
            ],
          ),
          if (service.workshop != null) ...[
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.store_outlined,
              label: 'Warsztat',
              value: service.workshop!,
            ),
          ],
          if (service.description != null &&
              service.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Opis', style: tt.titleSmall),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(service.description!),
              ),
            ),
          ],
          const SizedBox(height: 16),
          attachmentsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const SizedBox.shrink(),
            data: (attachments) {
              if (attachments.isEmpty) return const SizedBox.shrink();
              final images =
                  attachments.where((a) => a.fileType == 'IMAGE').toList();
              final pdfs =
                  attachments.where((a) => a.fileType == 'PDF').toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (images.isNotEmpty) ...[
                    Text('Zdjęcia', style: tt.titleSmall),
                    const SizedBox(height: 8),
                    _ImageGallery(images: images),
                    const SizedBox(height: 12),
                  ],
                  if (pdfs.isNotEmpty) ...[
                    Text('Faktury / PDF', style: tt.titleSmall),
                    const SizedBox(height: 8),
                    ...pdfs.map((pdf) => _PdfTile(attachment: pdf)),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń wpis'),
        content: const Text('Czy na pewno chcesz usunąć ten wpis serwisowy?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Anuluj')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // B2: delete with files; B3: stream emits null → auto-pop
              await ref
                  .read(serviceRepositoryProvider)
                  .deleteWithFiles(service.id);
            },
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                Text(value,
                    style: tt.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<Attachment> images;
  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final att = images[i];
          final f = File(att.filePath);
          return GestureDetector(
            onTap: () => _openFullscreen(context, images, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: f.existsSync()
                  ? Image.file(f, width: 120, height: 120, fit: BoxFit.cover)
                  : Container(
                      width: 120,
                      height: 120,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Icons.broken_image_outlined)),
            ),
          );
        },
      ),
    );
  }

  void _openFullscreen(
      BuildContext context, List<Attachment> images, int initial) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullscreenGallery(images: images, initial: initial),
    ));
  }
}

class _FullscreenGallery extends StatefulWidget {
  final List<Attachment> images;
  final int initial;
  const _FullscreenGallery({required this.images, required this.initial});

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${widget.initial + 1} / ${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.images.length,
        itemBuilder: (_, i) {
          final f = File(widget.images[i].filePath);
          return InteractiveViewer(
            child: Center(
              child: f.existsSync()
                  ? Image.file(f)
                  : const Icon(Icons.broken_image, color: Colors.white54),
            ),
          );
        },
      ),
    );
  }
}

class _PdfTile extends StatelessWidget {
  final Attachment attachment;
  const _PdfTile({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(attachment.fileName,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: const Text('Dotknij, żeby otworzyć'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async {
          final f = File(attachment.filePath);
          if (await f.exists()) {
            await OpenFile.open(attachment.filePath);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plik nie istnieje')));
            }
          }
        },
      ),
    );
  }
}
