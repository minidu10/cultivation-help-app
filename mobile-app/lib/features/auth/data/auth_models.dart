import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// What every sign-in endpoint returns: the token pair plus enough of the
/// profile to draw the first screen without another request.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String token,
    required String refreshToken,
    @Default(1800) int expiresIn,
    required String email,
    required String fullName,
    String? city,
    @Default('LIGHT') String themePreference,
    @Default(false) bool desktopMode,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) => _$AuthSessionFromJson(json);
}

/// Public sign-in options. The Google client id is served by the backend so
/// the app needs no build-time configuration for it.
@freezed
abstract class AuthConfig with _$AuthConfig {
  const factory AuthConfig({
    String? googleClientId,
    @Default(false) bool googleEnabled,
  }) = _AuthConfig;

  factory AuthConfig.fromJson(Map<String, dynamic> json) => _$AuthConfigFromJson(json);
}
