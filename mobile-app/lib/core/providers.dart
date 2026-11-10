import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/auth_interceptor.dart';
import 'env.dart';
import 'offline/connection_status.dart';
import 'offline/offline_interceptor.dart';
import 'offline/response_cache.dart';
import 'session/session_controller.dart';
import 'storage/token_store.dart';

/// Opened once in main() before the first frame; overridden there.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden in main()'),
);

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final responseCacheProvider = Provider<ResponseCache>(
  (ref) => PrefsResponseCache(ref.watch(sharedPreferencesProvider)),
);

BaseOptions _baseOptions() => BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      // AI answers can take most of a minute on a reasoning model.
      receiveTimeout: const Duration(seconds: 90),
      contentType: Headers.jsonContentType,
    );

/// No interceptors: used for refreshing tokens and replaying requests.
final plainDioProvider = Provider<Dio>((ref) => Dio(_baseOptions()));

/// The client every repository uses.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions());
  dio.interceptors
    ..add(AuthInterceptor(
      tokens: ref.watch(tokenStoreProvider),
      plain: ref.watch(plainDioProvider),
      onSessionExpired: () => ref.read(sessionControllerProvider.notifier).expire(),
    ))
    // After auth: an expired token is refreshed first; only a request that
    // got no reply at all falls back to the saved copy.
    ..add(OfflineInterceptor(
      cache: ref.watch(responseCacheProvider),
      onOffline: () => ref.read(connectionStatusProvider.notifier).offline(),
      onOnline: () => ref.read(connectionStatusProvider.notifier).online(),
    ));
  return dio;
});
