# task_cli

Application CLI de gestion de tâches, écrite en **Dart pur** (aucune dépendance
Flutter, aucun package tiers en dépendance de production).

## Fonctionnalités

- Ajouter une tâche (titre, priorité `low`/`medium`/`high`, date limite optionnelle)
- Lister les tâches, avec tri par priorité ou par date limite
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persistance automatique dans un fichier JSON local (`tasks.json` par défaut)

## Prérequis

- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0

Vérifier l'installation :

```bash
dart --version
```

## Installation

```bash
git clone <url-du-repo>
cd task_cli
dart pub get
```

## Utilisation

```bash
# Ajouter une tâche simple
dart run bin/main.dart add "Préparer la présentation" --priority=high --due=2026-08-15

# Ajouter une tâche urgente (priorité "high" imposée automatiquement)
dart run bin/main.dart add "Payer la facture" --urgent

# Lister toutes les tâches
dart run bin/main.dart list

# Lister triées par priorité
dart run bin/main.dart list --sort=priority

# Lister triées par date limite
dart run bin/main.dart list --sort=date

# Marquer une tâche comme terminée (utiliser l'id affiché par `list`)
dart run bin/main.dart complete <id>

# Supprimer une tâche
dart run bin/main.dart delete <id>

# Aide
dart run bin/main.dart help
```

Les tâches sont automatiquement sauvegardées dans `tasks.json`, créé dans le
répertoire courant lors du premier ajout.

## Lancer les tests

```bash
dart test
```

Cela exécute la suite de tests unitaires (`test/task_test.dart` et
`test/task_repository_test.dart`), qui couvre notamment :

- la validation et la (dé)sérialisation JSON des tâches ;
- le polymorphisme entre `SimpleTask` et `UrgentTask` ;
- le tri via `Comparable` ;
- les opérations CRUD du `TaskRepository` ;
- la persistance JSON (rechargement depuis le fichier par une nouvelle instance) ;
- la gestion des exceptions personnalisées (`TaskNotFoundException`,
  `InvalidTaskException`).

## Architecture et choix techniques

```
lib/
  src/
    models/
      priority.dart       Enum Priority (low/medium/high) + parsing
      task.dart            Classe abstraite Task (+ interface Describable)
      simple_task.dart      Sous-classe SimpleTask
      urgent_task.dart      Sous-classe UrgentTask
    exceptions/
      task_exceptions.dart  Exceptions personnalisées
    repository/
      repository.dart       Interface générique Repository<T>
      task_repository.dart  Implémentation JSON de Repository<Task>
    cli/
      cli_app.dart           Parsing des commandes et affichage CLI
bin/
  main.dart                  Point d'entrée exécutable
test/
  task_test.dart              Tests sur les modèles
  task_repository_test.dart   Tests sur le dépôt et la persistance
```

Correspondance avec les exigences techniques :

- **Classes abstraites et héritage** : `Task` est abstraite ; `SimpleTask` et
  `UrgentTask` en héritent et redéfinissent `describe()` et `type`.
- **Interface** : `Describable` (interface au sens Dart : classe abstraite
  utilisée avec `implements`) est implémentée par `Task`, qui implémente
  également `Comparable<Task>` pour le tri.
- **Génériques** : `Repository<T>` définit un contrat CRUD générique,
  implémenté par `TaskRepository implements Repository<Task>`.
- **Exceptions personnalisées** : `TaskException` (classe abstraite de base),
  `TaskNotFoundException`, `InvalidTaskException`, `PersistenceException`.
- **Tests unitaires** : 10 tests avec le package `test`, répartis sur les
  modèles et le dépôt.

## Publier ce projet sur GitHub

```bash
cd task_cli
git init
git add .
git commit -m "Initial commit: task_cli"
git branch -M main
git remote add origin https://github.com/<votre-utilisateur>/task_cli.git
git push -u origin main
```

Pensez à rendre le dépôt public dans les paramètres GitHub si ce n'est pas déjà
le cas.
