import 'package:flutter/material.dart';

import '../../../core/format/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/diagnosis_models.dart';

extension DiagnosisSeverityLabel on DiagnosisSeverity {
  String label(AppLocalizations l10n) => switch (this) {
        DiagnosisSeverity.none => l10n.severityNone,
        DiagnosisSeverity.low => l10n.severityLow,
        DiagnosisSeverity.moderate => l10n.severityModerate,
        DiagnosisSeverity.severe => l10n.severitySevere,
      };

  Color get color => switch (this) {
        DiagnosisSeverity.none => Brand.profit,
        DiagnosisSeverity.low => const Color(0xFF65A30D),
        DiagnosisSeverity.moderate => Brand.amber,
        DiagnosisSeverity.severe => Brand.loss,
      };
}

/// Everything the crop doctor said about one photo.
class DiagnosisResult extends StatelessWidget {
  const DiagnosisResult(this.diagnosis, {super.key, this.onRetake});

  final Diagnosis diagnosis;

  /// Shown on the "no plant in the photo" answer.
  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context) {
    final d = diagnosis;
    return d.isPlant ? _Findings(d) : _NotAPlant(onRetake: onRetake);
  }
}

class _Findings extends StatelessWidget {
  const _Findings(this.d);

  final Diagnosis d;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final percent = (d.confidence * 100).round();
    final barColor = percent >= 70 ? Brand.profit : (percent >= 50 ? Brand.amber : Brand.loss);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(d.condition, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            _SeverityChip(d.severity),
          ],
        ),
        if (d.cropGuess.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(l10n.diagnosisLooksLike(d.cropGuess), style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 14),
        Text(l10n.diagnosisConfidence(percent), style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: d.confidence,
            minHeight: 8,
            color: barColor,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            semanticsLabel: l10n.diagnosisConfidence(percent),
          ),
        ),
        if (d.seeExpert) ...[
          const SizedBox(height: 14),
          Container(
            key: const Key('see-expert'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent, color: theme.colorScheme.onSecondaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.diagnosisSeeExpert,
                    style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
        _Section(l10n.diagnosisSymptoms, d.symptoms, Icons.search),
        _Section(l10n.diagnosisOrganic, d.treatmentOrganic, Icons.eco_outlined, color: Brand.profit),
        _Section(l10n.diagnosisChemical, d.treatmentChemical, Icons.science_outlined, color: Brand.amber),
        if (d.treatmentChemical.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.diagnosisChemicalSafety, style: theme.textTheme.bodySmall),
          ),
        _Section(l10n.diagnosisPrevention, d.prevention, Icons.shield_outlined),
        const SizedBox(height: 16),
        Text(
          l10n.diagnosisDisclaimer,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip(this.severity);

  final DiagnosisSeverity severity;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: severity.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: severity.color.withValues(alpha: 0.5)),
        ),
        child: Text(
          severity.label(context.l10n),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: severity.color, fontWeight: FontWeight.w700),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.items, this.icon, {this.color});

  final String title;
  final List<String> items;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color ?? theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2),
              child: Text('• $item', style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _NotAPlant extends StatelessWidget {
  const _NotAPlant({this.onRetake});

  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.center_focus_weak, size: 48, color: Brand.amber),
        const SizedBox(height: 10),
        Text(l10n.diagnosisNotPlantTitle, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final tip in [l10n.diagnosisTipFrame, l10n.diagnosisTipLight, l10n.diagnosisTipSteady])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                const Icon(Icons.check, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(tip)),
              ],
            ),
          ),
        if (onRetake != null) ...[
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: onRetake, icon: const Icon(Icons.photo_camera), label: Text(l10n.diagnosisRetake)),
        ],
      ],
    );
  }
}
