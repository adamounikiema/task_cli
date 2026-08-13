import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/simple_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../repository/task_repository.dart';

/// Point d'entrée logique de la CLI : parse les arguments et
/// délègue au [TaskRepository].
class CliApp {
  final TaskRepository repository;

  CliApp({TaskRepository? repository})
      : repository = repository ?? TaskRepository();

  Future<void> run(List<String> args) async {
    if (args.isEmpty) {
      _printHelp();
      return;
    }

    final command = args.first;
    final rest = args.skip(1).toList();

    try {
      switch (command) {
        case 'add':
          await _handleAdd(rest);
          break;
        case 'list':
          await _handleList(rest);
          break;
        case 'complete':
          await _handleComplete(rest);
          break;
        case 'delete':
          await _handleDelete(rest);
          break;
        case 'help':
        case '--help':
        case '-h':
          _printHelp();
          break;
        default:
          stdout.writeln('Commande inconnue : "$command"');
          _printHelp();
      }
    } on TaskException catch (e) {
      stderr.writeln('Erreur : ${e.message}');
      exitCode = 1;
    }
  }

  Future<void> _handleAdd(List<String> args) async {
    if (args.isEmpty) {
      throw const InvalidTaskException(
        'Titre manquant. Usage : add "<titre>" [--priority=low|medium|high] [--due=YYYY-MM-DD] [--urgent]',
      );
    }

    final title = args.first;
    final flags = _parseFlags(args.skip(1).toList());

    final isUrgent = flags.containsKey('urgent');
    final priorityStr = flags['priority'];
    final dueStr = flags['due'];

    DateTime? dueDate;
    if (dueStr != null) {
      try {
        dueDate = DateTime.parse(dueStr);
      } on FormatException {
        throw InvalidTaskException('Date invalide : "$dueStr" (format attendu : YYYY-MM-DD)');
      }
    }

    final id = _generateId();

    final Task task;
    if (isUrgent) {
      task = UrgentTask(id: id, title: title, dueDate: dueDate);
    } else {
      final priority = priorityStr != null ? Priority.fromString(priorityStr) : Priority.medium;
      task = SimpleTask(id: id, title: title, priority: priority, dueDate: dueDate);
    }

    await repository.add(task);
    stdout.writeln('Tâche ajoutée (id: $id) :');
    stdout.writeln('  ${task.describe()}');
  }

  Future<void> _handleList(List<String> args) async {
    final flags = _parseFlags(args);
    final sortBy = flags['sort'];

    List<Task> tasks;
    switch (sortBy) {
      case 'priority':
        tasks = await repository.sortedByPriority();
        break;
      case 'date':
        tasks = await repository.sortedByDueDate();
        break;
      default:
        tasks = await repository.getAll();
    }

    if (tasks.isEmpty) {
      stdout.writeln('Aucune tâche enregistrée.');
      return;
    }

    stdout.writeln('${tasks.length} tâche(s) :');
    for (final task in tasks) {
      stdout.writeln('  [${task.id}] ${task.describe()}');
    }
  }

  Future<void> _handleComplete(List<String> args) async {
    if (args.isEmpty) {
      throw const InvalidTaskException('Id manquant. Usage : complete <id>');
    }
    final id = args.first;
    final task = await repository.getById(id);
    task.markAsCompleted();
    await repository.update(task);
    stdout.writeln('Tâche "${task.title}" marquée comme terminée.');
  }

  Future<void> _handleDelete(List<String> args) async {
    if (args.isEmpty) {
      throw const InvalidTaskException('Id manquant. Usage : delete <id>');
    }
    final id = args.first;
    await repository.delete(id);
    stdout.writeln('Tâche "$id" supprimée.');
  }

  /// Parse des flags de la forme --clef=valeur ou --clef (booléen).
  Map<String, String> _parseFlags(List<String> args) {
    final flags = <String, String>{};
    for (final arg in args) {
      if (!arg.startsWith('--')) continue;
      final body = arg.substring(2);
      final eqIndex = body.indexOf('=');
      if (eqIndex == -1) {
        flags[body] = 'true';
      } else {
        flags[body.substring(0, eqIndex)] = body.substring(eqIndex + 1);
      }
    }
    return flags;
  }

  String _generateId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return now.toRadixString(36);
  }

  void _printHelp() {
    stdout.writeln('''
Gestionnaire de tâches — CLI Dart

Usage :
  dart run bin/main.dart add "<titre>" [--priority=low|medium|high] [--due=YYYY-MM-DD] [--urgent]
  dart run bin/main.dart list [--sort=priority|date]
  dart run bin/main.dart complete <id>
  dart run bin/main.dart delete <id>
  dart run bin/main.dart help

Exemples :
  dart run bin/main.dart add "Préparer la présentation" --priority=high --due=2026-08-15
  dart run bin/main.dart add "Payer la facture" --urgent
  dart run bin/main.dart list --sort=priority
  dart run bin/main.dart complete 1a2b3c
  dart run bin/main.dart delete 1a2b3c
''');
  }
}
