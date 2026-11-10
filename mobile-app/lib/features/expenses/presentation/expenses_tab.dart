import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/format/labels.dart';
import '../../../core/offline/outbox.dart';
import '../../../core/offline/pending_records.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/record_list.dart';
import '../../auth/presentation/auth_widgets.dart';
import '../../auth/presentation/validators.dart';
import '../../crops/data/crop_repository.dart';
import '../data/expense_models.dart';
import '../data/expense_repository.dart';

class ExpensesTab extends ConsumerWidget {
  const ExpensesTab({super.key, required this.cropId});

  final int cropId;

  Future<void> _delete(BuildContext context, WidgetRef ref, Expense e) async {
    if (!await confirmDelete(context, item: e.description)) return;
    try {
      await ref.read(expenseRepositoryProvider).delete(cropId, e.id);
      ref.invalidate(expensesProvider(cropId));
      invalidateCropFigures(ref, cropId);
    } on Exception catch (err) {
      if (context.mounted) showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pending = ref.watch(outboxProvider.select((o) => o.forCrop(cropId, OutboxKind.expense)));
    return AsyncView(
      value: ref.watch(expensesProvider(cropId)),
      onRetry: () => ref.invalidate(expensesProvider(cropId)),
      data: (expenses) {
        final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        return RecordList<Expense>(
          items: expenses,
          addLabel: l10n.addExpense,
          emptyText: l10n.noExpenses,
          onAdd: () => showFormSheet<void>(context, ExpenseSheet(cropId: cropId)),
          onEdit: (e) => showFormSheet<void>(context, ExpenseSheet(cropId: cropId, existing: e)),
          onDelete: (e) => _delete(context, ref, e),
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PendingRecords(pending),
              if (expenses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '${l10n.totalLabel}: ${formatMoney(context, total)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Brand.loss),
                  ),
                ),
            ],
          ),
          tile: (e) => ListTile(
            leading: CircleAvatar(child: Icon(e.category.icon, size: 20)),
            title: Text(e.description),
            subtitle: Text('${e.category.label(l10n)} · ${formatDate(context, e.expenseDate)}'),
            trailing: Text(
              formatMoney(context, e.amount),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Brand.loss, fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}

class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({super.key, required this.cropId, this.existing});

  final int cropId;
  final Expense? existing;

  @override
  ConsumerState<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<ExpenseSheet> {
  final _form = GlobalKey<FormState>();
  late final _description = TextEditingController(text: widget.existing?.description);
  late final _amount = TextEditingController(text: widget.existing == null ? '' : _plain(widget.existing!.amount));
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late ExpenseCategory _category = widget.existing?.category ?? ExpenseCategory.fertilizer;
  late DateTime? _date = widget.existing?.expenseDate ?? DateTime.now();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final existing = widget.existing;
    final input = ExpenseInput(
      category: _category,
      description: _description.text,
      amount: parseAmount(_amount.text),
      expenseDate: _date,
      notes: _notes.text,
      // Every new record gets one, so a lost reply can be resent safely.
      clientRef: existing == null ? const Uuid().v4() : null,
    );
    final repo = ref.read(expenseRepositoryProvider);
    try {
      if (existing == null) {
        await repo.add(widget.cropId, input);
      } else {
        await repo.update(widget.cropId, existing.id, input);
      }
      ref.invalidate(expensesProvider(widget.cropId));
      invalidateCropFigures(ref, widget.cropId);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (e.offline && existing == null) {
        await _queue(input);
      } else if (e.offline) {
        setState(() => _error = context.l10n.editNeedsConnection);
      } else {
        setState(() => _error = e.fieldErrors.values.firstOrNull ?? e.message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// No signal: keep it on the phone and send it later.
  Future<void> _queue(ExpenseInput input) async {
    await ref.read(outboxProvider.notifier).enqueue(OutboxEntry(
          clientRef: input.clientRef!,
          kind: OutboxKind.expense,
          cropId: widget.cropId,
          body: input.toJson(),
          label: '${input.description?.trim()} · ${formatMoney(context, input.amount ?? 0)}',
          createdAt: DateTime.now(),
        ));
    if (!mounted) return;
    final message = context.l10n.savedOffline;
    Navigator.pop(context);
    showMessage(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _form,
      child: FormSheet(
        title: widget.existing == null ? l10n.addExpense : l10n.editExpense,
        busy: _busy,
        onSave: _save,
        children: [
          FormError(_error),
          DropdownButtonFormField<ExpenseCategory>(
            initialValue: _category,
            decoration: InputDecoration(labelText: l10n.categoryLabel, prefixIcon: Icon(_category.icon)),
            items: [
              for (final c in ExpenseCategory.values) DropdownMenuItem(value: c, child: Text(c.label(l10n))),
            ],
            onChanged: (c) => setState(() => _category = c ?? _category),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('expense-description'),
            controller: _description,
            maxLength: 200,
            decoration: InputDecoration(labelText: l10n.descriptionLabel, counterText: ''),
            validator: (v) => validateRequired(l10n, v),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('expense-amount'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.amountLabel, prefixIcon: const Icon(Icons.payments_outlined)),
            validator: (v) => validateAmount(l10n, v),
          ),
          const SizedBox(height: 14),
          DateField(
            label: l10n.dateLabel,
            value: _date,
            onChanged: (d) => setState(() => _date = d),
            validator: (_) => _date == null ? l10n.requiredField : null,
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

/// 4500.0 → "4500", 4750.5 → "4750.5": what a person would have typed.
String _plain(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
