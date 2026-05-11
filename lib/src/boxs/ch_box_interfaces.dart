///Inferface for ChBox`<T>`
abstract class ChBoxInterfaces<T, R> {
  ///
  /// ### Add Single
  ///
  Future<T?> add(T value);

  ///add all
  Future<void> addAll(List<T> values);

  ///update
  Future<bool> updateById(int id, T value);

  ///delete with id
  Future<bool> deleteById(int id);

  ///delete with id list
  Future<void> deleteAll(List<int> idList);

  ///get all with `parentId`,`langCode`
  Future<List<R>> getAll({int? parentId, int? langCode});

  /// get one
  Future<R?> getOne(
    bool Function(R value) test, {
    int? parentId,
    int? langCode,
  });

  /// query
  Future<List<R>> getQuery(
    bool Function(R value) test, {
    int? parentId,
    int? langCode,
  });

  /// get all Stream
  Stream<R> getAllStream({int? parentId, int? langCode});

  /// query stream
  Stream<List<R>> getQueryStream(
    bool Function(R value) test, {
    int? parentId,
    int? langCode,
  });

  ///get one stream
  Stream<R?> getOneStream(
    bool Function(R value) test, {
    int? parentId,
    int? langCode,
  });
}
