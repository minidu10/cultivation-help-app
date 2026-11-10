import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/format/labels.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/common.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../diagnosis/presentation/health_tab.dart';
import '../../expenses/presentation/expenses_tab.dart';
import '../../harvests/presentation/harvests_tab.dart';
import '../../reminders/presentation/reminders_tab.dart';
import '../data/crop_models.dart';
import '../data/crop_repository.dart';

class CropDetailScreen extends ConsumerWidget {
  const CropDetailScreen({super.key, required this.cropId});

  final int cropId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crop = ref.watch(cropProvider(cropId));
    return AsyncView(
      value: crop,
      onRetry: () => ref.invalidate(cropProvider(cropId)),
      loading: const Scaffold(body: Center(child: CircularProgressIndicator())),
      data: (c) => _CropDetail(c),
    );
  }
}

class _CropDetail extends ConsumerWidget {
  const _CropDetail(this.crop);

  final Crop crop;

  Future<void> _changeStatus(BuildContext context, WidgetRef ref, CropStatus status) async {
    try {
      await ref.read(cropRepositoryProvider).update(crop.id, CropInput(status: status));
      invalidateCropFigures(ref, crop.id);
    } on Exception catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    if (!await confirmDelete(context, item: crop.name, body: l10n.deleteCropBody)) return;
    try {
      await ref.read(cropRepositoryProvider).delete(crop.id);
      // Only the lists: refreshing the deleted crop itself would 404 on the
      // way out of its own page.
      ref
        ..invalidate(cropsProvider)
        ..invalidate(dashboardProvider);
      if (context.mounted) context.pop();
    } on Exception catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              title: Text(crop.name),
              actions: [
                IconButton(
                  tooltip: l10n.editCrop,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/crops/${crop.id}/edit'),
                ),
                PopupMenuButton<String>(
                  onSelected: (_) => _delete(context, ref),
                  itemBuilder: (_) => [PopupMenuItem(value: 'delete', child: Text(l10n.deleteCrop))],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        if (crop.variety?.isNotEmpty ?? false) crop.variety!,
                        l10n.plantedOn(formatDate(context, crop.plantingDate)),
                        if (crop.fieldSizeAcres != null) l10n.acres(formatNumber(context, crop.fieldSizeAcres!)),
                        if (crop.fieldLocation?.isNotEmpty ?? false) crop.fieldLocation!,
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    _StatusPicker(current: crop.status, onChanged: (s) => _changeStatus(context, ref, s)),
                    const SizedBox(height: 12),
                    _ProfitStrip(cropId: crop.id),
                    const SizedBox(height: 12),
                    _InsightCard(crop: crop),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeader(
                TabBar(
                  tabs: [
                    Tab(text: l10n.tabExpenses),
                    Tab(text: l10n.tabHarvests),
                    Tab(text: l10n.tabReminders),
                    Tab(text: l10n.tabHealth),
                  ],
                ),
                theme.scaffoldBackgroundColor,
              ),
            ),
          ],
          body: TabBarView(
            children: [
              ExpensesTab(cropId: crop.id),
              HarvestsTab(cropId: crop.id),
              RemindersTab(cropId: crop.id),
              HealthTab(crop: crop),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPicker extends StatelessWidget {
  const _StatusPicker({required this.current, required this.onChanged});

  final CropStatus current;
  final ValueChanged<CropStatus> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final s in CropStatus.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: Icon(s.icon, size: 16, color: s == current ? null : s.color),
                  label: Text(s.label(context.l10n)),
                  selected: s == current,
                  onSelected: s == current ? null : (_) => onChanged(s),
                ),
              ),
          ],
        ),
      );
}

class _ProfitStrip extends ConsumerWidget {
  const _ProfitStrip({required this.cropId});

  final int cropId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pl = ref.watch(profitLossProvider(cropId)).valueOrNull;
    Widget cell(String label, double? value, Color color) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value == null ? '—' : formatMoney(context, value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            cell(l10n.spentLabel, pl?.totalExpenses, Brand.loss),
            cell(l10n.earnedLabel, pl?.totalRevenue, Brand.profit),
            cell(l10n.netLabel, pl?.netProfit, (pl?.netProfit ?? 0) >= 0 ? Brand.profit : Brand.loss),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends ConsumerStatefulWidget {
  const _InsightCard({required this.crop});

  final Crop crop;

  @override
  ConsumerState<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends ConsumerState<_InsightCard> {
  bool _regenerating = false;

  Future<void> _regenerate() async {
    setState(() => _regenerating = true);
    try {
      await ref.read(cropRepositoryProvider).insight(widget.crop.id, refresh: true);
      ref.invalidate(cropInsightProvider(widget.crop.id));
    } on Exception catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _regenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (!widget.crop.aiInsightsEnabled) {
      return Text(l10n.aiInsightOff, style: theme.textTheme.bodySmall);
    }
    final insight = ref.watch(cropInsightProvider(widget.crop.id));
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(child: Text(l10n.aiInsightTitle, style: theme.textTheme.titleSmall)),
                TextButton(
                  onPressed: _regenerating || insight.isLoading ? null : _regenerate,
                  child: Text(l10n.refreshInsight),
                ),
              ],
            ),
            if (_regenerating || insight.isLoading)
              const LinearProgressIndicator()
            else
              insight.when(
                data: (i) => Text(i.insights, style: theme.textTheme.bodyMedium),
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text(
                  ApiException.from(e).statusCode == 503 ? l10n.aiInsightUnavailable : ApiException.from(e).message,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabBarHeader extends SliverPersistentHeaderDelegate {
  _TabBarHeader(this.tabBar, this.background);

  final TabBar tabBar;
  final Color background;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ColoredBox(color: background, child: tabBar);

  @override
  bool shouldRebuild(_TabBarHeader oldDelegate) => tabBar != oldDelegate.tabBar || background != oldDelegate.background;
}
