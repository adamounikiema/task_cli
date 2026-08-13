import '../exceptions/task_exceptions.dart';

/// Niveau de priorité d'une tâche.
enum Priority {
  low,
  medium,
  high;

  /// Poids numérique utilisé pour le tri (plus haut = plus urgent).
  int get weight {
    switch (this) {
      case Priority.low:
        return 0;
      case Priority.medium:
        return 1;
      case Priority.high:
        return 2;
    }
  }

  /// Convertit une chaîne (ex: "high", "HIGH") en [Priority].
  static Priority fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final priority in Priority.values) {
      if (priority.name == normalized) return priority;
    }
    throw InvalidTaskException(
      'Priorité invalide : "$value" (valeurs autorisées : low, medium, high)',
    );
  }
}
