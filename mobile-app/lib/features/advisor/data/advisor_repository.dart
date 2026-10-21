import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/providers.dart';
import '../../crops/data/crop_models.dart';

final advisorRepositoryProvider = Provider<AdvisorRepository>((ref) => AdvisorRepository(ref.watch(dioProvider)));

final advisorOnlineProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(advisorRepositoryProvider).isOnline(),
);

class AdvisorRepository {
  AdvisorRepository(this._dio);

  /// The server caps context at 2,000 characters; staying under it means
  /// nothing important is cut off mid-crop.
  static const _maxContext = 1900;

  final Dio _dio;

  Future<String> ask(String question, {List<Crop> crops = const []}) => guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/ai/ask', data: {
          'question': question.trim(),
          'cropContext': describeCrops(crops),
        });
        return res.data!['answer'] as String;
      });

  Future<bool> isOnline() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/ai/health');
      return res.data?['status'] == 'UP' && res.data?['configured'] == true;
    } on DioException {
      return false;
    }
  }

  /// One line per crop, so the advisor knows what is actually growing instead
  /// of the farmer typing it out each time. Active crops come first.
  static String describeCrops(List<Crop> crops) {
    final ordered = [...crops]..sort((a, b) => (b.status.isActive ? 1 : 0) - (a.status.isActive ? 1 : 0));
    final buffer = StringBuffer();
    for (final crop in ordered) {
      final parts = [
        crop.name,
        if (crop.variety?.isNotEmpty ?? false) 'variety ${crop.variety}',
        crop.status.wire.toLowerCase().replaceAll('_', ' '),
        'planted ${crop.plantingDate.toIso8601String().substring(0, 10)}',
        if (crop.fieldSizeAcres != null) '${crop.fieldSizeAcres} acres',
        if (crop.fieldLocation?.isNotEmpty ?? false) 'at ${crop.fieldLocation}',
      ];
      final line = '${parts.join(', ')}.\n';
      if (buffer.length + line.length > _maxContext) break;
      buffer.write(line);
    }
    return buffer.toString().trim();
  }
}
