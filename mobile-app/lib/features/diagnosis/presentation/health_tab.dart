import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/common.dart';
import '../../crops/data/crop_models.dart';
import '../data/diagnosis_models.dart';
import '../data/diagnosis_repository.dart';
import 'diagnosis_result.dart';
import 'scan_flow.dart';

/// A crop's photo history: was it blast in June, and did the treatment work?
class HealthTab extends ConsumerWidget {
  const HealthTab({super.key, required this.crop});

  final Crop crop;

  Future<void> _delete(BuildContext context, WidgetRef ref, Diagnosis d) async {
    if (!await confirmDelete(context, item: d.condition)) return;
    try {
      await ref.read(diagnosisRepositoryProvider).delete(crop.id, d.id!);
      ref.invalidate(diagnosesProvider(crop.id));
    } on Exception catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncView(
      value: ref.watch(diagnosesProvider(crop.id)),
      onRetry: () => ref.invalidate(diagnosesProvider(crop.id)),
      data: (history) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          OutlinedButton.icon(
            onPressed: () => startScan(context, ref, crop: crop),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l10n.checkPhoto),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(l10n.noDiagnoses)),
            )
          else
            for (final d in history)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HistoryCard(d, onDelete: () => _delete(context, ref, d)),
              ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard(this.d, {required this.onDelete});

  final Diagnosis d;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent = (d.confidence * 100).round();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: _Thumb(d.thumbnailUrl),
        title: Text(d.condition, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text([
          if (d.createdAt != null) formatDate(context, d.createdAt!),
          d.severity.label(l10n),
          l10n.diagnosisConfidence(percent),
        ].join(' · ')),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          DiagnosisResult(d),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.delete),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends ConsumerWidget {
  const _Thumb(this.url);

  final String? url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = Container(
      width: 48,
      height: 48,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_outlined),
    );
    final u = url;
    if (u == null) return placeholder;
    final bytes = ref.watch(thumbnailProvider(u)).valueOrNull;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: bytes == null ? placeholder : Image.memory(bytes, width: 48, height: 48, fit: BoxFit.cover),
    );
  }
}
