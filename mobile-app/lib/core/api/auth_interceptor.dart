import 'package:dio/dio.dart';

import '../storage/token_store.dart';

/// Attaches the access token and renews it when it expires.
///
/// Refresh tokens are single-use and the server treats a second use as theft,
/// revoking the whole session. When several requests fail with 401 together,
/// only one of them may refresh. [QueuedInterceptor] handles errors one at a
/// time, so the first refreshes and the rest find a newer token already
/// stored and simply retry with it.
///
/// Retries go through [_plain], a client without this interceptor. Retrying
/// through the queued interceptor itself would deadlock if the retry also
/// failed, since its error would queue behind the one waiting for it.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStore tokens,
    required Dio plain,
    required void Function() onSessionExpired,
  })  : _tokens = tokens,
        _plain = plain,
        _onSessionExpired = onSessionExpired;

  /// A 401 from these means wrong credentials, not an expired token.
  static const _noRefreshPaths = ['/auth/login', '/auth/refresh', '/auth/google', '/auth/register'];

  final TokenStore _tokens;
  final Dio _plain;
  final void Function() _onSessionExpired;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokens.readAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final eligible = err.response?.statusCode == 401 &&
        request.extra['retried'] != true &&
        !_noRefreshPaths.any(request.path.startsWith);
    if (!eligible) return handler.next(err);

    try {
      final sent = request.headers['Authorization'];
      final current = await _tokens.readAccessToken();
      // Another request already refreshed while this one waited its turn.
      final token = current != null && 'Bearer $current' != sent ? current : await _refresh();

      request
        ..headers['Authorization'] = 'Bearer $token'
        ..extra['retried'] = true;
      handler.resolve(await _plain.fetch<dynamic>(request));
    } on _SessionEnded {
      await _tokens.clear();
      _onSessionExpired();
      handler.next(err);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String> _refresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) throw const _SessionEnded();

    final Response<Map<String, dynamic>> response;
    try {
      response = await _plain.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      // Refused outright: the session is over. A network failure is not
      // proof of that, so the tokens are kept for the next attempt.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) throw const _SessionEnded();
      rethrow;
    }

    final data = response.data!;
    final access = data['token'] as String;
    await _tokens.save(accessToken: access, refreshToken: data['refreshToken'] as String);
    return access;
  }
}

class _SessionEnded implements Exception {
  const _SessionEnded();
}
