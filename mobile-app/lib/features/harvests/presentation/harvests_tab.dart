import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/format/labels.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/record_list.dart';
import '../../auth/presentation/auth_widgets.dart';
import '../../crops/data/crop_repository.dart';
import '../data/harvest_models.dart';
import '../data/harvest_repository.dart';

class HarvestsTab extends ConsumerWidget {
  const HarvestsTab({super.key, required this.cropId});

  final int cropId;

  Future<void> _delete(BuildContext context, WidgetRef ref, Harvest h) async {
    final label = '${formatNumber(context, h.quantity)} ${h.unit.label(context.l10n)}';
    if (!await confirmDelete(context, item: label)) return;
    try {
      await ref.read(harvestRepositoryProvider).delete(cropId, h.id);
      ref.invalidate(harvestsProvider(cropId));
      invalidateCropFigures(ref, cropId);
    } on Exception catch (err) {
      if (context.mounted) showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncView(
      value: ref.watch(harvestsProvider(cropId)),
      onRetry: () => ref.invalidate(harvestsProvider(cropId)),
      data: (harvests) {
        final total = harvests.fold<double>(0, (sum, h) => sum + h.totalRevenue);
        return RecordList<Harvest>(
          items: harvests,
          addLabel: l10n.addHarvest,
          emptyText: l10n.noHarvests,
          onAdd: () => showFormSheet<void>(context, HarvestSheet(cropId: cropId)),
          onEdit: (h) => showFormSheet<void>(context, HarvestSheet(cropId: cropId, existing: h)),
          onDelete: (h) => _delete(context, ref, h),
          header: harvests.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '${l10n.totalLabel}: ${formatMoney(context, total)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Brand.profit),
                  ),
                ),
          tile: (h) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined, size: 20)),
            title: Text('${formatNumber(context, h.quantity)} ${h.unit.label(l10n)}'),
            subtitle: Text([
              formatDate(context, h.harvestDate),
              l10n.pricePer(formatMoney(context, h.pricePerUnit), h.unit.label(l10n)),
              if (h.buyerName?.isNotEmpty ?? false) h.buyerName!,
            ].join(' · ')),
            trailing: Text(
              formatMoney(context, h.totalRevenue),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Brand.profit, fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}

class HarvestSheet extends ConsumerStatefulWidget {
  const HarvestSheet({super.key, required this.cropId, this.existing});

  final int cropId;
  final Harvest? existing;

  @override
  ConsumerState<HarvestSheet> createState() => _HarvestSheetState();
}

class _HarvestSheetState extends ConsumerState<HarvestSheet> {
  final _form = GlobalKey<FormState>();
  late final _quantity = TextEditingController(text: _plain(widget.existing?.quantity));
  late final _price = TextEditingController(text: _plain(widget.existing?.pricePerUnit));
  late final _buyer = TextEditingController(text: widget.existing?.buyerName);
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late QuantityUnit _unit = widget.existing?.unit ?? QuantityUnit.kg;
  late DateTime? _date = widget.existing?.harvestDate ?? DateTime.now();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_quantity, _price, _buyer, _notes]) {
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
    final input = HarvestInput(
      harvestDate: _date,
      quantity: parseAmount(_quantity.text),
      unit: _unit,
      pricePerUnit: parseAmount(_price.text),
      buyerName: _buyer.text,
      notes: _notes.text,
    );
    final repo = ref.read(harvestRepositoryProvider);
    try {
      final existing = widget.existing;
      if (existing == null) {
        await repo.add(widget.cropId, input);
      } else {
        await repo.update(widget.cropId, existing.id, input);
      }
      ref.invalidate(harvestsProvider(widget.cropId));
      invalidateCropFigures(ref, widget.cropId);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.fieldErrors.values.firstOrNull ?? e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final quantity = parseAmount(_quantity.text);
    final price = parseAmount(_price.text);
    return Form(
      key: _form,
      child: FormSheet(
        title: widget.existing == null ? l10n.addHarvest : l10n.editHarvest,
        busy: _busy,
        onSave: _save,
        children: [
          FormError(_error),
          DateField(
            label: l10n.dateLabel,
            value: _date,
            onChanged: (d) => setState(() => _date = d),
            validator: (_) => _date == null ? l10n.requiredField : null,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _quantity,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.quantityLabel),
                  validator: (v) => validateAmount(l10n, v, decimals: 3),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<QuantityUnit>(
                  initialValue: _unit,
                  decoration: InputDecoration(labelText: l10n.unitLabel),
                  items: [
                    for (final u in QuantityUnit.values) DropdownMenuItem(value: u, child: Text(u.label(l10n))),
                  ],
                  onChanged: (u) => setState(() => _unit = u ?? _unit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.pricePerUnitLabel, prefixIcon: const Icon(Icons.sell_outlined)),
            validator: (v) => validateAmount(l10n, v, allowZero: true),
            onChanged: (_) => setState(() {}),
          ),
          if (quantity != null && price != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.estimatedRevenue(formatMoney(context, quantity * price)),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Brand.profit, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 14),
          TextFormField(
            controller: _buyer,
            maxLength: 200,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.buyerLabel, counterText: ''),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _notes,
            maxLength: 500,
            decoration: InputDecoration(labelText: l10n.notesLabel, counterText: ''),
          ),
        ],
      ),
    );
  }
}

String _plain(double? v) => v == null ? '' : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());
