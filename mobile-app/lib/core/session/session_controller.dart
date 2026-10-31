import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_models.dart';
import '../offline/outbox.dart';
import '../providers.dart';
import '../push/push_registrar.dart';

/// Who is signed in, as far as drawing screens is concerned.
///
/// Cached in SharedPreferences (it holds nothing secret) so the app opens
/// straight onto the dashboard instead of waiting on a profile request.
@immutable
class SessionUser {
  const SessionUser({
    required this.fullName,
    required this.email,
    this.city,
    this.themePreference = 'LIGHT',
    this.desktopMode = false,
  });

  factory SessionUser.fromJson(Map<String, dynamic> json) => SessionUser(
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        city: json['city'] as String?,
        themePreference: json['themePreference'] as String? ?? 'LIGHT',
        desktopMode: json['desktopMode'] as bool? ?? false,
      );

  final String fullName;
  final String email;
  final String? city;
  final String themePreference;

  /// "Follow the device" for the theme. The name is the server's.
  final bool desktopMode;

  ThemeMode get themeMode => desktopMode
      ? ThemeMode.system
      : themePreference.toUpperCase() == 'DARK'
          ? ThemeMode.dark
          : ThemeMode.light;

  SessionUser copyWith({String? fullName, String? city, String? themePreference, bool? desktopMode}) =>
      SessionUser(
        fullName: fullName ?? this.fullName,
        email: email,
        city: city ?? this.city,
        themePreference: themePreference ?? this.themePreference,
        desktopMode: desktopMode ?? this.desktopMode,
      );

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'city': city,
        'themePreference': themePreference,
        'desktopMode': desktopMode,
      };
}

@immutable
class SessionState {
  const SessionState.signedIn(SessionUser this.user) : expired = false;
  const SessionState.signedOut({this.expired = false}) : user = null;

  final SessionUser? user;

  /// True when the server refused to renew the session, so the sign-in
  /// screen can say why the user ended up there.
  final bool expired;

  bool get isSignedIn => user != null;
}

/// Whether tokens were found on disk at start-up; read in main() because
/// secure storage is asynchronous and the first frame should not wait.
final hasStoredSessionProvider = Provider<bool>((ref) => false);

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  static const _userKey = 'session_user';

  @override
  SessionState build() {
    final cached = ref.read(sharedPreferencesProvider).getString(_userKey);
    if (ref.read(hasStoredSessionProvider) && cached != null) {
      return SessionState.signedIn(SessionUser.fromJson(jsonDecode(cached) as Map<String, dynamic>));
    }
    return const SessionState.signedOut();
  }

  Future<void> signIn(AuthSession session) async {
    await ref.read(tokenStoreProvider).save(accessToken: session.token, refreshToken: session.refreshToken);
    final user = SessionUser(
      fullName: session.fullName,
      email: session.email,
      city: session.city,
      themePreference: session.themePreference,
      desktopMode: session.desktopMode,
    );
    await _cache(user);
    state = SessionState.signedIn(user);
  }

  /// Revokes the refresh token server-side, then forgets everything locally.
  /// The network call is best effort: signing out must work offline.
  Future<void> signOut() async {
    // First, while the session still works: this phone stops getting this
    // farmer's notifications.
    await ref.read(pushRegistrarProvider).unregister();
    final tokens = ref.read(tokenStoreProvider);
    final refreshToken = await tokens.readRefreshToken();
    if (refreshToken != null) {
      unawaited(ref
          .read(plainDioProvider)
          .post<void>('/auth/logout', data: {'refreshToken': refreshToken})
          .then((_) {}, onError: (Object _) {}));
    }
    await tokens.clear();
    await ref.read(sharedPreferencesProvider).remove(_userKey);
    // Saved data and unsent records belong to the person signing out.
    await ref.read(responseCacheProvider).clear();
    await ref.read(outboxProvider.notifier).clear();
    state = const SessionState.signedOut();
  }

  /// Called by the API client once the refresh token has been refused.
  void expire() {
    unawaited(ref.read(sharedPreferencesProvider).remove(_userKey));
    unawaited(ref.read(responseCacheProvider).clear());
    state = const SessionState.signedOut(expired: true);
  }

  /// After the profile or a setting changes on the server.
  Future<void> updateUser(SessionUser Function(SessionUser current) change) async {
    final current = state.user;
    if (current == null) return;
    final next = change(current);
    await _cache(next);
    state = SessionState.signedIn(next);
  }

  Future<void> _cache(SessionUser user) =>
      ref.read(sharedPreferencesProvider).setString(_userKey, jsonEncode(user.toJson()));
}
