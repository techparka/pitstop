import 'package:drift/drift.dart' show OrderingTerm;
import '../../garage/garage_providers.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';

import '../../../core/l10n/app_formats.dart';
import '../../../core/l10n/labels.dart';

import '../../../core/utils/file_helper.dart';
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
      error: (e, _) => Scaffold(
          body: Center(child: Text(context.l10n.errorWithDetails('$e')))),
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
    final attachmentsAsync = ref.watch(attachmentsProvider(service.id));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final type = ServiceType.fromValue(service.serviceType);

    return Scaffold(
      appBar: AppBar(
        title: Text(service.title),
        actions: [
          IconButton(
            tooltip: context.l10n.editServiceTooltip,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
                '/service/${service.id}/edit?vehicleId=${service.vehicleId}'),
          ),
          IconButton(
            tooltip: context.l10n.deleteServiceTooltip,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder(
              future: (ref.read(garageRepositoryProvider).db.select(
                      ref.read(garageRepositoryProvider).db.serviceItems)
                    ..where((i) => i.serviceId.equals(service.id))
                    ..orderBy([(i) => OrderingTerm.asc(i.id)]))
                  .get(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (items.isEmpty) return const SizedBox();
                return Card(
                    child: Column(children: [
                  ListTile(title: Text(context.l10n.serviceItemsSection)),
                  ...items.map((i) => ListTile(
                      title: Text(i.name),
                      subtitle: Text(itemKindLabel(context, i.kind)),
                      trailing: Text(context.fmt.money(i.amountCents))))
                ]));
              }),
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
                    child: Icon(type.icon, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.label(context),
                            style: tt.labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        Text(service.title,
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          context.fmt.dateLong(service.serviceDate),
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
                    label: context.l10n.mileageLabel,
                    value: context.km(service.mileage!),
                  ),
                ),
              if (service.mileage != null && service.cost != null)
                const SizedBox(width: 12),
              if (service.cost != null)
                Expanded(
                  child: _StatCard(
                    icon: Icons.payments_outlined,
                    label: context.l10n.costLabel,
                    value: context.fmt
                        .moneyFromZloty(service.cost!),
                  ),
                ),
            ],
          ),
          if (service.workshop != null) ...[
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.store_outlined,
              label: context.l10n.workshopLabel,
              value: service.workshop!,
            ),
          ],
          if (service.description != null &&
              service.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(context.l10n.descriptionSection, style: tt.titleSmall),
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
              final invoices = attachments.where(
                  (a) => a.fileType == 'PDF' || a.fileType == 'INVOICE_IMAGE');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (images.isNotEmpty) ...[
                    Text(context.l10n.photosSection,
                        style: tt.titleSmall),
                    const SizedBox(height: 8),
                    _ImageGallery(images: images),
                    const SizedBox(height: 12),
                  ],
                  if (invoices.isNotEmpty) ...[
                    Text(context.l10n.invoicesSection,
                        style: tt.titleSmall),
                    const SizedBox(height: 8),
                    ...invoices
                        .map((invoice) => _InvoiceTile(attachment: invoice)),
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
        title: Text(context.l10n.deleteEntryTitle),
        content: Text(context.l10n.deleteServiceConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancelAction)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // B2: delete with files; B3: stream emits null → auto-pop
              await ref
                  .read(serviceRepositoryProvider)
                  .deleteWithFiles(service.id);
            },
            child: Text(context.l10n.deleteAction),
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
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                Text(value,
                    style:
                        tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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
            onTap: () => _FullscreenGallery.open(context, images, i),
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
}

class _FullscreenGallery extends StatefulWidget {
  final List<Attachment> images;
  final int initial;
  const _FullscreenGallery({required this.images, required this.initial});

  static void open(BuildContext context, List<Attachment> images, int initial) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _FullscreenGallery(images: images, initial: initial),
    ));
  }

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
        title: Text(widget.images.length == 1
            ? widget.images.single.fileName
            : '${widget.initial + 1} / ${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.images.length,
        itemBuilder: (_, i) {
          final f = File(widget.images[i].filePath);
          return InteractiveViewer(
            child: Center(
              child: Image.file(
                f,
                errorBuilder: (_, __, ___) => Text(
                  context.l10n.imageUnavailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final Attachment attachment;
  const _InvoiceTile({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.fileType == 'INVOICE_IMAGE' ||
        FileHelper.isInvoiceImagePath(attachment.fileName) ||
        FileHelper.isInvoiceImagePath(attachment.filePath);
    return Card(
      child: ListTile(
        leading: isImage
            ? const Icon(Icons.image_outlined)
            : const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(attachment.fileName,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(context.l10n.tapToOpen),
        trailing: Icon(isImage ? Icons.zoom_in : Icons.open_in_new),
        onTap: isImage
            ? () => _FullscreenGallery.open(context, [attachment], 0)
            : () => _openPdf(context),
      ),
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    // Teksty pobierane przed `await`ami - potem kontekst moze byc juz nieaktualny.
    final l = context.l10n;
    String message;
    try {
      if (!await File(attachment.filePath).exists()) {
        message = l.invoiceFileMissing;
      } else {
        final result = await OpenFile.open(
          attachment.filePath,
          type: 'application/pdf',
        );
        switch (result.type) {
          case ResultType.done:
            return;
          case ResultType.fileNotFound:
            message = l.invoiceFileMissing;
          case ResultType.noAppToOpen:
            message = l.noPdfApp;
          case ResultType.permissionDenied:
            message = l.invoiceAccessDenied;
          case ResultType.error:
            message = l.pdfOpenFailed;
        }
      }
    } catch (_) {
      message = l.pdfOpenFailed;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
