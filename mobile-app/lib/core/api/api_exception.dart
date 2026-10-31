import 'package:dio/dio.dart';

/// A failed API call, reduced to what a screen can show.
///
/// The backend answers every error with `{status, message, fieldErrors?}`, so
/// the server's own wording is preferred; anything else (no connection, a
/// proxy's HTML page) falls back to a plain sentence.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.fieldErrors = const {}});

  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    if (error is! DioException) return const ApiException('Something went wrong. Please try again.');

    final response = error.response;
    if (response == null) {
      return ApiException(switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'The server took too long to answer. Check your connection and try again.',
        _ => 'Cannot reach AgroMaster. Check your internet connection.',
      });
    }

    final data = response.data;
    var message = 'Request failed (${response.statusCode}).';
    var fieldErrors = const <String, String>{};
    if (data is Map) {
      final serverMessage = data['message'];
      if (serverMessage is String && serverMessage.isNotEmpty) message = serverMessage;
      final fields = data['fieldErrors'];
      if (fields is Map) {
        fieldErrors = {for (final e in fields.entries) '${e.key}': '${e.value}'};
      }
    }
    return ApiException(message, statusCode: response.statusCode, fieldErrors: fieldErrors);
  }

  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}
