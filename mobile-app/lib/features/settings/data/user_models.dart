import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_models.freezed.dart';
part 'user_models.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int id,
    required String fullName,
    required String email,
    String? phone,
    String? city,
    @Default('LIGHT') String themePreference,
    @Default(false) bool desktopMode,
    @Default(true) bool reminderEmailsEnabled,
    @Default('LOCAL') String authProvider,
    @Default(true) bool hasPassword,
    @Default(false) bool googleLinked,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
