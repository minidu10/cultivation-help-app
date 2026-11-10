import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase settings, passed at build time so no google-services.json (and
/// nothing project-specific) is committed:
///
///   flutter build apk --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=...
///     --dart-define=FIREBASE_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
///
/// Without them the app builds and runs normally, with push switched off.
abstract final class PushConfig {
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static bool get enabled => apiKey.isNotEmpty && appId.isNotEmpty && senderId.isNotEmpty && projectId.isNotEmpty;

  static FirebaseOptions get options =>
      const FirebaseOptions(apiKey: apiKey, appId: appId, messagingSenderId: senderId, projectId: projectId);
}

/// What tapping a notification asks the app to open.
@immutable
class PushTap {
  const PushTap({this.cropId});

  final int? cropId;

  static PushTap fromData(Map<String, dynamic> data) => PushTap(cropId: int.tryParse('${data['cropId'] ?? ''}'));
}

/// The phone's side of push, behind an interface so tests need no Firebase.
abstract interface class PushMessaging {
  bool get enabled;

  /// Asks permission where the OS requires it; false if the farmer declined.
  Future<bool> requestPermission();
  Future<String?> token();
  Stream<String> get tokenRefreshes;
  Stream<PushTap> get taps;

  /// The notification that launched the app from closed, if any.
  Future<PushTap?> launchTap();

  String get platform;
}

final pushMessagingProvider = Provider<PushMessaging>(
  (ref) => PushConfig.enabled ? FirebasePushMessaging() : const DisabledPushMessaging(),
);

class DisabledPushMessaging implements PushMessaging {
  const DisabledPushMessaging();

  @override
  bool get enabled => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Stream<PushTap> get taps => const Stream.empty();

  @override
  Future<PushTap?> launchTap() async => null;

  @override
  String get platform => 'android';
}

class FirebasePushMessaging implements PushMessaging {
  static const _channel = AndroidNotificationChannel(
    // Matches the channel_id the backend sets on every push.
    'reminders',
    'Farm reminders',
    description: 'Upcoming field tasks and weather warnings',
    importance: Importance.high,
  );

  final _local = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<PushTap>.broadcast();
  bool _ready = false;

  /// Called once from main(), before the first frame.
  static Future<void> initializeFirebase() async {
    if (!PushConfig.enabled) return;
    try {
      await Firebase.initializeApp(options: PushConfig.options);
    } on Exception catch (e) {
      debugPrint('Firebase did not start, push is off: $e');
    }
  }

  @override
  bool get enabled => Firebase.apps.isNotEmpty;

  @override
  String get platform => Platform.isIOS ? 'ios' : 'android';

  Future<void> _setUp() async {
    if (_ready || !enabled) return;
    _ready = true;
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final cropId = int.tryParse(response.payload ?? '');
        _taps.add(PushTap(cropId: cropId));
      },
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Android shows nothing for a push that arrives while the app is open,
    // so the app shows it itself.
    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n == null) return;
      _local.show(
        id: message.hashCode,
        title: n.title,
        body: n.body,
        payload: '${message.data['cropId'] ?? ''}',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(_channel.id, _channel.name, importance: Importance.high),
        ),
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _taps.add(PushTap.fromData(m.data)));
  }

  @override
  Future<bool> requestPermission() async {
    if (!enabled) return false;
    await _setUp();
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // getToken and onTokenRefresh are deprecated in favour of register() and
  // onRegistered, which yield a Firebase Installation ID. The backend sends
  // through the FCM HTTP v1 API, whose message.token is documented as the
  // registration token these return, so they stay until the server side
  // moves to installation IDs too.

  @override
  // ignore: deprecated_member_use
  Future<String?> token() async => enabled ? FirebaseMessaging.instance.getToken() : null;

  @override
  Stream<String> get tokenRefreshes =>
      // ignore: deprecated_member_use
      enabled ? FirebaseMessaging.instance.onTokenRefresh : const Stream.empty();

  @override
  Stream<PushTap> get taps => _taps.stream;

  @override
  Future<PushTap?> launchTap() async {
    if (!enabled) return null;
    await _setUp();
    final message = await FirebaseMessaging.instance.getInitialMessage();
    return message == null ? null : PushTap.fromData(message.data);
  }
}
