import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/providers.dart';
import '../../auth/data/auth_models.dart';
import 'user_models.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository(ref.watch(dioProvider)));

final userProfileProvider = FutureProvider.autoDispose<UserProfile>(
  (ref) => ref.watch(userRepositoryProvider).me(),
);

class UserRepository {
  UserRepository(this._dio);

  final Dio _dio;

  Future<UserProfile> me() => guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/users/me');
        return UserProfile.fromJson(res.data!);
      });

  /// Partial: only the fields passed are changed.
  Future<UserProfile> update({
    String? fullName,
    String? phone,
    String? city,
    String? themePreference,
    bool? desktopMode,
    bool? reminderEmailsEnabled,
  }) =>
      guard(() async {
        final res = await _dio.put<Map<String, dynamic>>('/users/me', data: compact({
          'fullName': fullName,
          'phone': phone,
          'city': city,
          'themePreference': themePreference,
          'desktopMode': desktopMode,
          'reminderEmailsEnabled': reminderEmailsEnabled,
        }));
        return UserProfile.fromJson(res.data!);
      });

  /// Signs every other device out; returns a fresh pair for this one.
  Future<AuthSession> changePassword({required String currentPassword, required String newPassword}) =>
      guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/users/me/password', data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        });
        return AuthSession.fromJson(res.data!);
      });

  Future<void> deleteAccount({String? password, String? googleCredential}) => guard(
        () => _dio.delete<void>('/users/me', data: compact({
          'password': password,
          'googleCredential': googleCredential,
        })),
      );
}
