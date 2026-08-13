import '../exceptions/task_exceptions.dart';
import 'priority.dart';
import 'simple_task.dart';
import 'urgent_task.dart';

/// Interface implémentée par tout objet capable de se décrire
/// sous forme de texte destiné à l'affichage CLI.
///
/// C'est l'interface exigée par le cahier des charges : en Dart,
/// une classe "implémente" une interface en implémentant une autre
/// classe/classe abstraite avec `implements`.
abstract class Describable {
  String describe();
}

/// Classe abstraite représentant une tâche.
///
/// - Implémente [Comparable] pour permettre le tri par priorité.
/// - Implémente [Describable] (interface) pour l'affichage CLI.
/// - Sert de classe de base pour [SimpleTask] et [UrgentTask]
///   (démonstration de l'héritage).
abstract class Task implements Comparable<Task>, Describable {
  final String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required String title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : title = _validateTitle(title),
        createdAt = createdAt ?? DateTime.now();

  static String _validateTitle(String title) {
    if (title.trim().isEmpty) {
      throw const InvalidTaskException('Le titre d\'une tâche ne peut pas être vide');
    }
    return title.trim();
  }

  /// Identifiant du type concret, utilisé pour la (dé)sérialisation
  /// JSON polymorphique. Chaque sous-classe doit le définir.
  String get type;

  void markAsCompleted() {
    isCompleted = true;
  }

  /// Sérialise la tâche en Map JSON-compatible.
  /// Les sous-classes surchargent cette méthode pour ajouter leurs
  /// propres champs, en appelant `super.toJson()` d'abord.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
    };
  }

  /// Tri par priorité décroissante (high avant low).
  /// À priorité égale, la tâche la plus ancienne (createdAt) passe en premier.
  @override
  int compareTo(Task other) {
    final byPriority = other.priority.weight.compareTo(priority.weight);
    if (byPriority != 0) return byPriority;
    return createdAt.compareTo(other.createdAt);
  }

  @override
  String toString() => describe();

  /// Désérialise une [Task] à partir d'une Map JSON, en choisissant
  /// la sous-classe concrète appropriée grâce au champ `type`.
  static Task fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'urgent':
        return UrgentTask.fromJson(json);
      case 'simple':
        return SimpleTask.fromJson(json);
      default:
        throw InvalidTaskException('Type de tâche inconnu dans le JSON : "$type"');
    }
  }
}
