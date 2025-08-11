import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Auth UI
import '../../../../../lib/features/auth/ui/login_page.dart';
import '../../../../../lib/features/auth/ui/register_page.dart';

// Tasks UI
import '../../../../../lib/features/auth/widgets/auth_gate.dart';
import '../../../../../lib/features/tasks/ui/task_list_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ No se pudo cargar .env: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

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
