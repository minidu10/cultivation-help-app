import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/crops/data/crop_repository.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/expenses/data/expense_repository.dart';
import '../../features/harvests/data/harvest_repository.dart';
import '../session/session_controller.dart';
import 'connection_status.dart';
import 'outbox.dart';

/// "The network came back": from the OS, or from a request that worked again.
/// A provider so tests can feed it without the platform plugin.
final networkChangesProvider = Provider<Stream<bool>>((ref) => Connectivity()
    .onConnectivityChanged
    .map((results) => results.any((r) => r != ConnectivityResult.none)));

/// Sends records saved offline whenever there is a chance they will get
/// through: at start, when the network returns, when a request starts working
/// again, and when the app comes back to the foreground.
class SyncCoordinator extends ConsumerStatefulWidget {
  const SyncCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncCoordinator> createState() => _SyncCoordinatorState();
}

class _SyncCoordinatorState extends ConsumerState<SyncCoordinator> with WidgetsBindingObserver {
  StreamSubscription<bool>? _network;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A synced record replaces its "waiting" copy on every screen showing it.
    ref.read(outboxProvider.notifier).onSynced = (cropId) {
      if (!mounted) return;
      ref
        ..invalidate(expensesProvider(cropId))
        ..invalidate(harvestsProvider(cropId))
        ..invalidate(profitLossProvider(cropId))
        ..invalidate(dashboardProvider);
    };
    try {
      _network = ref.read(networkChangesProvider).listen((up) {
        if (up) _flush();
      }, onError: (Object _) {});
    } on Exception {
      // No connectivity plugin (tests, unsupported platform): the other
      // triggers still apply.
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _flush());
  }

  void _flush() {
    if (!mounted || !ref.read(sessionControllerProvider).isSignedIn) return;
    unawaited(ref.read(outboxProvider.notifier).flush());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _flush();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_network?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(connectionStatusProvider, (wasOnline, online) {
      if (wasOnline == false && online) _flush();
    });
    return widget.child;
  }
}
