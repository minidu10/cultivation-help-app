import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/format/labels.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/common.dart';
import '../../reminders/data/reminder_models.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../weather/data/weather_repository.dart';
import '../../weather/presentation/weather_card.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = ref.watch(sessionControllerProvider.select((s) => s.user?.fullName)) ?? '';
    final summary = ref.watch(dashboardProvider);

    Future<void> refresh() {
      ref.invalidate(farmWeatherProvider);
      return settle(ref.refresh(dashboardProvider.future));
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Text(
                l10n.greeting(name.split(' ').first),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                l10n.dashboardSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              AsyncView(
                value: summary,
                onRetry: () => ref.invalidate(dashboardProvider),
                data: (data) => _SummaryBody(data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody(this.data);

  final DashboardSummary data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = data.totals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            StatTile(
              label: l10n.statRevenue,
              value: formatMoney(context, t.totalRevenue),
              icon: Icons.payments_outlined,
              color: Brand.profit,
            ),
            StatTile(
              label: l10n.statExpenses,
              value: formatMoney(context, t.totalExpenses),
              icon: Icons.receipt_long_outlined,
              color: Brand.loss,
            ),
            StatTile(
              label: l10n.statNetProfit,
              value: formatMoney(context, t.netProfit),
              icon: t.netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
              color: t.netProfit >= 0 ? Brand.profit : Brand.loss,
              caption: t.netProfit >= 0 ? l10n.profitLabel : l10n.lossLabel,
            ),
            StatTile(
              label: l10n.statActiveCrops,
              value: '${t.activeCrops}',
              icon: Icons.grass,
              color: Brand.leaf,
              caption: l10n.ofTotalCrops(t.totalCrops),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const WeatherCard(),
        SectionHeader(l10n.revenueVsExpenses),
        if (data.crops.isEmpty)
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Text(l10n.noCropData)))
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
              child: _CropChart(data.crops),
            ),
          ),
        SectionHeader(l10n.dueReminders),
        _ReminderList(reminders: data.dueReminders, cropNames: _names(data), emptyText: l10n.noDueReminders),
        if (data.upcomingReminders.isNotEmpty) ...[
          SectionHeader(l10n.upcomingReminders),
          _ReminderList(reminders: data.upcomingReminders, cropNames: _names(data)),
        ],
      ],
    );
  }

  static Map<int, String> _names(DashboardSummary data) => {for (final c in data.crops) c.cropId: c.cropName};
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.caption,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: theme.textTheme.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: color),
              ),
            ),
            if (caption != null)
              Text(caption!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _CropChart extends StatelessWidget {
  const _CropChart(this.crops);

  final List<CropSummary> crops;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final shown = crops.take(6).toList();
    final maxY = shown.fold<double>(0, (m, c) => [m, c.totalRevenue, c.totalExpenses].reduce((a, b) => a > b ? a : b));

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              maxY: maxY == 0 ? 1 : maxY * 1.15,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    formatMoney(context, rod.toY),
                    TextStyle(color: theme.colorScheme.onInverseSurface, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= shown.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          shown[i].cropName,
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < shown.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(toY: shown[i].totalRevenue, color: Brand.profit, width: 12, borderRadius: BorderRadius.circular(4)),
                      BarChartRodData(toY: shown[i].totalExpenses, color: Brand.loss, width: 12, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: Brand.profit, label: l10n.legendRevenue),
            const SizedBox(width: 20),
            _Legend(color: Brand.loss, label: l10n.legendExpenses),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      );
}

class _ReminderList extends ConsumerWidget {
  const _ReminderList({required this.reminders, required this.cropNames, this.emptyText});

  final List<Reminder> reminders;
  final Map<int, String> cropNames;
  final String? emptyText;

  Future<void> _markDone(BuildContext context, WidgetRef ref, Reminder r) async {
    try {
      await ref.read(reminderRepositoryProvider).update(r.cropId, r.id, const ReminderInput(completed: true));
      ref
        ..invalidate(dashboardProvider)
        ..invalidate(remindersProvider(r.cropId));
    } on Exception catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (reminders.isEmpty) {
      return Card(child: Padding(padding: const EdgeInsets.all(20), child: Text(emptyText ?? '')));
    }
    final now = DateTime.now();
    return Card(
      child: Column(
        children: [
          for (final r in reminders)
            ListTile(
              leading: CircleAvatar(child: Icon(r.type.icon, size: 20)),
              title: Text(r.title),
              subtitle: Text([
                cropNames[r.cropId] ?? '',
                formatDateTime(context, r.reminderAt),
                if (r.reminderAt.isBefore(now)) l10n.overdue,
              ].where((s) => s.isNotEmpty).join(' · ')),
              onTap: () => context.push('/crops/${r.cropId}'),
              trailing: IconButton(
                tooltip: l10n.markDone,
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _markDone(context, ref, r),
              ),
            ),
        ],
      ),
    );
  }
}
