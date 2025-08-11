import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task_model.dart';
import '../state/task_providers.dart';

/// Página de formulario para Crear / Editar tarea.
/// - Si [initial] es null => Crear
/// - Si [initial] viene con datos => Editar
class TaskFormPage extends ConsumerStatefulWidget {
  const TaskFormPage({super.key, this.initial});

  final Task? initial;

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.initial?.title ?? '');
  late final TextEditingController _desc =
      TextEditingController(text: widget.initial?.description ?? '');

  late TaskStatus _status = widget.initial?.status ?? TaskStatus.PENDING;
  late bool _done = widget.initial?.done ?? false;

  bool _submitting = false;

  // Animaciones
  late final AnimationController _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _slideCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  late final AnimationController _btnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 140));

  late final Animation<double> _fadeIn =
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
  late final Animation<Offset> _slideUp = Tween<Offset>(
    begin: const Offset(0, .08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));
  late final Animation<double> _btnScale = Tween<double>(begin: 1, end: .96)
      .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120), () {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _btnCtrl.dispose();
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    HapticFeedback.lightImpact();

    final ctrl = ref.read(tasksControllerProvider.notifier);
    try {
      if (widget.initial == null) {
        // CREAR
        await ctrl.create(
          title: _title.text.trim(),
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
          status: _status,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea creada')),
          );
          // Ir a la lista
          Navigator.pushReplacementNamed(context, '/tasks');
        }
      } else {
        // EDITAR
        await ctrl.updateTask(
          widget.initial!.copyWith(
            title: _title.text.trim(),
            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            status: _status,
            done: _done,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cambios guardados')),
          );
          // Ir a la lista
          Navigator.pushReplacementNamed(context, '/tasks');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _tapFx() => _btnCtrl.forward().then((_) => _btnCtrl.reverse());

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final titleText = isEdit ? 'Editar tarea' : 'Nueva tarea';

    return WillPopScope(
      // Back del sistema → ir a la lista
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/tasks');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(titleText),
          centerTitle: true,
          leading: IconButton(
            // Botón volver → ir a la lista
            icon: const Icon(Icons.arrow_back),
            onPressed: _submitting
                ? null
                : () => Navigator.pushReplacementNamed(context, '/tasks'),
          ),
          actions: [
            if (isEdit)
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline),
                onPressed: _submitting
                    ? null
                    : () async {
                        final ok = await _confirmDelete(context);
                        if (ok != true) return;
                        setState(() => _submitting = true);
                        try {
                          await ref
                              .read(tasksControllerProvider.notifier)
                              .delete(widget.initial!.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tarea eliminada')),
                            );
                            // Ir a la lista
                            Navigator.pushReplacementNamed(context, '/tasks');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _submitting = false);
                        }
                      },
              ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _CardGlass(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Icon + título bonito
                              _HeaderIcon(isEdit: isEdit),
                              const SizedBox(height: 16),

                              // Campo título
                              _AnimatedField(
                                delayMs: 80,
                                child: TextFormField(
                                  controller: _title,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(
                                    label: 'Título',
                                    icon: Icons.title_outlined,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Escribe un título'
                                          : null,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Campo descripción
                              _AnimatedField(
                                delayMs: 140,
                                child: TextFormField(
                                  controller: _desc,
                                  maxLines: 4,
                                  decoration: _inputDecoration(
                                    label: 'Descripción (opcional)',
                                    icon: Icons.description_outlined,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Estado (chips animadas)
                              _AnimatedField(
                                delayMs: 200,
                                child: _StatusChips(
                                  value: _status,
                                  onChanged: (s) => setState(() => _status = s),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Toggle done (solo en edición)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: isEdit
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle_outline,
                                              color: Color(0xFF667eea),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('Completada'),
                                            const Spacer(),
                                            Switch.adaptive(
                                              value: _done,
                                              onChanged: _submitting
                                                  ? null
                                                  : (v) =>
                                                      setState(() => _done = v),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 24),

                              // Botón guardar con gradient + scale
                              ScaleTransition(
                                scale: _btnScale,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _submitting
                                        ? null
                                        : () {
                                            _tapFx();
                                            _submit();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF667eea),
                                            Color(0xFF764ba2)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF667eea)
                                                .withOpacity(0.25),
                                            blurRadius: 10,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: _submitting
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.save_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    isEdit
                                                        ? 'Guardar cambios'
                                                        : 'Crear tarea',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Cancelar → ir a la lista
                              TextButton.icon(
                                onPressed: _submitting
                                    ? null
                                    : () => Navigator.pushReplacementNamed(
                                          context,
                                          '/tasks',
                                        ),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Volver'),
                              ),
                            ],
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
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('Esta acción no se puede deshacer.'),
        icon: const Icon(Icons.warning_amber_outlined),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Cabecera con icono animado (Hero para transiciones entre pantallas)
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.isEdit});
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'task-form-hero',
      child: CircleAvatar(
        radius: 32,
        backgroundColor: const Color(0xFF667eea).withOpacity(.12),
        child: Icon(
          isEdit ? Icons.edit_note_outlined : Icons.add_task_outlined,
          color: const Color(0xFF667eea),
          size: 36,
        ),
      ),
    );
  }
}

/// Contenedor tipo “glass card”
class _CardGlass extends StatelessWidget {
  const _CardGlass({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

/// Campo animado (fade + slide) reutilizable
class _AnimatedField extends StatelessWidget {
  const _AnimatedField({required this.child, required this.delayMs});
  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 450 + delayMs),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Transform.translate(
        offset: Offset(0, 20 * (1 - v)),
        child: Opacity(opacity: v, child: child),
      ),
    );
  }
}

/// Chips para seleccionar el estado de la tarea con animaciones sutiles.
class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.value, required this.onChanged});
  final TaskStatus value;
  final ValueChanged<TaskStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = const [
      (TaskStatus.PENDING, 'Pendiente', Icons.hourglass_bottom),
      (TaskStatus.IN_PROGRESS, 'En progreso', Icons.run_circle_outlined),
      (TaskStatus.DONE, 'Hecha', Icons.check_circle_outline),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final (status, label, icon) in options)
          _ChipOption(
            label: label,
            icon: icon,
            selected: value == status,
            onTap: () => onChanged(status),
          ),
      ],
    );
  }
}

class _ChipOption extends StatelessWidget {
  const _ChipOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: selected ? 1.02 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  )
                : null,
            color: selected ? null : Colors.grey.shade100,
            border: Border.all(
              color: selected ? Colors.transparent : Colors.grey.shade300,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : const Color(0xFF667eea)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
