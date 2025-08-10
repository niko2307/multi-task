import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // Variables for API configuration  para las direcciones predeterminadas , del backend
  static String get baseUrl =>
      dotenv.env['API_BASE_URL']!.replaceAll(RegExp(r'/$'), '');
  static String get prefix =>
      (dotenv.env['API_PREFIX'] ?? '').replaceAll(RegExp(r'/$'), '');
  //division de los path por caracter de / para hacer la union en los path y realizar el consumo de forma adecuada
  static String url(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    final px = prefix.isEmpty ? '' : prefix;
    return '$baseUrl$px$p';
  }
}
