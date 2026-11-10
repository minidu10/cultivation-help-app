import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Runs an API call and turns any failure into an [ApiException], so screens
/// only ever deal with one error type carrying a displayable message.
Future<T> guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw ApiException.from(e);
  }
}

/// Drops nulls so a partial update leaves untouched fields alone server-side.
Map<String, Object?> compact(Map<String, Object?> body) =>
    {for (final e in body.entries) if (e.value != null) e.key: e.value};
