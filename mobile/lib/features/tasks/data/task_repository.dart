import 'task_api.dart';
import 'task_model.dart';

/// Orquesta las operaciones de tareas y sirve como punto único
/// para la UI/estado. Mantiene la API intercambiable/testeable.
class TaskRepository {
  final TaskApi api;
  TaskRepository(this.api);

  Future<List<Task>> list({bool? done}) => api.list(done: done);
  Future<Task> getById(int id) => api.getById(id);
  Future<Task> create(
          {required String title, String? description, TaskStatus? status}) =>
      api.create(title: title, description: description, status: status);
  Future<Task> update(Task t) => api.update(t);
  Future<Task> changeStatus(int id, TaskStatus status) =>
      api.changeStatus(id, status);
  Future<Task> toggle(int id) => api.toggle(id);
  Future<void> delete(int id) => api.delete(id);
}
