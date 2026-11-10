import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/widgets/async_view.dart';
import '../../crops/data/crop_models.dart';
import '../data/diagnosis_models.dart';
import '../data/diagnosis_repository.dart';
import 'diagnosis_result.dart';
import 'scan_flow.dart';

/// Sends one photo and shows the answer. The photo stays on screen while the
/// model works, so the farmer can see what is being judged.
class DiagnosisScreen extends ConsumerStatefulWidget {
  const DiagnosisScreen({super.key, required this.crop, required this.photo});

  final Crop crop;
  final Uint8List photo;

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  Diagnosis? _result;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _send();
  }

  Future<void> _send() async {
    setState(() {
      _result = null;
      _error = null;
    });
    try {
      final result = await ref.read(diagnosisRepositoryProvider).diagnose(widget.crop.id, widget.photo);
      if (result.id != null) ref.invalidate(diagnosesProvider(widget.crop.id));
      if (mounted) setState(() => _result = result);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _retake() {
    Navigator.of(context).pop();
    startScan(context, ref, crop: widget.crop);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final result = _result;
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.diagnosisTitle} · ${widget.crop.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // Capped so the answer stays in view on tablets and in landscape.
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 260,
              child: Image.memory(widget.photo, fit: BoxFit.cover, gaplessPlayback: true),
            ),
          ),
          const SizedBox(height: 20),
          if (error != null)
            ErrorView(message: error.message, onRetry: error.statusCode == 429 ? null : _send)
          else if (result == null)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 14),
                Text(l10n.diagnosisChecking, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l10n.diagnosisCheckingHint, style: theme.textTheme.bodySmall),
              ],
            )
          else ...[
            DiagnosisResult(result, onRetake: _retake),
            if (result.isPlant) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.done)),
            ],
          ],
        ],
      ),
    );
  }
}
