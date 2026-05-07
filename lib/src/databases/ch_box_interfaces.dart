abstract class ChBoxInterfaces<T> {
  ///
  /// ### Add Single
  ///
  Future<T?> add(T value);

  Future<void> addAll(List<T> values);

  Future<bool> updateById(int id, T value);
  Future<bool> deleteById(int id);
  Future<void> deleteAll(List<int> idList);
  Future<List<T>> getAll({int? parentId, int? langCode});
  Future<T?> getOne(bool Function(T value) test);
  // query
  Future<List<T>> getQuery(
    bool Function(T value) test, {
    int? parentId,
    int? langCode,
  });

  // Stream
  Stream<T> getAllStream({int? parentId, int? langCode});
  Stream<List<T>> getQueryStream(bool Function(T value) test);
  Stream<T?> getOneStream(bool Function(T value) test);
}
