import 'package:flutter/material.dart';

import '../format/formatters.dart';

/// The body of a crop tab: an add button above a list of records, each with
/// edit and delete in a menu. Shared by expenses, harvests and reminders.
class RecordList<T> extends StatelessWidget {
  const RecordList({
    super.key,
    required this.items,
    required this.addLabel,
    required this.emptyText,
    required this.onAdd,
    required this.tile,
    required this.onEdit,
    required this.onDelete,
    this.header,
  });

  final List<T> items;
  final String addLabel;
  final String emptyText;
  final VoidCallback onAdd;
  final Widget Function(T item) tile;
  final void Function(T item) onEdit;
  final void Function(T item) onDelete;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(addLabel)),
        const SizedBox(height: 12),
        ?header,
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text(emptyText, style: Theme.of(context).textTheme.bodyMedium)),
          )
        else
          Card(
            child: Column(
              children: [
                for (final (i, item) in items.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                  Row(
                    children: [
                      Expanded(child: tile(item)),
                      PopupMenuButton<bool>(
                        onSelected: (edit) => edit ? onEdit(item) : onDelete(item),
                        itemBuilder: (_) => [
                          PopupMenuItem(value: true, child: Text(l10n.edit)),
                          PopupMenuItem(value: false, child: Text(l10n.delete)),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
