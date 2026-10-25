import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'push_messaging.dart';

final pushRegistrarProvider = Provider<PushRegistrar>((ref) {
  final registrar = PushRegistrar(ref.watch(pushMessagingProvider), ref.watch(dioProvider));
  ref.onDispose(registrar.dispose);
  return registrar;
});

/// Keeps the server's list of this phone's push token current: registered
/// after sign-in, re-registered when Firebase rotates it, removed at sign-out
/// so the next person on the phone does not get someone else's reminders.
class PushRegistrar {
  PushRegistrar(this._messaging, this._dio);

  final PushMessaging _messaging;
  final Dio _dio;
  StreamSubscription<String>? _refreshes;
  String? _registered;

  bool get enabled => _messaging.enabled;

  Future<void> register() async {
    if (!_messaging.enabled) return;
    try {
      if (!await _messaging.requestPermission()) return;
      final token = await _messaging.token();
      if (token == null) return;
      await _send(token);
      await _refreshes?.cancel();
      _refreshes = _messaging.tokenRefreshes.listen((t) => unawaited(_send(t).catchError((Object _) {})));
    } on Exception catch (e) {
      // Push is a convenience; failing to set it up must never block sign-in.
      debugPrint('Push registration failed: $e');
    }
  }

  Future<void> unregister() async {
    await _refreshes?.cancel();
    _refreshes = null;
    final token = _registered;
    _registered = null;
    if (token == null) return;
    try {
      await _dio.delete<void>('/devices/${Uri.encodeComponent(token)}').timeout(const Duration(seconds: 5));
    } on Object catch (e) {
      debugPrint('Push unregistration failed: $e');
    }
  }

  Future<void> _send(String token) async {
    await _dio.post<void>('/devices', data: {'token': token, 'platform': _messaging.platform});
    _registered = token;
  }

  /// Asks the server to push "AgroMaster is connected" to this phone.
  /// Returns how many phones it reached.
  Future<int> sendTest() async {
    final res = await _dio.post<Map<String, dynamic>>('/devices/test');
    return (res.data?['sent'] as num?)?.toInt() ?? 0;
  }

  void dispose() => unawaited(_refreshes?.cancel());
}
