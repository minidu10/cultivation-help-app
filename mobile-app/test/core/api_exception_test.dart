import 'package:agromaster/core/api/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _failure(int status, Object? data) {
  final request = RequestOptions(path: '/x');
  return DioException.badResponse(
    statusCode: status,
    requestOptions: request,
    response: Response<Object?>(requestOptions: request, statusCode: status, data: data),
  );
}

void main() {
  test('uses the server\'s message and field errors', () {
    final e = ApiException.from(_failure(400, {
      'message': 'Amount must be greater than zero',
      'fieldErrors': {'amount': 'Amount must be greater than zero'},
    }));

    expect(e.message, 'Amount must be greater than zero');
    expect(e.statusCode, 400);
    expect(e.fieldErrors, {'amount': 'Amount must be greater than zero'});
  });

  test('falls back to the status when the body is not the API\'s error shape', () {
    final e = ApiException.from(_failure(502, '<html>Bad Gateway</html>'));

    expect(e.message, 'Request failed (502).');
  });

  test('explains a missing connection in plain words', () {
    final e = ApiException.from(DioException.connectionError(requestOptions: RequestOptions(path: '/x'), reason: 'x'));

    expect(e.message, contains('internet connection'));
    expect(e.statusCode, isNull);
  });

  test('explains a timeout', () {
    final e = ApiException.from(DioException.receiveTimeout(
      timeout: const Duration(seconds: 1),
      requestOptions: RequestOptions(path: '/x'),
    ));

    expect(e.message, contains('too long'));
  });
}
