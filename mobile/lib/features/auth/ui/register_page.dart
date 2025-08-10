import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/ui/task_form_page.dart';
import '../state/auth_controller.dart';
import '../../../core/app_exception.dart';

/// Página de registro con el mismo estilo/animaciones del Login.
/// Al registrarse, guarda el token que devuelve el backend y navega a /tasks.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;

  // Animations (idénticas al Login)
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _buttonController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.elasticOut));
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onButtonTap() =>
      _buttonController.forward().then((_) => _buttonController.reverse());

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    HapticFeedback.lightImpact();

    final auth = ref.read(authControllerProvider.notifier);

    try {
      // 1) Registrar y guardar token
      await auth.registerAndLogin(
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
      );

      // 2) Asegurar que el estado de auth ya quedó resuelto (UserMe cargado)
      await ref.read(authControllerProvider.future);

      // 3) Navegar DIRECTO al formulario de creación de tarea
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormPage()),
          (route) => false, // limpia el stack (no vuelve a register/login)
        );
      }
    } catch (e) {
      final msg = (e is AppException) ? e.message : 'Error al registrar';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 24.0 : 48.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: isSmallScreen ? double.infinity : 420),
                      child: Card(
                        elevation: 20,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: _buildForm(isSmallScreen),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(isSmallScreen),
          SizedBox(height: isSmallScreen ? 32 : 40),
          _buildAnimatedField(delay: 600, child: _buildNameField()),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildAnimatedField(delay: 700, child: _buildEmailField()),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildAnimatedField(delay: 800, child: _buildPasswordField()),
          SizedBox(height: isSmallScreen ? 24 : 32),
          _buildAnimatedField(delay: 900, child: _buildRegisterButton()),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildAnimatedField(delay: 1000, child: _buildBackToLogin()),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(
          opacity: value,
          child: Column(
            children: [
              Icon(Icons.person_add_alt_1,
                  size: isSmallScreen ? 64 : 80,
                  color: const Color(0xFF667eea)),
              const SizedBox(height: 16),
              Text('Crear cuenta',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333))),
              const SizedBox(height: 8),
              Text('Regístrate para empezar',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, _) => Transform.translate(
        offset: Offset(0, 30 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _name,
      decoration: _inputDecoration(
          label: 'Nombre (opcional)', icon: Icons.badge_outlined),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(
          label: 'Correo electrónico', icon: Icons.email_outlined),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
        final re = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
        if (!re.hasMatch(v.trim())) return 'Correo no válido';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _password,
      obscureText: _obscure,
      decoration: _inputDecoration(
        label: 'Contraseña (mín. 6)',
        icon: Icons.lock_outlined,
        suffix: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                key: ValueKey(_obscure),
                color: const Color(0xFF667eea)),
          ),
          onPressed: () {
            setState(() => _obscure = !_obscure);
            HapticFeedback.selectionClick();
          },
        ),
      ),
      validator: (v) =>
          (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
      onFieldSubmitted: (_) => _submit(),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
      suffixIcon: suffix,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildRegisterButton() {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _submitting
              ? null
              : () {
                  _onButtonTap();
                  _submit();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Center(
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text('Crear cuenta',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: const Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 14, color: Colors.grey),
          children: [
            TextSpan(text: '¿Ya tienes cuenta? '),
            TextSpan(
                text: 'Inicia sesión',
                style: TextStyle(
                    color: Color(0xFF667eea), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
