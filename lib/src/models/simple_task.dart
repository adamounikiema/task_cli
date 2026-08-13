import 'priority.dart';
import 'task.dart';

/// Tâche standard, sans comportement particulier au-delà de [Task].
class SimpleTask extends Task {
  SimpleTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted,
    super.createdAt,
  });

  @override
  String get type => 'simple';

  @override
  String describe() {
    final status = isCompleted ? '[x]' : '[ ]';
    final due = dueDate != null ? ' (échéance : ${_formatDate(dueDate!)})' : '';
    return '$status $title — priorité: ${priority.name}$due';
  }

  factory SimpleTask.fromJson(Map<String, dynamic> json) {
    return SimpleTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.fromString(json['priority'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
