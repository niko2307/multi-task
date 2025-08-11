/// Enum de estados alineado con el backend (TypeORM enum)
enum TaskStatus { PENDING, IN_PROGRESS, DONE }

String statusToApi(TaskStatus s) {
  switch (s) {
    case TaskStatus.PENDING:
      return 'pending';
    case TaskStatus.IN_PROGRESS:
      return 'in_progress';
    case TaskStatus.DONE:
      return 'completed';
  }
}

TaskStatus statusFromApi(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'pending':
      return TaskStatus.PENDING;
    case 'in_progress':
      return TaskStatus.IN_PROGRESS;
    case 'completed':
      return TaskStatus.DONE;
    default:
      return TaskStatus.PENDING;
  }
}

/// Representa una tarea del usuario autenticado.
class Task {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final TaskStatus status;
  final bool done;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.status,
    required this.done,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as int,
        userId: j['userId'] as int,
        title: (j['title'] ?? '') as String,
        description: j['description'] as String?,
        status: statusFromApi(j['status']),
        done: (j['done'] ?? false) as bool,
        createdAt:
            j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
        updatedAt:
            j['updatedAt'] != null ? DateTime.parse(j['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'status': status.name,
        'done': done,
      };

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    bool? done,
  }) =>
      Task(
        id: id,
        userId: userId,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        done: done ?? this.done,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
