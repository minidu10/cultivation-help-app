// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  token: json['token'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 1800,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  city: json['city'] as String?,
  themePreference: json['themePreference'] as String? ?? 'LIGHT',
  desktopMode: json['desktopMode'] as bool? ?? false,
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'email': instance.email,
      'fullName': instance.fullName,
      'city': instance.city,
      'themePreference': instance.themePreference,
      'desktopMode': instance.desktopMode,
    };

_AuthConfig _$AuthConfigFromJson(Map<String, dynamic> json) => _AuthConfig(
  googleClientId: json['googleClientId'] as String?,
  googleEnabled: json['googleEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$AuthConfigToJson(_AuthConfig instance) =>
    <String, dynamic>{
      'googleClientId': instance.googleClientId,
      'googleEnabled': instance.googleEnabled,
    };
