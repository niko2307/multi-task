import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/data/auth_models.dart';
import '../../../core/http.dart';
import '../../../core/token_storage.dart';

/// Provee una única instancia reutilizable de FlutterSecureStorage para almacenamiento seguro.
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Wrapper sobre FlutterSecureStorage para leer/guardar/borrar el JWT.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.read(flutterSecureStorageProvider));
});

/// Dio configurado con baseUrl + interceptor JWT (Http.build).
final dioProvider = Provider<Dio>((ref) {
  final secure = ref.read(flutterSecureStorageProvider);
  return Http.build(secure);
});

/// Repositorio de autenticación (/auth/* y /users/me).
final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(tokenStorageProvider));
});

/// Controlador de autenticación: mantiene en estado el usuario autenticado (UserMe?).
class AuthController extends AsyncNotifier<UserMe?> {
  AuthRepository get _repo => ref.read(authRepoProvider);

  /// Al iniciar, si hay token intenta cargar /users/me. Si falla, cierra sesión.
  @override
  Future<UserMe?> build() async {
    try {
      final hasToken = await ref.read(tokenStorageProvider).read() != null;
      if (!hasToken) return null;
      final user = await _repo.me();
      return user;
    } catch (_) {
      await _repo.logout();
      return null;
    }
  }

  /// Login + carga del perfil.
  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.login(LoginDto(email, password));
      final me = await _repo.me();
      return me;
    });
  }

  /// Registro que guarda token y luego carga el perfil.
  Future<void> registerAndLogin({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.registerAndStore(
        RegisterDto(email: email, password: password, name: name),
      );
      final me = await _repo.me();
      return me;
    });
  }

  /// Refresca /users/me.
  Future<void> refreshMe() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _repo.me());
  }

  /// Cierra sesión y limpia estado.
  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }
}

/// Provider público del controlador.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserMe?>(AuthController.new);

/// ¿Hay usuario autenticado?
final isAuthenticatedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider);
  return auth.maybeWhen(data: (u) => u != null, orElse: () => false);
});
