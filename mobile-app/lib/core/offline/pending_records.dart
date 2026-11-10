import 'package:flutter/material.dart';

import '../format/formatters.dart';
import 'outbox.dart';

/// Records saved on this phone that have not reached the server yet.
class PendingRecords extends StatelessWidget {
  const PendingRecords(this.entries, {super.key});

  final List<OutboxEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: scheme.tertiaryContainer.withValues(alpha: 0.4),
        child: Column(
          children: [
            for (final e in entries)
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: Text(e.label),
                subtitle: Text(l10n.waitingToSend),
              ),
          ],
        ),
      ),
    );
  }
}
