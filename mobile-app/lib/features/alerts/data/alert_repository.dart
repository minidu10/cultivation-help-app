import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/providers.dart';
import 'alert_models.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) => AlertRepository(ref.watch(dioProvider)));

/// Fetched separately from the dashboard summary, so slow weather never
/// holds up the figures.
final weatherAlertsProvider = FutureProvider.autoDispose<List<WeatherAlert>>(
  (ref) => ref.watch(alertRepositoryProvider).alerts(),
);

class AlertRepository {
  AlertRepository(this._dio);

  final Dio _dio;

  Future<List<WeatherAlert>> alerts() => guard(() async {
        final res = await _dio.get<List<dynamic>>('/alerts');
        return res.data!.map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>)).toList();
      });
}
