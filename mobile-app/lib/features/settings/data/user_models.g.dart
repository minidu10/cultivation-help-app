// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  city: json['city'] as String?,
  themePreference: json['themePreference'] as String? ?? 'LIGHT',
  desktopMode: json['desktopMode'] as bool? ?? false,
  reminderEmailsEnabled: json['reminderEmailsEnabled'] as bool? ?? true,
  authProvider: json['authProvider'] as String? ?? 'LOCAL',
  hasPassword: json['hasPassword'] as bool? ?? true,
  googleLinked: json['googleLinked'] as bool? ?? false,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'city': instance.city,
      'themePreference': instance.themePreference,
      'desktopMode': instance.desktopMode,
      'reminderEmailsEnabled': instance.reminderEmailsEnabled,
      'authProvider': instance.authProvider,
      'hasPassword': instance.hasPassword,
      'googleLinked': instance.googleLinked,
    };
