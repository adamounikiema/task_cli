/// Contrat générique CRUD, indépendant du type de donnée stocké.
///
/// Utiliser des génériques ici permet de réutiliser cette interface
/// pour n'importe quelle entité (`Repository<Task>`, mais aussi
/// potentiellement `Repository<User>`, `Repository<Project>`, etc.)
abstract class Repository<T> {
  Future<void> add(T item);
  Future<List<T>> getAll();
  Future<T> getById(String id);
  Future<void> update(T item);
  Future<void> delete(String id);
}
