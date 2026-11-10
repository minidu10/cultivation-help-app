import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../format/formatters.dart';

/// A read-only field that opens a date picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.allowClear = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool allowClear;

  @override
  Widget build(BuildContext context) => FormField<DateTime>(
        initialValue: value,
        validator: validator,
        builder: (state) => InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: firstDate ?? DateTime(now.year - 5),
              lastDate: lastDate ?? DateTime(now.year + 3),
            );
            if (picked != null) {
              state.didChange(picked);
              onChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: state.errorText,
              prefixIcon: const Icon(Icons.event_outlined),
              suffixIcon: allowClear && value != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        state.didChange(null);
                        onChanged(null);
                      },
                    )
                  : null,
            ),
            child: Text(value == null ? context.l10n.pickDate : formatDate(context, value!)),
          ),
        ),
      );
}

/// A number the server stores as NUMERIC(p, s): positive, and with at most
/// [decimals] places. Mirrors the backend's @Digits/@Positive checks.
String? validateAmount(AppLocalizations l10n, String? value, {int decimals = 2, bool required = true, bool allowZero = false}) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return required ? l10n.requiredField : null;
  final parsed = double.tryParse(v.replaceAll(',', ''));
  if (parsed == null) return l10n.invalidNumber;
  if (allowZero ? parsed < 0 : parsed <= 0) return l10n.mustBePositive;
  final dot = v.indexOf('.');
  if (dot >= 0 && v.length - dot - 1 > decimals) return l10n.tooManyDecimals;
  return null;
}

double? parseAmount(String text) => double.tryParse(text.trim().replaceAll(',', ''));

/// Bottom-sheet frame for the add/edit forms: title, scrollable body that
/// stays above the keyboard, and a save button.
class FormSheet extends StatelessWidget {
  const FormSheet({super.key, required this.title, required this.children, required this.onSave, required this.busy});

  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final bool busy;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...children,
              const SizedBox(height: 20),
              FilledButton(
                onPressed: busy ? null : onSave,
                child: busy
                    ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                    : Text(context.l10n.save),
              ),
            ],
          ),
        ),
      );
}

Future<T?> showFormSheet<T>(BuildContext context, Widget sheet) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => sheet,
    );
