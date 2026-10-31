import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/providers.dart';
import 'diagnosis_models.dart';

final diagnosisRepositoryProvider =
    Provider<DiagnosisRepository>((ref) => DiagnosisRepository(ref.watch(dioProvider)));

final diagnosesProvider = FutureProvider.autoDispose.family<List<Diagnosis>, int>(
  (ref, cropId) => ref.watch(diagnosisRepositoryProvider).history(cropId),
);

/// Thumbnails need the session's token, so they are fetched as bytes rather
/// than handed to Image.network. Kept for the session: they never change.
final thumbnailProvider = FutureProvider.family<Uint8List, String>(
  (ref, url) => ref.watch(diagnosisRepositoryProvider).thumbnail(url),
);

class DiagnosisRepository {
  DiagnosisRepository(this._dio);

  /// A vision model can take most of a minute; the default would give up first.
  static const _diagnoseTimeout = Duration(seconds: 100);

  final Dio _dio;

  Future<List<Diagnosis>> history(int cropId) => guard(() async {
        final res = await _dio.get<List<dynamic>>('/crops/$cropId/diagnoses');
        return res.data!.map((e) => Diagnosis.fromJson(e as Map<String, dynamic>)).toList();
      });

  Future<Diagnosis> diagnose(int cropId, Uint8List jpeg, {String? note}) => guard(() async {
        final form = FormData.fromMap({
          'image': MultipartFile.fromBytes(jpeg, filename: 'photo.jpg', contentType: DioMediaType('image', 'jpeg')),
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        });
        final res = await _dio.post<Map<String, dynamic>>(
          '/crops/$cropId/diagnoses',
          data: form,
          options: Options(receiveTimeout: _diagnoseTimeout, sendTimeout: _diagnoseTimeout),
        );
        return Diagnosis.fromJson(res.data!);
      });

  Future<void> delete(int cropId, int diagnosisId) =>
      guard(() => _dio.delete<void>('/crops/$cropId/diagnoses/$diagnosisId'));

  /// [url] is the server's "/api/crops/…/thumbnail"; the client's base already ends in /api.
  Future<Uint8List> thumbnail(String url) => guard(() async {
        final res = await _dio.get<List<int>>(
          url.replaceFirst(RegExp('^/api'), ''),
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data!);
      });
}
