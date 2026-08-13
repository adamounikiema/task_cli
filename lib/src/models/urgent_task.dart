import 'priority.dart';
import 'task.dart';

/// Tâche urgente : hérite de [Task] mais ajoute un délai de rappel
/// et surcharge [describe] pour afficher un rendu distinct (polymorphisme).
class UrgentTask extends Task {
  /// Nombre d'heures avant l'échéance auxquelles un rappel doit être envoyé.
  final int reminderHoursBefore;

  // Note : on ne peut pas mélanger les super-paramètres (super.xxx) avec un
  // appel explicite à super(...), donc les champs hérités sont déclarés
  // "normalement" ici et transmis explicitement au constructeur parent.
  UrgentTask({
    required String id,
    required String title,
    DateTime? dueDate,
    bool isCompleted = false,
    DateTime? createdAt,
    this.reminderHoursBefore = 24,
  }) : super(
          id: id,
          title: title,
          priority: Priority.high, // une tâche urgente est toujours "high"
          dueDate: dueDate,
          isCompleted: isCompleted,
          createdAt: createdAt,
        );

  @override
  String get type => 'urgent';

  @override
  String describe() {
    final status = isCompleted ? '[x]' : '[ ]';
    final due = dueDate != null ? ' (échéance : ${_formatDate(dueDate!)})' : '';
    return '🔥 $status URGENT — $title$due — rappel ${reminderHoursBefore}h avant';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['reminderHoursBefore'] = reminderHoursBefore;
    return json;
  }

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reminderHoursBefore: json['reminderHoursBefore'] as int? ?? 24,
    );
  }
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
