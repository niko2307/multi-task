// lib/features/auth/ui/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_controller.dart';

/// AuthGate
/// Envuelve una pantalla protegida. Si no hay sesión, navega a '/' (login).
class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    required this.child,
    this.loginRoute = '/',
    this.showScaffoldWhileLoading = true,
  });

  /// Widget protegido (por ejemplo, TaskListPage).
  final Widget child;

  /// Ruta a la que redirige si no hay sesión (login por defecto).
  final String loginRoute;

  /// Muestra un Scaffold con loader mientras resuelve el estado inicial.
  final bool showScaffoldWhileLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return auth.when(
      // Hay sesión => renderiza el hijo
      data: (user) {
        if (user != null) return child;

        // No hay sesión => redirige a login fuera del frame actual
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.settings.name != loginRoute) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (_) => false);
          }
        });

        return showScaffoldWhileLoading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : const SizedBox.shrink();
      },

      // Cargando (por ejemplo, validando /users/me al inicio)
      loading: () => showScaffoldWhileLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const SizedBox.shrink(),

      // Error al resolver estado: ofrece reintentar o ir a login
      error: (e, _) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text('Error: $e', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () => ref
                            .read(authControllerProvider.notifier)
                            .refreshMe(),
                        child: const Text('Reintentar'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (_) => false);
                        },
                        child: const Text('Ir a login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
