import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage(this._s);
  final FlutterSecureStorage _s;

  Future<void> save(String token) => _s.write(key: 'token', value: token);
  Future<String?> read() => _s.read(key: 'token');
  Future<void> clear() => _s.delete(key: 'token');
}
