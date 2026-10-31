import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../format/formatters.dart';
import '../session/session_controller.dart';
import 'connection_status.dart';
import 'outbox.dart';

/// A strip across the top of every screen while offline or while records
/// are waiting to send. Hidden when there is nothing to say.
class OfflineFrame extends ConsumerWidget {
  const OfflineFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionControllerProvider.select((s) => s.isSignedIn));
    final online = ref.watch(connectionStatusProvider);
    final outbox = ref.watch(outboxProvider);
    final visible = signedIn && (!online || outbox.pending.isNotEmpty || outbox.rejected.isNotEmpty);
    if (!visible) return child;

    return Column(
      children: [
        _Banner(online: online, outbox: outbox),
        // The banner now owns the status-bar inset, so the page below must not add it again.
        Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
      ],
    );
  }
}

class _Banner extends ConsumerWidget {
  const _Banner({required this.online, required this.outbox});

  final bool online;
  final OutboxState outbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final rejected = outbox.rejected.isNotEmpty;
    final background = rejected ? scheme.errorContainer : (online ? scheme.secondaryContainer : scheme.tertiaryContainer);
    final foreground = rejected
        ? scheme.onErrorContainer
        : (online ? scheme.onSecondaryContainer : scheme.onTertiaryContainer);

    final lines = [
      if (!online) l10n.offlineBanner,
      if (outbox.pending.isNotEmpty) l10n.pendingCount(outbox.pending.length),
      if (rejected) l10n.rejectedRecords(outbox.rejected.join(', ')),
    ];

    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          child: Row(
            children: [
              Icon(online ? Icons.cloud_upload_outlined : Icons.cloud_off_outlined, size: 20, color: foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Text(lines.join(' · '), style: TextStyle(color: foreground, fontSize: 13)),
              ),
              if (rejected)
                TextButton(
                  onPressed: () => ref.read(outboxProvider.notifier).dismissRejected(),
                  child: Text(l10n.dismiss, style: TextStyle(color: foreground)),
                )
              else if (outbox.pending.isNotEmpty)
                TextButton(
                  onPressed: outbox.syncing ? null : () => ref.read(outboxProvider.notifier).flush(),
                  child: Text(outbox.syncing ? l10n.syncing : l10n.syncNow, style: TextStyle(color: foreground)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
