import 'dart:io';

import 'package:task_cli/src/exceptions/task_exceptions.dart';
import 'package:task_cli/src/models/priority.dart';
import 'package:task_cli/src/models/simple_task.dart';
import 'package:task_cli/src/repository/task_repository.dart';
import 'package:test/test.dart';

void main() {
  late String testFilePath;

  setUp(() {
    testFilePath = 'test_tasks_${DateTime.now().microsecondsSinceEpoch}.json';
  });

  tearDown(() async {
    final file = File(testFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  });

  group('TaskRepository CRUD', () {
    test('add puis getAll retourne la tâche ajoutée', () async {
      final repo = TaskRepository(filePath: testFilePath);
      final task = SimpleTask(id: '1', title: 'Écrire le README', priority: Priority.medium);

      await repo.add(task);
      final all = await repo.getAll();

      expect(all, hasLength(1));
      expect(all.first.id, '1');
    });

    test('add avec un id déjà existant lève InvalidTaskException', () async {
      final repo = TaskRepository(filePath: testFilePath);
      await repo.add(SimpleTask(id: '1', title: 'Tâche A', priority: Priority.low));

      // Note : on passe directement le Future à throwsA (et pas une closure
      // synchrone), car l'exception d'une fonction async est portée par le
      // Future retourné, non levée de façon synchrone lors de l'appel.
      await expectLater(
        repo.add(SimpleTask(id: '1', title: 'Tâche B', priority: Priority.low)),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('getById lève TaskNotFoundException si l\'id est inconnu', () async {
      final repo = TaskRepository(filePath: testFilePath);

      await expectLater(
        repo.getById('inexistant'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('update modifie une tâche existante', () async {
      final repo = TaskRepository(filePath: testFilePath);
      final task = SimpleTask(id: '1', title: 'Titre initial', priority: Priority.low);
      await repo.add(task);

      task.title = 'Titre modifié';
      task.markAsCompleted();
      await repo.update(task);

      final updated = await repo.getById('1');
      expect(updated.title, 'Titre modifié');
      expect(updated.isCompleted, isTrue);
    });

    test('delete supprime une tâche, delete sur id inconnu lève une exception', () async {
      final repo = TaskRepository(filePath: testFilePath);
      await repo.add(SimpleTask(id: '1', title: 'À supprimer', priority: Priority.low));

      await repo.delete('1');
      final all = await repo.getAll();
      expect(all, isEmpty);

      await expectLater(repo.delete('1'), throwsA(isA<TaskNotFoundException>()));
    });
  });

  group('Persistance JSON', () {
    test('les tâches sont rechargées depuis le fichier par une nouvelle instance', () async {
      final repo1 = TaskRepository(filePath: testFilePath);
      await repo1.add(SimpleTask(id: '1', title: 'Persistée', priority: Priority.high));

      final repo2 = TaskRepository(filePath: testFilePath);
      final all = await repo2.getAll();

      expect(all, hasLength(1));
      expect(all.first.title, 'Persistée');
    });
  });

  group('Tri', () {
    test('sortedByPriority place les tâches high en premier', () async {
      final repo = TaskRepository(filePath: testFilePath);
      await repo.add(SimpleTask(id: '1', title: 'Basse', priority: Priority.low));
      await repo.add(SimpleTask(id: '2', title: 'Haute', priority: Priority.high));

      final sorted = await repo.sortedByPriority();

      expect(sorted.first.id, '2');
    });
  });
}
