// clase para la respuesta de autenticación
class AuthResponse {
  final String accessToken;
  AuthResponse({required this.accessToken});
  factory AuthResponse.fromJson(Map<String, dynamic> j) =>
      AuthResponse(accessToken: j['access_token'] ?? j['token'] ?? '');
}

// clase para el modelo de login
class LoginDto {
  final String email;
  final String password;
  LoginDto(this.email, this.password);
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

//clase para el modelo de register
class RegisterDto {
  final String email;
  final String password;
  final String? name;
  RegisterDto({required this.email, required this.password, this.name});
  Map<String, dynamic> toJson() =>
      {'email': email, 'password': password, if (name != null) 'name': name};
}

//clase para el modelo de usuario
class UserMe {
  final int id;
  final String email;
  final String? name;
  UserMe({required this.id, required this.email, this.name});

  factory UserMe.fromJson(Map<String, dynamic> j) =>
      UserMe(id: j['id'], email: j['email'], name: j['name']);
}
