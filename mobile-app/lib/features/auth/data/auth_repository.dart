import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/providers.dart';
import 'auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));

final authConfigProvider = FutureProvider<AuthConfig>(
  (ref) => ref.watch(authRepositoryProvider).config(),
);

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthConfig> config() => guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/auth/config');
        return AuthConfig.fromJson(res.data!);
      });

  Future<AuthSession> login(String email, String password) =>
      _session('/auth/login', {'email': email.trim(), 'password': password});

  Future<AuthSession> google(String idToken) => _session('/auth/google', {'credential': idToken});

  // Registration is three steps: prove the address with a code, then create
  // the account. The server re-checks the code, so the order cannot be skipped.
  Future<void> sendCode(String email) =>
      guard(() => _dio.post<void>('/auth/send-code', data: {'email': email.trim()}));

  Future<void> verifyCode(String email, String code) =>
      guard(() => _dio.post<void>('/auth/verify-code', data: {'email': email.trim(), 'code': code.trim()}));

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? city,
  }) =>
      _session('/auth/register', compact({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone?.trim(),
        'city': city?.trim(),
      }));

  Future<void> forgotPassword(String email) =>
      guard(() => _dio.post<void>('/auth/forgot-password', data: {'email': email.trim()}));

  Future<void> resetPassword({required String email, required String code, required String newPassword}) =>
      guard(() => _dio.post<void>('/auth/reset-password', data: {
            'email': email.trim(),
            'code': code.trim(),
            'newPassword': newPassword,
          }));

  Future<AuthSession> _session(String path, Map<String, Object?> body) => guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(path, data: body);
        return AuthSession.fromJson(res.data!);
      });
}
