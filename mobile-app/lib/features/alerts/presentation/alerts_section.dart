import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/format/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../reminders/data/reminder_repository.dart';
import '../data/alert_models.dart';
import '../data/alert_repository.dart';

/// The dashboard's weather alerts: hidden when there is nothing to say, and
/// when the forecast cannot be reached. Weather is advice, so it never puts an
/// error on the farmer's home screen.
class AlertsSection extends ConsumerWidget {
  const AlertsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(weatherAlertsProvider).valueOrNull ?? const [];
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(context.l10n.alertsTitle),
        for (final alert in alerts)
          Padding(padding: const EdgeInsets.only(bottom: 10), child: AlertCard(alert)),
      ],
    );
  }
}

class AlertCard extends ConsumerStatefulWidget {
  const AlertCard(this.alert, {super.key});

  final WeatherAlert alert;

  @override
  ConsumerState<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends ConsumerState<AlertCard> {
  bool _moving = false;

  Future<void> _move() async {
    final a = widget.alert;
    final when = a.suggestedAt!;
    final l10n = context.l10n;
    final label = _when(context, when);
    setState(() => _moving = true);
    try {
      await ref.read(reminderRepositoryProvider).update(a.cropId!, a.reminderId!, ReminderInput(reminderAt: when));
      ref
        ..invalidate(weatherAlertsProvider)
        ..invalidate(dashboardProvider)
        ..invalidate(remindersProvider(a.cropId!));
      if (mounted) showMessage(context, l10n.rescheduledTo(label));
    } on Exception catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _moving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alert;
    final theme = Theme.of(context);
    final color = a.severity == AlertSeverity.high ? Brand.loss : Brand.amber;
    return Card(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon(a.type), color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alertTitle(context.l10n, a),
                    style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(alertBody(context, a), style: theme.textTheme.bodyMedium),
                  if (a.canReschedule) ...[
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                      onPressed: _moving ? null : _move,
                      icon: _moving
                          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.event_repeat, size: 18),
                      label: Text(context.l10n.moveTo(_when(context, a.suggestedAt!))),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _when(BuildContext context, DateTime t) =>
    '${DateFormat.MMMEd(context.localeName).format(t)}, ${DateFormat.jm(context.localeName).format(t)}';

IconData _icon(AlertType type) => switch (type) {
      AlertType.rainWashoff => Icons.water_drop,
      AlertType.sprayWind => Icons.air,
      AlertType.irrigationRain => Icons.umbrella,
      AlertType.harvestRain => Icons.agriculture,
      AlertType.heatStress => Icons.thermostat,
      AlertType.unknown => Icons.warning_amber_rounded,
    };

String alertTitle(AppLocalizations l10n, WeatherAlert a) => switch (a.type) {
      AlertType.rainWashoff => l10n.alertWashoffTitle,
      AlertType.sprayWind => l10n.alertWindTitle,
      AlertType.irrigationRain => l10n.alertIrrigationTitle,
      AlertType.harvestRain => l10n.alertHarvestTitle,
      AlertType.heatStress => l10n.alertHeatTitle,
      AlertType.unknown => a.reminderTitle ?? a.cropName,
    };

/// Written from the figures in the farmer's language; the server's English
/// sentence is only used for an alert type this app version does not know.
String alertBody(BuildContext context, WeatherAlert a) {
  final l10n = context.l10n;
  final day = DateFormat.MMMEd(context.localeName).format(a.date);
  final task = a.reminderTitle ?? '';
  return switch (a.type) {
    AlertType.rainWashoff => l10n.alertWashoffBody(day, a.rainChancePercent, task, a.cropName),
    AlertType.sprayWind => l10n.alertWindBody(a.windSpeed.toStringAsFixed(1), day, a.cropName),
    AlertType.irrigationRain => l10n.alertIrrigationBody(day, a.rainChancePercent, task, a.cropName),
    AlertType.harvestRain => l10n.alertHarvestBody(day, a.rainChancePercent, a.cropName),
    AlertType.heatStress => l10n.alertHeatBody(a.maxTempC.round(), a.location, day, a.cropName),
    AlertType.unknown => a.message,
  };
}
