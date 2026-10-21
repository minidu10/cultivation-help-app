import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/format/labels.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/form_fields.dart';
import '../../auth/presentation/auth_widgets.dart';
import '../../auth/presentation/validators.dart';
import '../data/crop_models.dart';
import '../data/crop_repository.dart';

/// Add a crop, or edit one when [cropId] is given.
class CropFormScreen extends ConsumerWidget {
  const CropFormScreen({super.key, this.cropId});

  final int? cropId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = cropId;
    return Scaffold(
      appBar: AppBar(title: Text(id == null ? l10n.newCropTitle : l10n.editCrop)),
      body: id == null
          ? const _CropForm()
          : AsyncView(
              value: ref.watch(cropProvider(id)),
              onRetry: () => ref.invalidate(cropProvider(id)),
              data: (crop) => _CropForm(existing: crop),
            ),
    );
  }
}

class _CropForm extends ConsumerStatefulWidget {
  const _CropForm({this.existing});

  final Crop? existing;

  @override
  ConsumerState<_CropForm> createState() => _CropFormState();
}

class _CropFormState extends ConsumerState<_CropForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _variety = TextEditingController(text: widget.existing?.variety);
  late final _location = TextEditingController(text: widget.existing?.fieldLocation);
  late final _acres = TextEditingController(
    text: widget.existing?.fieldSizeAcres == null ? '' : '${widget.existing!.fieldSizeAcres}',
  );
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late DateTime? _planted = widget.existing?.plantingDate ?? DateTime.now();
  late DateTime? _harvest = widget.existing?.expectedHarvestDate;
  late CropStatus _status = widget.existing?.status ?? CropStatus.planted;
  late bool _aiInsights = widget.existing?.aiInsightsEnabled ?? true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _variety, _location, _acres, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final input = CropInput(
      name: _name.text,
      variety: _variety.text,
      fieldLocation: _location.text,
      fieldSizeAcres: parseAmount(_acres.text),
      plantingDate: _planted,
      expectedHarvestDate: _harvest,
      status: _status,
      aiInsightsEnabled: _aiInsights,
      notes: _notes.text,
    );
    final repo = ref.read(cropRepositoryProvider);
    try {
      final existing = widget.existing;
      final saved = existing == null ? await repo.create(input) : await repo.update(existing.id, input);
      invalidateCropFigures(ref, saved.id);
      if (!mounted) return;
      // A new crop opens on its own page; an edit returns to where it came from.
      if (existing == null) {
        context.pushReplacement('/crops/${saved.id}');
      } else {
        context.pop();
      }
    } on ApiException catch (e) {
      setState(() => _error = e.fieldErrors.values.firstOrNull ?? e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          FormError(_error),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            maxLength: 100,
            decoration: InputDecoration(labelText: l10n.cropNameLabel, prefixIcon: const Icon(Icons.grass), counterText: ''),
            validator: (v) => validateRequired(l10n, v),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _variety,
            maxLength: 100,
            decoration: InputDecoration(labelText: l10n.varietyLabel, prefixIcon: const Icon(Icons.local_florist_outlined), counterText: ''),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _location,
            maxLength: 200,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.fieldLocationLabel,
              helperText: l10n.fieldLocationHelper,
              prefixIcon: const Icon(Icons.location_on_outlined),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _acres,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.fieldSizeLabel, prefixIcon: const Icon(Icons.square_foot)),
            validator: (v) => validateAmount(l10n, v, decimals: 4, required: false),
          ),
          const SizedBox(height: 14),
          DateField(
            label: l10n.plantingDateLabel,
            value: _planted,
            onChanged: (d) => setState(() => _planted = d),
            validator: (_) => _planted == null ? l10n.requiredField : null,
          ),
          const SizedBox(height: 14),
          DateField(
            label: l10n.expectedHarvestLabel,
            value: _harvest,
            allowClear: true,
            onChanged: (d) => setState(() => _harvest = d),
            validator: (_) => _planted != null && _harvest != null && _harvest!.isBefore(_planted!)
                ? l10n.harvestBeforePlanting
                : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<CropStatus>(
            initialValue: _status,
            decoration: InputDecoration(labelText: l10n.statusLabel, prefixIcon: Icon(_status.icon)),
            items: [
              for (final s in CropStatus.values) DropdownMenuItem(value: s, child: Text(s.label(l10n))),
            ],
            onChanged: (s) => setState(() => _status = s ?? _status),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _notes,
            maxLength: 500,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.notesLabel, alignLabelWithHint: true),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _aiInsights,
            onChanged: (v) => setState(() => _aiInsights = v),
            title: Text(l10n.aiInsightsToggle),
            subtitle: Text(l10n.aiInsightsToggleHint),
          ),
          const SizedBox(height: 16),
          BusyButton(label: l10n.saveCrop, busy: _busy, onPressed: _save),
        ],
      ),
    );
  }
}
