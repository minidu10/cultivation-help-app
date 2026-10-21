import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/json/converters.dart';
import '../../../core/providers.dart';
import 'harvest_models.dart';

final harvestRepositoryProvider =
    Provider<HarvestRepository>((ref) => HarvestRepository(ref.watch(dioProvider)));

final harvestsProvider = FutureProvider.autoDispose.family<List<Harvest>, int>(
  (ref, cropId) => ref.watch(harvestRepositoryProvider).list(cropId),
);

class HarvestInput {
  const HarvestInput({
    this.harvestDate,
    this.quantity,
    this.unit,
    this.pricePerUnit,
    this.buyerName,
    this.notes,
  });

  final DateTime? harvestDate;
  final double? quantity;
  final QuantityUnit? unit;
  final double? pricePerUnit;
  final String? buyerName;
  final String? notes;

  Map<String, Object?> toJson() => compact({
        'harvestDate': harvestDate == null ? null : formatDateOnly(harvestDate!),
        'quantity': quantity,
        'unit': unit?.wire,
        'pricePerUnit': pricePerUnit,
        'buyerName': buyerName?.trim(),
        'notes': notes?.trim(),
      });
}

class HarvestRepository {
  HarvestRepository(this._dio);

  final Dio _dio;

  Future<List<Harvest>> list(int cropId) => guard(() async {
        final res = await _dio.get<List<dynamic>>('/crops/$cropId/harvests');
        return res.data!.map((e) => Harvest.fromJson(e as Map<String, dynamic>)).toList();
      });

  Future<Harvest> add(int cropId, HarvestInput input) => guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/crops/$cropId/harvests', data: input.toJson());
        return Harvest.fromJson(res.data!);
      });

  Future<Harvest> update(int cropId, int harvestId, HarvestInput input) => guard(() async {
        final res = await _dio.put<Map<String, dynamic>>(
          '/crops/$cropId/harvests/$harvestId',
          data: input.toJson(),
        );
        return Harvest.fromJson(res.data!);
      });

  Future<void> delete(int cropId, int harvestId) =>
      guard(() => _dio.delete<void>('/crops/$cropId/harvests/$harvestId'));
}
