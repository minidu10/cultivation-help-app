import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/format/labels.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/record_list.dart';
import '../../auth/presentation/auth_widgets.dart';
import '../../auth/presentation/validators.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../data/reminder_models.dart';
import '../data/reminder_repository.dart';

class RemindersTab extends ConsumerWidget {
  const RemindersTab({super.key, required this.cropId});

  final int cropId;

  void _refresh(WidgetRef ref) => ref
    ..invalidate(remindersProvider(cropId))
    ..invalidate(dashboardProvider);

  Future<void> _toggleDone(BuildContext context, WidgetRef ref, Reminder r) async {
    try {
      await ref.read(reminderRepositoryProvider).update(cropId, r.id, ReminderInput(completed: !r.completed));
      _refresh(ref);
    } on Exception catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Reminder r) async {
    if (!await confirmDelete(context, item: r.title)) return;
    try {
      await ref.read(reminderRepositoryProvider).delete(cropId, r.id);
      _refresh(ref);
    } on Exception catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = DateTime.now();
    return AsyncView(
      value: ref.watch(remindersProvider(cropId)),
      onRetry: () => ref.invalidate(remindersProvider(cropId)),
      data: (reminders) => RecordList<Reminder>(
        items: reminders,
        addLabel: l10n.addReminder,
        emptyText: l10n.noReminders,
        onAdd: () => showFormSheet<void>(context, ReminderSheet(cropId: cropId)),
        onEdit: (r) => showFormSheet<void>(context, ReminderSheet(cropId: cropId, existing: r)),
        onDelete: (r) => _delete(context, ref, r),
        tile: (r) => CheckboxListTile(
          value: r.completed,
          onChanged: (_) => _toggleDone(context, ref, r),
          controlAffinity: ListTileControlAffinity.leading,
          secondary: Icon(r.type.icon),
          title: Text(
            r.title,
            style: r.completed ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
          ),
          subtitle: Text([
            r.type.label(l10n),
            formatDateTime(context, r.reminderAt),
            if (!r.completed && r.reminderAt.isBefore(now)) l10n.overdue,
          ].join(' · ')),
        ),
      ),
    );
  }
}

class ReminderSheet extends ConsumerStatefulWidget {
  const ReminderSheet({super.key, required this.cropId, this.existing});

  final int cropId;
  final Reminder? existing;

  @override
  ConsumerState<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<ReminderSheet> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _note = TextEditingController(text: widget.existing?.note);
  late ReminderType _type = widget.existing?.type ?? ReminderType.fertilizer;
  late DateTime _when = widget.existing?.reminderAt ?? _tomorrowAtSeven();
  bool _busy = false;
  String? _error;

  static DateTime _tomorrowAtSeven() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 7);
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (time != null) {
      setState(() => _when = DateTime(_when.year, _when.month, _when.day, time.hour, time.minute));
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final input = ReminderInput(title: _title.text, type: _type, reminderAt: _when, note: _note.text);
    final repo = ref.read(reminderRepositoryProvider);
    try {
      final existing = widget.existing;
      if (existing == null) {
        await repo.add(widget.cropId, input);
      } else {
        await repo.update(widget.cropId, existing.id, input);
      }
      ref
        ..invalidate(remindersProvider(widget.cropId))
        ..invalidate(dashboardProvider);
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
    return Form(
      key: _form,
      child: FormSheet(
        title: widget.existing == null ? l10n.addReminder : l10n.editReminder,
        busy: _busy,
        onSave: _save,
        children: [
          FormError(_error),
          TextFormField(
            controller: _title,
            maxLength: 150,
            decoration: InputDecoration(labelText: l10n.titleLabel, counterText: ''),
            validator: (v) => validateRequired(l10n, v),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<ReminderType>(
            initialValue: _type,
            decoration: InputDecoration(labelText: l10n.typeLabel, prefixIcon: Icon(_type.icon)),
            items: [
              for (final t in ReminderType.values) DropdownMenuItem(value: t, child: Text(t.label(l10n))),
            ],
            onChanged: (t) => setState(() => _type = t ?? _type),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DateField(
                  label: l10n.whenLabel,
                  value: _when,
                  onChanged: (d) {
                    if (d != null) setState(() => _when = DateTime(d.year, d.month, d.day, _when.hour, _when.minute));
                  },
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(96, 56)),
                onPressed: _pickTime,
                child: Text(TimeOfDay.fromDateTime(_when).format(context)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _note,
            maxLength: 400,
            decoration: InputDecoration(labelText: l10n.noteLabel, counterText: ''),
          ),
        ],
      ),
    );
  }
}
