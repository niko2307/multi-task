import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Auth
import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/register_page.dart';

// Tasks
import 'features/auth/widgets/auth_gate.dart';

import 'features/tasks/ui/task_list_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar .env (opcional)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Barra de estado
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multitask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF667eea),
        brightness: Brightness.light,
      ),
      // 👇 rutas reales de tu app
      routes: {
        '/': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/tasks': (_) => const AuthGate(child: TaskListPage()),
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
