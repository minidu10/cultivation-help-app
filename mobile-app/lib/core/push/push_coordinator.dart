import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../session/session_controller.dart';
import 'push_messaging.dart';
import 'push_registrar.dart';

/// Registers the phone for push whenever someone is signed in, and opens the
/// crop a tapped notification is about.
class PushCoordinator extends ConsumerStatefulWidget {
  const PushCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushCoordinator> createState() => _PushCoordinatorState();
}

class _PushCoordinatorState extends ConsumerState<PushCoordinator> {
  StreamSubscription<PushTap>? _taps;

  @override
  void initState() {
    super.initState();
    final messaging = ref.read(pushMessagingProvider);
    if (!messaging.enabled) return;
    _taps = messaging.taps.listen(_open);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ref.read(sessionControllerProvider).isSignedIn) {
        unawaited(ref.read(pushRegistrarProvider).register());
      }
      final launch = await messaging.launchTap();
      if (launch != null) _open(launch);
    });
  }

  void _open(PushTap tap) {
    if (!mounted || !ref.read(sessionControllerProvider).isSignedIn) return;
    final cropId = tap.cropId;
    ref.read(routerProvider).push(cropId == null ? '/home' : '/crops/$cropId');
  }

  @override
  void dispose() {
    unawaited(_taps?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(sessionControllerProvider.select((s) => s.isSignedIn), (was, now) {
      if (now && was != true) unawaited(ref.read(pushRegistrarProvider).register());
    });
    return widget.child;
  }
}
