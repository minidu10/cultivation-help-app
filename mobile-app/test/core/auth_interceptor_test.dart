import 'dart:convert';
import 'dart:typed_data';

import 'package:agromaster/core/api/auth_interceptor.dart';
import 'package:agromaster/core/storage/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A tiny in-memory AgroMaster: one protected route and a refresh endpoint
/// that, like the real one, accepts each refresh token exactly once.
class FakeBackend implements HttpClientAdapter {
  FakeBackend({this.validRefreshToken = 'refresh-1'});

  String? validRefreshToken;

  /// What a successful refresh hands out, and what the protected route accepts.
  /// Normally the same; a test can make them differ to force a failing retry.
  String issuedAccessToken = 'access-2';
  String acceptedAccessToken = 'access-2';
  int refreshCalls = 0;
  bool refreshUnreachable = false;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    // Let concurrent requests genuinely overlap.
    await Future<void>.delayed(const Duration(milliseconds: 5));

    if (options.path == '/auth/refresh') {
      refreshCalls++;
      if (refreshUnreachable) {
        throw DioException.connectionError(requestOptions: options, reason: 'offline');
      }
      final presented = (options.data as Map)['refreshToken'];
      if (presented != validRefreshToken) return _json(401, {'message': 'Your session has ended.'});
      validRefreshToken = null; // spent
      return _json(200, {'token': issuedAccessToken, 'refreshToken': 'refresh-2', 'expiresIn': 1800});
    }
    if (options.path == '/auth/login') return _json(401, {'message': 'Invalid email or password'});
    if (options.path == '/crops/1/insights') return _json(403, {'message': 'AI insights are off'});

    final auth = options.headers['Authorization'];
    return auth == 'Bearer $acceptedAccessToken' ? _json(200, {'ok': true, 'path': options.path}) : _json(401, {});
  }

  static ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeBackend backend;
  late MemoryTokenStore tokens;
  late Dio api;
  late int expiredCalls;

  setUp(() {
    backend = FakeBackend();
    tokens = MemoryTokenStore(accessToken: 'access-1', refreshToken: 'refresh-1');
    expiredCalls = 0;
    final plain = Dio(BaseOptions(baseUrl: 'http://test/api'))..httpClientAdapter = backend;
    api = Dio(BaseOptions(baseUrl: 'http://test/api'))
      ..httpClientAdapter = backend
      ..interceptors.add(AuthInterceptor(tokens: tokens, plain: plain, onSessionExpired: () => expiredCalls++));
  });

  test('sends the stored access token', () async {
    backend.acceptedAccessToken = 'access-1';

    final res = await api.get<Map<String, dynamic>>('/crops');

    expect(res.data!['ok'], isTrue);
    expect(backend.requests.single.headers['Authorization'], 'Bearer access-1');
  });

  test('refreshes an expired token and retries the request', () async {
    final res = await api.get<Map<String, dynamic>>('/crops');

    expect(res.data!['ok'], isTrue);
    expect(backend.refreshCalls, 1);
    expect(tokens.accessToken, 'access-2');
    expect(tokens.refreshToken, 'refresh-2');
  });

  // The server accepts each refresh token once. If two requests both
  // refreshed, the second would present a spent token and be refused, so
  // this only passes when exactly one refresh happens.
  test('requests that expire together share a single refresh', () async {
    final results = await Future.wait([
      api.get<Map<String, dynamic>>('/crops'),
      api.get<Map<String, dynamic>>('/reminders/due'),
      api.get<Map<String, dynamic>>('/users/me'),
    ]);

    expect(results.map((r) => r.data!['ok']), everyElement(isTrue));
    expect(backend.refreshCalls, 1);
    expect(expiredCalls, 0);
  });

  test('a refused refresh ends the session', () async {
    backend.validRefreshToken = 'something-else';

    await expectLater(api.get<void>('/crops'), throwsA(isA<DioException>()));

    expect(expiredCalls, 1);
    expect(tokens.accessToken, isNull);
    expect(tokens.refreshToken, isNull);
  });

  test('with no refresh token stored, the session ends without calling the server', () async {
    tokens.refreshToken = null;

    await expectLater(api.get<void>('/crops'), throwsA(isA<DioException>()));

    expect(backend.refreshCalls, 0);
    expect(expiredCalls, 1);
  });

  test('a network failure while refreshing keeps the tokens for next time', () async {
    backend.refreshUnreachable = true;

    await expectLater(api.get<void>('/crops'), throwsA(isA<DioException>()));

    expect(expiredCalls, 0);
    expect(tokens.refreshToken, 'refresh-1');
  });

  test('a 401 from login means wrong credentials, not an expired session', () async {
    await expectLater(
      api.post<void>('/auth/login', data: {'email': 'a@b.c', 'password': 'x'}),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 401)),
    );

    expect(backend.refreshCalls, 0);
    expect(expiredCalls, 0);
  });

  test('business-rule 403s pass straight through', () async {
    await expectLater(
      api.get<void>('/crops/1/insights'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 403)),
    );

    expect(backend.refreshCalls, 0);
    expect(tokens.accessToken, 'access-1');
  });

  test('a retry that still fails is not retried again', () async {
    backend.acceptedAccessToken = 'never-matches';

    await expectLater(api.get<void>('/crops'), throwsA(isA<DioException>()));

    // Original, refresh, one retry: no loop.
    expect(backend.requests.where((r) => r.path == '/crops'), hasLength(2));
  });
}
