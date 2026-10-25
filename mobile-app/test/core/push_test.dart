import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:agromaster/core/push/push_messaging.dart';
import 'package:agromaster/core/push/push_registrar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMessaging implements PushMessaging {
  FakeMessaging({this.enabled = true, this.permission = true, this.currentToken = 'token-1'});

  @override
  final bool enabled;
  final bool permission;
  String? currentToken;
  final refreshes = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<String?> token() async => currentToken;

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;

  @override
  Stream<PushTap> get taps => const Stream.empty();

  @override
  Future<PushTap?> launchTap() async => null;

  @override
  String get platform => 'android';
}

class RecordingServer implements HttpClientAdapter {
  final calls = <String>[];
  final bodies = <Object?>[];
  bool down = false;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? body, Future<void>? cancel) async {
    if (down) throw DioException.connectionError(requestOptions: options, reason: 'down');
    calls.add('${options.method} ${options.path}');
    bodies.add(options.data);
    final reply = options.path == '/devices/test' ? {'sent': 1} : <String, Object>{};
    return ResponseBody.fromString(jsonEncode(reply), options.method == 'DELETE' ? 204 : 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late RecordingServer server;
  late Dio dio;

  setUp(() {
    server = RecordingServer();
    dio = Dio(BaseOptions(baseUrl: 'http://test/api'))..httpClientAdapter = server;
  });

  test('registers this phone with its platform after sign-in', () async {
    await PushRegistrar(FakeMessaging(), dio).register();

    expect(server.calls, ['POST /devices']);
    expect(server.bodies.single, {'token': 'token-1', 'platform': 'android'});
  });

  test('a rotated token is registered again', () async {
    final messaging = FakeMessaging();
    final registrar = PushRegistrar(messaging, dio);
    await registrar.register();

    messaging.refreshes.add('token-2');
    await pumpEventQueue();

    expect(server.bodies.last, {'token': 'token-2', 'platform': 'android'});
  });

  test('sign-out removes the last registered token', () async {
    final messaging = FakeMessaging();
    final registrar = PushRegistrar(messaging, dio);
    await registrar.register();
    messaging.refreshes.add('token:2');
    await pumpEventQueue();

    await registrar.unregister();

    expect(server.calls.last, 'DELETE /devices/token%3A2');
  });

  test('after sign-out a rotated token is not sent', () async {
    final messaging = FakeMessaging();
    final registrar = PushRegistrar(messaging, dio);
    await registrar.register();
    await registrar.unregister();
    final before = server.calls.length;

    messaging.refreshes.add('token-3');
    await pumpEventQueue();

    expect(server.calls.length, before);
  });

  test('a farmer who declines notifications is not registered', () async {
    await PushRegistrar(FakeMessaging(permission: false), dio).register();

    expect(server.calls, isEmpty);
  });

  test('with push not configured nothing is sent at all', () async {
    final registrar = PushRegistrar(const DisabledPushMessaging(), dio);

    await registrar.register();
    await registrar.unregister();

    expect(registrar.enabled, isFalse);
    expect(server.calls, isEmpty);
  });

  test('a registration failure never breaks sign-in', () async {
    server.down = true;

    await expectLater(PushRegistrar(FakeMessaging(), dio).register(), completes);
  });

  test('unregistering offline does not throw or hang', () async {
    final registrar = PushRegistrar(FakeMessaging(), dio);
    await registrar.register();
    server.down = true;

    await expectLater(registrar.unregister(), completes);
  });

  test('the test notification reports how many phones it reached', () async {
    expect(await PushRegistrar(FakeMessaging(), dio).sendTest(), 1);
  });

  test('a tap on a reminder notification knows its crop', () {
    expect(PushTap.fromData({'type': 'reminders', 'cropId': '42'}).cropId, 42);
    expect(PushTap.fromData({'type': 'test'}).cropId, isNull);
  });
}
