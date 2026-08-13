import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import 'repository.dart';

/// Implémentation de [Repository]<[Task]> qui persiste les tâches
/// dans un fichier JSON local.
class TaskRepository implements Repository<Task> {
  final String filePath;
  final List<Task> _tasks = [];
  bool _loaded = false;

  TaskRepository({this.filePath = 'tasks.json'});

  Future<void> _ensureLoaded() async {
    if (!_loaded) {
      await load();
      _loaded = true;
    }
  }

  /// Charge les tâches depuis [filePath]. Si le fichier n'existe pas
  /// encore, part d'une liste vide (premier lancement de l'app).
  Future<void> load() async {
    final file = File(filePath);
    if (!await file.exists()) {
      _tasks.clear();
      return;
    }
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        _tasks.clear();
        return;
      }
      final decoded = jsonDecode(content) as List<dynamic>;
      _tasks
        ..clear()
        ..addAll(decoded.map((e) => Task.fromJson(e as Map<String, dynamic>)));
    } on FormatException catch (e) {
      throw PersistenceException('Fichier JSON invalide ($filePath) : $e');
    } on IOException catch (e) {
      throw PersistenceException('Erreur de lecture du fichier $filePath : $e');
    }
  }

  Future<void> _save() async {
    try {
      final file = File(filePath);
      final jsonList = _tasks.map((t) => t.toJson()).toList();
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonList));
    } on IOException catch (e) {
      throw PersistenceException('Erreur d\'écriture du fichier $filePath : $e');
    }
  }

  @override
  Future<void> add(Task item) async {
    await _ensureLoaded();
    if (_tasks.any((t) => t.id == item.id)) {
      throw InvalidTaskException('Une tâche avec l\'id "${item.id}" existe déjà');
    }
    _tasks.add(item);
    await _save();
  }

  @override
  Future<List<Task>> getAll() async {
    await _ensureLoaded();
    return List<Task>.unmodifiable(_tasks);
  }

  @override
  Future<Task> getById(String id) async {
    await _ensureLoaded();
    return _tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => throw TaskNotFoundException(id),
    );
  }

  @override
  Future<void> update(Task item) async {
    await _ensureLoaded();
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) throw TaskNotFoundException(item.id);
    _tasks[index] = item;
    await _save();
  }

  @override
  Future<void> delete(String id) async {
    await _ensureLoaded();
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw TaskNotFoundException(id);
    _tasks.removeAt(index);
    await _save();
  }

  /// Retourne une copie triée par priorité (high -> low).
  Future<List<Task>> sortedByPriority() async {
    final tasks = List<Task>.from(await getAll());
    tasks.sort(); // Task implémente Comparable<Task>
    return tasks;
  }

  /// Retourne une copie triée par date limite croissante.
  /// Les tâches sans date limite sont placées en fin de liste.
  Future<List<Task>> sortedByDueDate() async {
    final tasks = List<Task>.from(await getAll());
    tasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return tasks;
  }
}
