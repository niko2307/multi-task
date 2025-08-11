import 'package:dio/dio.dart';
import '../../../core/token_storage.dart';
import '../../../core/dio_error_mapper.dart';
import '../../../core/app_exception.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository(this.dio, this.storage);
  final Dio dio;
  final TokenStorage storage;

  /// POST /auth/login
  Future<void> login(LoginDto dto) async {
    try {
      final r = await dio.post('/auth/login', data: dto.toJson());
      final token = _parseToken(r.data);
      if (token.isEmpty) {
        throw AppException('Token no recibido desde el backend',
            status: r.statusCode);
      }
      await storage.save(token);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /auth/register  (devuelve y guarda token)
  Future<void> registerAndStore(RegisterDto dto) async {
    try {
      final r = await dio.post('/auth/register', data: dto.toJson());
      final token = _parseToken(r.data);
      if (token.isEmpty) {
        throw AppException('No se recibió token en el registro',
            status: r.statusCode);
      }
      await storage.save(token);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /users/me (protegido)
  Future<UserMe> me() async {
    try {
      final r = await dio.get('/users/me');
      return UserMe.fromJson(r.data as Map<String, dynamic>);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logout() => storage.clear();
  Future<bool> isLogged() async => (await storage.read()) != null;

  // --- helpers ---
  String _parseToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      // tu backend (por logs) entrega: { "access_token": "..." }
      return (data['access_token'] ?? data['accessToken'] ?? '').toString();
    }
    try {
      return AuthResponse.fromJson(data).accessToken;
    } catch (_) {
      return '';
    }
  }
}
