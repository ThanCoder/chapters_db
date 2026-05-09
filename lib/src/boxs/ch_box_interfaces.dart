abstract class ChBoxInterfaces<T, R> {
  ///
  /// ### Add Single
  ///
  Future<T?> add(T value);

  Future<void> addAll(List<T> values);

  Future<bool> updateById(int id, T value);
  Future<bool> deleteById(int id);
  Future<void> deleteAll(List<int> idList);

  Future<List<R>> getAll({int? parentId, int? langCode});
  Future<R?> getOne(
    bool Function(R value) test, {
    int? parentId,
    int? langCode,
  });
  // query
  Future<List<R>> getQuery(
    bool Function(R value) test, {
    int? parentId,
    int? langCode,
  });

  // Stream
  Stream<R> getAllStream({int? parentId, int? langCode});
  Stream<List<R>> getQueryStream(
    bool Function(R value) test, {
    int? parentId,
    int? langCode,
  });
  Stream<R?> getOneStream(
    bool Function(R value) test, {
    int? parentId,
    int? langCode,
  });
}
