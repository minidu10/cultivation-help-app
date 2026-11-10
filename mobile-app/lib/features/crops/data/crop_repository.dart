import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/json/converters.dart';
import '../../../core/providers.dart';
import '../../dashboard/data/dashboard_repository.dart';
import 'crop_models.dart';

final cropRepositoryProvider = Provider<CropRepository>((ref) => CropRepository(ref.watch(dioProvider)));

final cropsProvider = FutureProvider.autoDispose<List<Crop>>(
  (ref) => ref.watch(cropRepositoryProvider).list(),
);

final cropProvider = FutureProvider.autoDispose.family<Crop, int>(
  (ref, id) => ref.watch(cropRepositoryProvider).get(id),
);

final profitLossProvider = FutureProvider.autoDispose.family<ProfitLoss, int>(
  (ref, id) => ref.watch(cropRepositoryProvider).profitLoss(id),
);

final cropInsightProvider = FutureProvider.autoDispose.family<CropInsight, int>(
  (ref, id) => ref.watch(cropRepositoryProvider).insight(id),
);

/// After anything that moves a crop's figures, everything derived from them
/// is stale: its own totals, its insight, the crop list and the dashboard.
void invalidateCropFigures(WidgetRef ref, int cropId) {
  ref
    ..invalidate(profitLossProvider(cropId))
    ..invalidate(cropInsightProvider(cropId))
    ..invalidate(cropProvider(cropId))
    ..invalidate(cropsProvider)
    ..invalidate(dashboardProvider);
}

/// The editable fields of a crop. Null means "leave unchanged" on update.
class CropInput {
  const CropInput({
    this.name,
    this.variety,
    this.fieldLocation,
    this.fieldSizeAcres,
    this.plantingDate,
    this.expectedHarvestDate,
    this.status,
    this.aiInsightsEnabled,
    this.notes,
  });

  final String? name;
  final String? variety;
  final String? fieldLocation;
  final double? fieldSizeAcres;
  final DateTime? plantingDate;
  final DateTime? expectedHarvestDate;
  final CropStatus? status;
  final bool? aiInsightsEnabled;
  final String? notes;

  Map<String, Object?> toJson() => compact({
        'name': name?.trim(),
        'variety': variety?.trim(),
        'fieldLocation': fieldLocation?.trim(),
        'fieldSizeAcres': fieldSizeAcres,
        'plantingDate': plantingDate == null ? null : formatDateOnly(plantingDate!),
        'expectedHarvestDate': expectedHarvestDate == null ? null : formatDateOnly(expectedHarvestDate!),
        'status': status?.wire,
        'aiInsightsEnabled': aiInsightsEnabled,
        'notes': notes?.trim(),
      });
}

class CropRepository {
  CropRepository(this._dio);

  final Dio _dio;

  Future<List<Crop>> list() => guard(() async {
        final res = await _dio.get<List<dynamic>>('/crops');
        return res.data!.map((e) => Crop.fromJson(e as Map<String, dynamic>)).toList();
      });

  Future<Crop> get(int id) => guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/crops/$id');
        return Crop.fromJson(res.data!);
      });

  Future<Crop> create(CropInput input) => guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/crops', data: input.toJson());
        return Crop.fromJson(res.data!);
      });

  Future<Crop> update(int id, CropInput input) => guard(() async {
        final res = await _dio.put<Map<String, dynamic>>('/crops/$id', data: input.toJson());
        return Crop.fromJson(res.data!);
      });

  Future<void> delete(int id) => guard(() => _dio.delete<void>('/crops/$id'));

  Future<ProfitLoss> profitLoss(int id) => guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/crops/$id/expenses/profit-loss');
        return ProfitLoss.fromJson(res.data!);
      });

  /// Served from the server's cache unless [refresh] or the figures changed.
  Future<CropInsight> insight(int id, {bool refresh = false}) => guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/crops/$id/insights',
          queryParameters: refresh ? {'refresh': true} : null,
        );
        return CropInsight.fromJson(res.data!);
      });
}
