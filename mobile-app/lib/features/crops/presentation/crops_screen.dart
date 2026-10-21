import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/format/labels.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/common.dart';
import '../data/crop_models.dart';
import '../data/crop_repository.dart';

class CropsScreen extends ConsumerStatefulWidget {
  const CropsScreen({super.key});

  @override
  ConsumerState<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends ConsumerState<CropsScreen> {
  /// Null shows every crop.
  CropStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final crops = ref.watch(cropsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cropsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-crop',
        onPressed: () => context.push('/crops/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addCrop),
      ),
      body: AsyncView(
        value: crops,
        onRetry: () => ref.invalidate(cropsProvider),
        data: (all) {
          if (all.isEmpty) {
            return EmptyState(icon: Icons.grass, title: l10n.noCrops, message: l10n.noCropsHint);
          }
          final shown = _filter == null ? all : all.where((c) => c.status == _filter).toList();
          return RefreshIndicator(
            onRefresh: () => settle(ref.refresh(cropsProvider.future)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
              children: [
                _FilterBar(
                  crops: all,
                  selected: _filter,
                  onSelected: (status) => setState(() => _filter = status),
                ),
                const SizedBox(height: 12),
                if (shown.isEmpty)
                  Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l10n.noCropsForFilter)))
                else
                  for (final crop in shown)
                    Padding(padding: const EdgeInsets.only(bottom: 10), child: CropCard(crop)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.crops, required this.selected, required this.onSelected});

  final List<Crop> crops;
  final CropStatus? selected;
  final ValueChanged<CropStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = {for (final s in CropStatus.values) s: crops.where((c) => c.status == s).length};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: Text('${l10n.filterAll} (${crops.length})'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final status in CropStatus.values)
            if (counts[status]! > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text('${status.label(l10n)} (${counts[status]})'),
                  selected: selected == status,
                  onSelected: (_) => onSelected(status),
                ),
              ),
        ],
      ),
    );
  }
}

class CropCard extends StatelessWidget {
  const CropCard(this.crop, {super.key});

  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/crops/${crop.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: crop.status.color.withValues(alpha: 0.15),
                child: Icon(crop.status.icon, color: crop.status.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [crop.name, if (crop.variety?.isNotEmpty ?? false) crop.variety].join(' · '),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        l10n.plantedOn(formatDate(context, crop.plantingDate)),
                        if (crop.fieldSizeAcres != null) l10n.acres(formatNumber(context, crop.fieldSizeAcres!)),
                        if (crop.fieldLocation?.isNotEmpty ?? false) crop.fieldLocation!,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    StatusChip(crop.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
