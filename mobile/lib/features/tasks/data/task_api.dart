import 'package:dio/dio.dart';
import '../../../core/env.dart';
import '../../../core/dio_error_mapper.dart';
import '../../../core/app_exception.dart';
import 'task_model.dart';

/// Capa de acceso HTTP. Llama a los endpoints REST del backend.
/// Rutas esperadas (prefijadas por Env.url('/...')):
/// GET    /tasks
/// GET    /tasks/:id
/// POST   /tasks
/// PUT    /tasks/:id
/// PATCH  /tasks/:id/status
/// PATCH  /tasks/:id/toggle
/// DELETE /tasks/:id/delete
class TaskApi {
  TaskApi(this.dio);
  final Dio dio;

  Future<List<Task>> list(
      {bool? done, TaskStatus? status, String? search}) async {
    final qp = <String, dynamic>{};
    if (done != null) qp['done'] = done.toString();
    if (status != null) qp['status'] = statusToApi(status);
    if (search != null && search.trim().isNotEmpty)
      qp['search'] = search.trim();

    final r = await dio.get('tasks', queryParameters: qp);
    final data = (r.data as List).cast<Map<String, dynamic>>();
    return data.map(Task.fromJson).toList();
  }

  // ⬇⬇⬇ cambio clave: POST a tasks/create
  Future<Task> create(
      {required String title, String? description, TaskStatus? status}) async {
    final body = {
      'title': title,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      if (status != null) 'status': statusToApi(status),
    };
    final r = await dio.post('/tasks/create', data: body);
    return Task.fromJson(r.data);
  }

  Future<Task> getById(int id) async {
    final r = await dio.get('/tasks/$id');
    return Task.fromJson(r.data);
  }

  Future<Task> update(Task t) async {
    final r = await dio.put('/tasks/${t.id}', data: {
      'title': t.title,
      'description': t.description,
      'status': statusToApi(t.status),
      'done': t.done,
    });
    return Task.fromJson(r.data);
  }

  Future<Task> changeStatus(int id, TaskStatus status) async {
    final r = await dio
        .patch('/tasks/$id/status', data: {'status': statusToApi(status)});
    return Task.fromJson(r.data as Map<String, dynamic>);
  }

  Future<Task> toggle(int id) async {
    final r = await dio.patch('/tasks/$id/toggle');
    return Task.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await dio.delete('/tasks/$id/delete');
  }
}
