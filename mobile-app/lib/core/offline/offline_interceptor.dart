import 'dart:convert';

import 'package:dio/dio.dart';

import 'response_cache.dart';

/// Keeps the app usable without a signal.
///
/// Every successful JSON GET is saved. When a GET gets no reply at all, the
/// saved copy is returned instead, marked as stale, and [onOffline] fires so
/// the app can say so. Errors the server actually sent (a 404, a 403) are
/// never papered over with a cached answer: those are real.
class OfflineInterceptor extends Interceptor {
  OfflineInterceptor({required ResponseCache cache, required this.onOffline, required this.onOnline})
      : _cache = cache;

  /// Set on a response that came from the cache rather than the server.
  static const fromCacheKey = 'fromCache';

  final ResponseCache _cache;
  final void Function() onOffline;
  final void Function() onOnline;

  static String keyFor(RequestOptions options) {
    final query = options.queryParameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return query.isEmpty ? options.path : '${options.path}?${query.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  static bool _cacheable(RequestOptions options) =>
      options.method == 'GET' && options.responseType == ResponseType.json;

  @override
  Future<void> onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    onOnline();
    final options = response.requestOptions;
    final ok = (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;
    if (ok && _cacheable(options) && response.data != null) {
      await _cache.write(keyFor(options), jsonEncode(response.data));
    }
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      // The server answered; we are online, and the error stands.
      onOnline();
      return handler.next(err);
    }
    onOffline();
    final options = err.requestOptions;
    if (!_cacheable(options)) return handler.next(err);

    final cached = await _cache.read(keyFor(options));
    if (cached == null) return handler.next(err);
    handler.resolve(Response<dynamic>(
      requestOptions: options,
      statusCode: 200,
      data: jsonDecode(cached.body),
      extra: {fromCacheKey: true, 'cachedAt': cached.storedAt.toIso8601String()},
    ));
  }
}
