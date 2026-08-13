import 'package:task_cli/src/exceptions/task_exceptions.dart';
import 'package:task_cli/src/models/priority.dart';
import 'package:task_cli/src/models/simple_task.dart';
import 'package:task_cli/src/models/task.dart';
import 'package:task_cli/src/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('SimpleTask', () {
    test('markAsCompleted passe isCompleted à true', () {
      final task = SimpleTask(id: '1', title: 'Faire les courses', priority: Priority.low);
      expect(task.isCompleted, isFalse);
      task.markAsCompleted();
      expect(task.isCompleted, isTrue);
    });

    test('toJson / fromJson préservent les données (round-trip)', () {
      final due = DateTime(2026, 8, 15);
      final task = SimpleTask(
        id: '42',
        title: 'Réviser le rapport',
        priority: Priority.medium,
        dueDate: due,
      );

      final json = task.toJson();
      final restored = Task.fromJson(json);

      expect(restored, isA<SimpleTask>());
      expect(restored.id, '42');
      expect(restored.title, 'Réviser le rapport');
      expect(restored.priority, Priority.medium);
      expect(restored.dueDate, due);
    });

    test('le titre ne peut pas être vide', () {
      expect(
        () => SimpleTask(id: '1', title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskException>()),
      );
    });
  });

  group('UrgentTask', () {
    test('est toujours de priorité high et décrit différemment de SimpleTask', () {
      final urgent = UrgentTask(id: '2', title: 'Éteindre l\'incendie');
      final simple = SimpleTask(id: '3', title: 'Éteindre l\'incendie', priority: Priority.high);

      expect(urgent.priority, Priority.high);
      expect(urgent.describe(), isNot(equals(simple.describe())));
      expect(urgent.describe(), contains('URGENT'));
    });

    test('toJson / fromJson préservent reminderHoursBefore', () {
      final urgent = UrgentTask(id: '5', title: 'Appeler le client', reminderHoursBefore: 2);
      final restored = Task.fromJson(urgent.toJson());

      expect(restored, isA<UrgentTask>());
      expect((restored as UrgentTask).reminderHoursBefore, 2);
    });
  });

  group('Tri (Comparable)', () {
    test('compareTo trie par priorité décroissante (high avant low)', () {
      final low = SimpleTask(id: '1', title: 'A', priority: Priority.low);
      final high = SimpleTask(id: '2', title: 'B', priority: Priority.high);
      final medium = SimpleTask(id: '3', title: 'C', priority: Priority.medium);

      final list = [low, high, medium]..sort();

      expect(list, [high, medium, low]);
    });
  });
}
