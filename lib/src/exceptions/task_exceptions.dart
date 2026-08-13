/// Exception de base pour toutes les erreurs liées aux tâches.
///
/// Toutes les exceptions métier de l'application héritent de cette classe,
/// ce qui permet de les intercepter collectivement avec `on TaskException`.
abstract class TaskException implements Exception {
  final String message;

  const TaskException(this.message);

  @override
  String toString() => 'TaskException: $message';
}

/// Levée lorsqu'une tâche demandée (par id) n'existe pas dans le dépôt.
class TaskNotFoundException extends TaskException {
  final String taskId;

  TaskNotFoundException(this.taskId)
      : super('Aucune tâche trouvée avec l\'id "$taskId"');

  @override
  String toString() => 'TaskNotFoundException: $message';
}

/// Levée lorsque les données fournies pour créer/modifier une tâche
/// sont invalides (titre vide, priorité inconnue, id dupliqué, etc.).
class InvalidTaskException extends TaskException {
  const InvalidTaskException(super.message);

  @override
  String toString() => 'InvalidTaskException: $message';
}

/// Levée en cas d'erreur lors de la lecture ou de l'écriture du fichier
/// de persistance JSON.
class PersistenceException extends TaskException {
  const PersistenceException(super.message);

  @override
  String toString() => 'PersistenceException: $message';
}
