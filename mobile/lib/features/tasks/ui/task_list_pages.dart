import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task_model.dart';
import '../state/task_providers.dart';
import '../../auth/state/auth_controller.dart';
import 'task_form_page.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    // Gradiente “vivo” (lento y sutil)
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  // Ruta con transición slide + fade para el form
  PageRoute _formRoute({Task? initial}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => TaskFormPage(initial: initial),
      transitionsBuilder: (_, anim, __, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksControllerProvider);
    final mutating = ref.watch(taskMutatingProvider);
    final filter = ref.watch(taskDoneFilterProvider);

    // Auto-redirect si no hay tareas (tras cargar)
    tasks.whenData((list) {
      if (list.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if ((ModalRoute.of(context)?.isCurrent ?? false) && mounted) {
            Navigator.pushReplacement(context, _formRoute());
          }
        });
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mis tareas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _FilterChip(
            current: filter,
            onChanged: (v) =>
                ref.read(tasksControllerProvider.notifier).setFilter(v),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (_) => false);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo con gradiente animado (donde “mueve” el centro)
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, _) {
              final a = _bgAnim.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.8 + a * 0.6, -1.0),
                    end: Alignment(1.0, 0.8 - a * 0.6),
                    colors: const [
                      Color(0xFF667eea), // indigo-ish
                      Color(0xFF764ba2), // purple-ish
                    ],
                  ),
                ),
              );
            },
          ),
          // Capa de “vidrio” para el contenido
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
            ),
          ),

          // CONTENIDO
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 8),
            child: tasks.when(
              data: (list) => RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.white10,
                onRefresh: () =>
                    ref.read(tasksControllerProvider.notifier).refresh(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 140),
                            _EmptyState(),
                            SizedBox(height: 240),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _StaggeredItem(
                            index: i,
                            child: _TaskCard(
                              key: ValueKey(list[i].id),
                              task: list[i],
                            ),
                          ),
                        ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        'Error: $e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref
                            .read(tasksControllerProvider.notifier)
                            .refresh(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (mutating) const _TopLinearActivity(),
        ],
      ),
      floatingActionButton: _FabAnimated(
        onPressed: () async {
          await Navigator.push(context, _formRoute());
        },
      ),
    );
  }
}

/// ====== ITEM CON ENTRADA “STAGGERED” ======
class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // delay por índice (máx 10 items “progresivos”)
    final delay = (index.clamp(0, 10)) * 40;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (_, v, __) => Transform.translate(
        offset: Offset(0, 16 * (1 - v)),
        child: Opacity(opacity: v, child: child),
      ),
    );
  }
}

/// ====== FAB con animación sutil ======
class _FabAnimated extends StatefulWidget {
  const _FabAnimated({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_FabAnimated> createState() => _FabAnimatedState();
}

class _FabAnimatedState extends State<_FabAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 160));
  late final Animation<double> _scale = Tween<double>(begin: 1, end: .94)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton.extended(
        heroTag: 'task-form-hero',
        onPressed: () async {
          await _ctrl.forward();
          await _ctrl.reverse();
          widget.onPressed();
        },
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Nueva'),
      ),
    );
  }
}

/// ====== CARD ======
class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task, super.key});
  final Task task;

  Color _statusColor(BuildContext c) {
    return switch (task.status) {
      TaskStatus.PENDING => Colors.orange,
      TaskStatus.IN_PROGRESS => Theme.of(c).colorScheme.primary,
      TaskStatus.DONE => Colors.green,
    };
  }

  String _statusLabel() {
    return switch (task.status) {
      TaskStatus.PENDING => 'Pendiente',
      TaskStatus.IN_PROGRESS => 'En progreso',
      TaskStatus.DONE => 'Hecha',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade700],
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            SizedBox(width: 6),
            Text('Eliminar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) async {
        await ref.read(tasksControllerProvider.notifier).delete(task.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea eliminada')),
          );
        }
      },
      child: Card(
        elevation: 12,
        shadowColor: Colors.black.withOpacity(.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showActions(context, ref, task),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white.withOpacity(.98),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox + estado (con animaciones implícitas)
                Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Checkbox(
                        key: ValueKey(task.done),
                        value: task.done,
                        onChanged: (_) => ref
                            .read(tasksControllerProvider.notifier)
                            .toggle(task.id),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(context).withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _statusColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          decoration:
                              task.done ? TextDecoration.lineThrough : null,
                          color: Colors.black87,
                        ),
                        child: Text(task.title),
                      ),
                      if ((task.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.more_horiz, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Seguro que deseas eliminarla?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, Task task) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TaskActionsSheet(task: task),
    );
  }
}

/// ====== BOTTOM SHEET DE ACCIONES ======
class _TaskActionsSheet extends ConsumerWidget {
  const _TaskActionsSheet({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 280),
                    pageBuilder: (_, __, ___) => TaskFormPage(initial: task),
                    transitionsBuilder: (_, anim, __, child) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, .05),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic));
                      final fade =
                          CurvedAnimation(parent: anim, curve: Curves.easeOut);
                      return FadeTransition(
                        opacity: fade,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                  ),
                );
              },
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(task.done
                  ? Icons.radio_button_unchecked
                  : Icons.check_circle_outline),
              title: Text(
                  task.done ? 'Marcar como pendiente' : 'Marcar como hecha'),
              onTap: () async {
                // capturamos el notifier ANTES
                final notifier = ref.read(tasksControllerProvider.notifier);
                await notifier.toggle(task.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz_outlined),
              title: const Text('Cambiar estado'),
              subtitle: const Text('Pendiente, En progreso, Hecha'),
              onTap: () async {
                final notifier = ref.read(tasksControllerProvider.notifier);
                final sel = await _pickStatus(context, task.status);
                if (sel != null) {
                  await notifier.changeStatus(task.id, sel);
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final notifier = ref.read(tasksControllerProvider.notifier);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar tarea'),
                    content: const Text('¿Seguro que deseas eliminarla?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar')),
                      FilledButton.tonal(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Eliminar')),
                    ],
                  ),
                );
                if (ok == true) {
                  await notifier.delete(task.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tarea eliminada')),
                    );
                    Navigator.pop(context); // cierra el sheet
                  }
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<TaskStatus?> _pickStatus(
      BuildContext context, TaskStatus current) async {
    return showModalBottomSheet<TaskStatus>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<TaskStatus>(
              value: TaskStatus.PENDING,
              groupValue: current,
              title: const Text('Pendiente'),
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<TaskStatus>(
              value: TaskStatus.IN_PROGRESS,
              groupValue: current,
              title: const Text('En progreso'),
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<TaskStatus>(
              value: TaskStatus.DONE,
              groupValue: current,
              title: const Text('Hecha'),
              onChanged: (v) => Navigator.pop(context, v),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// ====== FILTRO ======
class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.current, required this.onChanged});
  final bool? current;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool?>(
      tooltip: 'Filtrar',
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem<bool?>(
            value: null,
            child: _FilterRow(icon: Icons.list_alt, text: 'Todas')),
        PopupMenuItem<bool?>(
            value: false,
            child: _FilterRow(icon: Icons.timelapse, text: 'Pendientes')),
        PopupMenuItem<bool?>(
            value: true,
            child: _FilterRow(icon: Icons.check_circle, text: 'Hechas')),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.filter_alt_outlined, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              current == null
                  ? 'Todas'
                  : (current == true ? 'Hechas' : 'Pendientes'),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18),
      const SizedBox(width: 8),
      Text(text),
    ]);
  }
}

/// ====== UI extra ======
class _TopLinearActivity extends StatelessWidget {
  const _TopLinearActivity();
  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: kToolbarHeight - 3),
        child: LinearProgressIndicator(minHeight: 3),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 450),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Transform.scale(
        scale: 0.98 + v * 0.02,
        child: Opacity(
          opacity: v,
          child: child,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty, size: 72, color: Colors.white70),
          const SizedBox(height: 12),
          const Text(
            'No hay tareas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Te llevaremos a crear tu primera tarea…',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
