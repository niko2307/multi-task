import 'package:dio/dio.dart';
import 'app_exception.dart';

AppException mapDioError(Object e) {
  if (e is DioException) {
    final code = e.response?.statusCode;
    final msg = e.response?.data is Map
        ? (e.response?.data['message']?.toString() ?? e.message)
        : e.message;
    return AppException(msg ?? 'Network error', status: code);
  }
  return AppException(e.toString());
}
