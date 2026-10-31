import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/providers.dart';
import 'dashboard_models.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) => DashboardRepository(ref.watch(dioProvider)));

final dashboardProvider = FutureProvider.autoDispose<DashboardSummary>(
  (ref) => ref.watch(dashboardRepositoryProvider).summary(),
);

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardSummary> summary() => guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/dashboard/summary');
        return DashboardSummary.fromJson(res.data!);
      });
}
