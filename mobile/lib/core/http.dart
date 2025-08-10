import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_storage.dart';

class Http {
  static Dio build(FlutterSecureStorage secure) {
    final base =
        (dotenv.env['API_BASE_URL'] ?? '').trim().replaceAll(RegExp(r'/$'), '');
    final prefix = (dotenv.env['API_PREFIX'] ?? '').trim();
    final normalizedPrefix =
        prefix.isEmpty ? '' : (prefix.startsWith('/') ? prefix : '/$prefix');
    final baseUrl =
        '$base$normalizedPrefix/'; // https://multi-task.onrender.com/api

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    final storage = TokenStorage(secure);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    // Log para ver URL final y payload
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    // (Opcional) imprime el baseUrl al inicio
    // // ignore: avoid_print
    print('🌐 DIO BASE URL => $baseUrl');

    return dio;
  }
}
