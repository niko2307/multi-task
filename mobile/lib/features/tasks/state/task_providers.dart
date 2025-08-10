import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/http.dart';
import '../../auth/state/auth_controller.dart'
    show flutterSecureStorageProvider; // <-- lo reutilizamos desde auth

import '../data/task_api.dart';
import '../data/task_model.dart';
import '../data/task_repository.dart';

/// ===============================
/// Providers base (API / Repo) - opción 1
/// ===============================

/// Construye Dio usando directamente FlutterSecureStorage,
/// porque Http.build espera ese tipo.
final tasksDioProvider = Provider<Dio>((ref) {
  final secure = ref.read(flutterSecureStorageProvider); // viene de auth/state
  return Http.build(secure); // <-- ahora coincide el tipo esperado
});

final taskApiProvider = Provider<TaskApi>((ref) {
  return TaskApi(ref.read(tasksDioProvider));
});

final taskRepoProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(taskApiProvider));
});

/// ===============================
/// Filtro y flags
/// ===============================
final taskDoneFilterProvider = StateProvider<bool?>((_) => null);
final taskMutatingProvider = StateProvider<bool>((_) => false);

/// ===============================
/// Controller (AsyncNotifier)
/// ===============================
class TasksController extends AsyncNotifier<List<Task>> {
  TaskRepository get _repo => ref.read(taskRepoProvider);

  @override
  Future<List<Task>> build() async {
    final filter = ref.watch(taskDoneFilterProvider);
    return _repo.list(done: filter);
  }

  Future<void> setFilter(bool? done) async {
    ref.read(taskDoneFilterProvider.notifier).state = done;
    await refresh();
  }

  Future<void> refresh() async {
    final filter = ref.read(taskDoneFilterProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.list(done: filter));
  }

  Future<void> create({
    required String title,
    String? description,
    TaskStatus? status,
  }) async {
    ref.read(taskMutatingProvider.notifier).state = true;
    try {
      final created = await _repo.create(
        title: title,
        description: description,
        status: status,
      );
      state = state.whenData((list) => [created, ...list]);
    } finally {
      ref.read(taskMutatingProvider.notifier).state = false;
    }
  }

  Future<void> updateTask(Task t) async {
    ref.read(taskMutatingProvider.notifier).state = true;
    try {
      final updated = await _repo.update(t);
      state = state.whenData(
        (list) => list.map((x) => x.id == updated.id ? updated : x).toList(),
      );
    } finally {
      ref.read(taskMutatingProvider.notifier).state = false;
    }
  }

  Future<void> changeStatus(int id, TaskStatus status) async {
    ref.read(taskMutatingProvider.notifier).state = true;
    try {
      final updated = await _repo.changeStatus(id, status);
      state = state.whenData(
        (list) => list.map((x) => x.id == id ? updated : x).toList(),
      );
    } finally {
      ref.read(taskMutatingProvider.notifier).state = false;
    }
  }

  Future<void> toggle(int id) async {
    ref.read(taskMutatingProvider.notifier).state = true;
    try {
      final updated = await _repo.toggle(id);
      state = state.whenData(
        (list) => list.map((x) => x.id == id ? updated : x).toList(),
      );
    } finally {
      ref.read(taskMutatingProvider.notifier).state = false;
    }
  }

  Future<void> delete(int id) async {
    ref.read(taskMutatingProvider.notifier).state = true;
    try {
      await _repo.delete(id);
      state = state.whenData(
        (list) => list.where((x) => x.id != id).toList(),
      );
    } finally {
      ref.read(taskMutatingProvider.notifier).state = false;
    }
  }
}

final tasksControllerProvider =
    AsyncNotifierProvider<TasksController, List<Task>>(TasksController.new);

final taskByIdProvider = FutureProvider.family<Task, int>((ref, id) async {
  return ref.read(taskRepoProvider).getById(id);
});
