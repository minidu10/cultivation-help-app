import 'dart:convert';
import 'dart:typed_data';

import 'package:agromaster/core/offline/connection_status.dart';
import 'package:agromaster/core/offline/offline_interceptor.dart';
import 'package:agromaster/core/offline/outbox.dart';
import 'package:agromaster/core/offline/response_cache.dart';
import 'package:agromaster/core/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A server that can be unplugged. While offline every request fails with
/// no response, exactly as a phone with no signal sees it.
class Switchable implements HttpClientAdapter {
  bool online = true;
  final List<RequestOptions> requests = [];
  final Map<String, int> statusFor = {};

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? body, Future<void>? cancel) async {
    if (!online) throw DioException.connectionError(requestOptions: options, reason: 'no signal');
    requests.add(options);
    final status = statusFor[options.path] ?? 200;
    final payload = options.method == 'GET' ? {'path': options.path, 'n': requests.length} : {'id': requests.length};
    return ResponseBody.fromString(jsonEncode(status == 200 ? payload : {'message': 'refused'}), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Future<SharedPreferences> _prefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  group('OfflineInterceptor', () {
    late Switchable server;
    late Dio dio;
    late List<String> events;

    setUp(() async {
      server = Switchable();
      events = [];
      dio = Dio(BaseOptions(baseUrl: 'http://test/api'))
        ..httpClientAdapter = server
        ..interceptors.add(OfflineInterceptor(
          cache: PrefsResponseCache(await _prefs()),
          onOffline: () => events.add('offline'),
          onOnline: () => events.add('online'),
        ));
    });

    test('serves the last good answer when there is no signal', () async {
      final live = await dio.get<Map<String, dynamic>>('/crops');
      server.online = false;

      final saved = await dio.get<Map<String, dynamic>>('/crops');

      expect(saved.data, live.data);
      expect(saved.extra[OfflineInterceptor.fromCacheKey], isTrue);
      expect(events.last, 'offline');
    });

    test('a page never opened online still fails offline', () async {
      server.online = false;

      await expectLater(dio.get<void>('/crops/9/expenses'), throwsA(isA<DioException>()));
    });

    test('query parameters are part of the saved key', () async {
      await dio.get<void>('/weather/daily', queryParameters: {'lat': 7.9, 'lon': 81.0});
      server.online = false;

      await expectLater(
        dio.get<void>('/weather/daily', queryParameters: {'lat': 6.9, 'lon': 79.8}),
        throwsA(isA<DioException>()),
      );
      final same = await dio.get<void>('/weather/daily', queryParameters: {'lon': 81.0, 'lat': 7.9});
      expect(same.extra[OfflineInterceptor.fromCacheKey], isTrue);
    });

    test('a real refusal from the server is never hidden behind a saved copy', () async {
      await dio.get<void>('/crops/1');
      server.statusFor['/crops/1'] = 404;

      await expectLater(
        dio.get<void>('/crops/1'),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 404)),
      );
      expect(events.last, 'online');
    });

    test('writes are not answered from the cache', () async {
      server.online = false;

      await expectLater(dio.post<void>('/crops', data: {'name': 'Paddy'}), throwsA(isA<DioException>()));
    });
  });

  group('Outbox', () {
    late Switchable server;
    late ProviderContainer container;
    late List<int> synced;

    OutboxEntry entry(String ref, {int cropId = 7, OutboxKind kind = OutboxKind.expense}) => OutboxEntry(
          clientRef: ref,
          kind: kind,
          cropId: cropId,
          body: {'clientRef': ref, 'description': 'Urea', 'amount': 4500},
          label: 'Urea · Rs. 4,500',
          createdAt: DateTime(2026, 10, 25),
        );

    setUp(() async {
      server = Switchable();
      final prefs = await _prefs();
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))..httpClientAdapter = server;
      container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        dioProvider.overrideWithValue(dio),
      ]);
      synced = [];
      container.read(outboxProvider.notifier).onSynced = synced.add;
    });

    tearDown(() => container.dispose());

    OutboxController outbox() => container.read(outboxProvider.notifier);
    OutboxState state() => container.read(outboxProvider);

    test('sends everything waiting, oldest first, with its client reference', () async {
      await outbox().enqueue(entry('a'));
      await outbox().enqueue(entry('b', kind: OutboxKind.harvest, cropId: 8));

      await outbox().flush();

      expect(server.requests.map((r) => r.path), ['/crops/7/expenses', '/crops/8/harvests']);
      expect(server.requests.map((r) => (r.data as Map)['clientRef']), ['a', 'b']);
      expect(state().pending, isEmpty);
      expect(synced, [7, 8]);
    });

    test('still offline: nothing is lost and the order is kept', () async {
      await outbox().enqueue(entry('a'));
      await outbox().enqueue(entry('b'));
      server.online = false;

      await outbox().flush();

      expect(state().pending.map((e) => e.clientRef), ['a', 'b']);
      expect(state().syncing, isFalse);
    });

    test('survives the app being closed', () async {
      await outbox().enqueue(entry('a'));
      final prefs = container.read(sharedPreferencesProvider);

      final reopened = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
      addTearDown(reopened.dispose);

      expect(reopened.read(outboxProvider).pending.single.clientRef, 'a');
    });

    test('a record the server refuses is set aside, not retried forever', () async {
      server.statusFor['/crops/7/expenses'] = 404;
      await outbox().enqueue(entry('a'));
      await outbox().enqueue(entry('b', cropId: 8));

      await outbox().flush();

      expect(state().pending, isEmpty);
      expect(state().rejected, ['Urea · Rs. 4,500']);
      expect(server.requests.last.path, '/crops/8/expenses');
    });

    test('a server error leaves the record queued for the next try', () async {
      server.statusFor['/crops/7/expenses'] = 503;
      await outbox().enqueue(entry('a'));

      await outbox().flush();

      expect(state().pending, hasLength(1));
      expect(state().rejected, isEmpty);
    });

    test('lists what is waiting per crop and kind', () async {
      await outbox().enqueue(entry('a'));
      await outbox().enqueue(entry('b', kind: OutboxKind.harvest));
      await outbox().enqueue(entry('c', cropId: 8));

      expect(state().forCrop(7, OutboxKind.expense).map((e) => e.clientRef), ['a']);
    });

    test('sign-out empties it', () async {
      await outbox().enqueue(entry('a'));

      await outbox().clear();

      expect(state().pending, isEmpty);
      expect(container.read(sharedPreferencesProvider).getString('outbox'), isNull);
    });
  });

  test('connection status only changes on a real transition', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final changes = <bool>[];
    container.listen<bool>(connectionStatusProvider, (_, next) => changes.add(next));

    container.read(connectionStatusProvider.notifier)
      ..online()
      ..offline()
      ..offline()
      ..online();

    expect(changes, [false, true]);
  });
}
