import 'package:chapters_db/src/databases/ch_adapter.dart';
import 'package:chapters_db/src/databases/ch_box_interfaces.dart';
import 'package:chapters_db/src/databases/chapter_record.dart';
import 'package:chapters_db/src/databases/index_db.dart';

class ChBox<T> extends ChBoxInterfaces<T> {
  final ChAdapter<T> _adapter;
  final IndexDB _indexDB;

  ChBox({required ChAdapter<T> adapter, required IndexDB indexDB})
    : _adapter = adapter,
      _indexDB = indexDB;

  @override
  Future<T?> add(T value) async {
    final id = _indexDB.generatedId;
    final map = _adapter.setId(id, _adapter.toMap(value));
    await _indexDB.add(
      ChapterRecord(
        id: id,
        adapterId: _adapter.getAdapterId,
        parentId: _adapter.getParentId,
        langCode: _adapter.getLangCode(value),
        chapter: _adapter.getChapter(value),
        data: _adapter.encodeData(_adapter.toJson(map)),
      ),
    );
    return _adapter.fromMap(map);
  }

  @override
  Future<void> addAll(List<T> values) {
    // TODO: implement addAll
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll(List<int> idList) {
    // TODO: implement deleteAll
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteById(int id) {
    // TODO: implement deleteById
    throw UnimplementedError();
  }

  @override
  Future<List<T>> getAll({int? parentId, int? langCode}) async {
    final list = <T>[];
    for (var meta in _indexDB.getAll(parentId: parentId, langCode: langCode)) {
      final data = await meta.readData(_indexDB.readRaf);
      final map = _adapter.fromJson(_adapter.decodeData(data));
      final value = _adapter.fromMap(_adapter.setId(meta.id, map));
      list.add(value);
    }
    return list;
  }

  @override
  Stream<T> getAllStream({int? parentId, int? langCode}) {
    // TODO: implement getAllStream
    throw UnimplementedError();
  }

  @override
  Future<T?> getOne(bool Function(T value) test) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Stream<T?> getOneStream(bool Function(T value) test) {
    // TODO: implement getOneStream
    throw UnimplementedError();
  }

  @override
  Future<List<T>> getQuery(
    bool Function(T value) test, {
    int? parentId,
    int? langCode,
  }) {
    // TODO: implement getQuery
    throw UnimplementedError();
  }

  @override
  Stream<List<T>> getQueryStream(bool Function(T value) test) {
    // TODO: implement getQueryStream
    throw UnimplementedError();
  }

  @override
  Future<bool> updateById(int id, T value) async {
    try {
      // delete old
      await _indexDB.deleteById(id);

      final map = _adapter.setId(id, _adapter.toMap(value));
      await _indexDB.add(
        ChapterRecord(
          id: _adapter.getId(value),
          adapterId: _adapter.getAdapterId,
          parentId: _adapter.getParentId,
          langCode: _adapter.getLangCode(value),
          chapter: _adapter.getChapter(value),
          data: _adapter.encodeData(_adapter.toJson(map)),
        ),
        callFlush: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
