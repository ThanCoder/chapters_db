import 'dart:convert';

import 'package:chapters_db/src/adapters/ch_adapter.dart';
import 'package:chapters_db/src/boxs/ch_box_crud.dart';
import 'package:chapters_db/src/databases/chapter_record.dart';
import 'package:chapters_db/src/databases/index_db.dart';
import 'package:chapters_db/src/models/chapter_info.dart';

///Record Box Manager Class
class ChBox<T> extends ChBoxCrud<T, ChapterInfo<T>> {
  final ChAdapter<T> _adapter;
  final IndexDB _indexDB;

  ///init
  ChBox({required ChAdapter<T> adapter, required IndexDB indexDB})
    : _adapter = adapter,
      _indexDB = indexDB;

  @override
  int get allCount => _indexDB.getAllCount();

  @override
  int getAllCount({int? parentId, int? langCode}) =>
      _indexDB.getAllCount(parentId: parentId, langCode: langCode);

  @override
  Future<T?> add(T value) async {
    final id = _indexDB.generatedId;
    final map = _adapter.setId(id, _adapter.toMap(value));
    final adapterId = _adapter.adapterId;
    final title = utf8.encode(_adapter.getTitle(value));
    final parentId = _adapter.parentId(value);
    final langCode = _adapter.getLangCode(value);
    final chapter = _adapter.getChapter(value);
    final data = _adapter.encodeData(_adapter.toJson(map));
    await _indexDB.add(
      ChapterRecord(
        id: id,
        title: title,
        adapterId: adapterId,
        parentId: parentId,
        langCode: langCode,
        chapter: chapter,
        data: data,
      ),
    );
    return _adapter.fromMap(map);
  }

  @override
  Future<void> addAll(List<T> values) async {
    for (var value in values) {
      final id = _indexDB.generatedId;
      final map = _adapter.setId(id, _adapter.toMap(value));
      await _indexDB.add(
        ChapterRecord(
          id: id,
          title: utf8.encode(_adapter.getTitle(value)),
          adapterId: _adapter.adapterId,
          parentId: _adapter.parentId(value),
          langCode: _adapter.getLangCode(value),
          chapter: _adapter.getChapter(value),
          data: _adapter.encodeData(_adapter.toJson(map)),
        ),
        callFlush: false,
      );
    }

    await _indexDB.writeFlush();
  }

  @override
  Future<void> deleteAll(List<int> idList) async {
    await _indexDB.deleteMultiple(idList);
  }

  @override
  Future<bool> deleteById(int id) async {
    try {
      await _indexDB.deleteById(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ChapterInfo<T>>> getAll({int? parentId, int? langCode}) async {
    final list = <ChapterInfo<T>>[];
    for (var meta in _indexDB.getAll(parentId: parentId, langCode: langCode)) {
      if (meta.adapterId != _adapter.adapterId) continue;
      final ch = ChapterInfo<T>.fromMeta(
        meta,
        readRaf: _indexDB.readRaf,
        adapter: _adapter,
      );
      list.add(ch);
    }
    return list;
  }

  @override
  Stream<ChapterInfo<T>> getAllStream({int? parentId, int? langCode}) async* {
    for (var meta in _indexDB.getAll(parentId: parentId, langCode: langCode)) {
      if (meta.adapterId != _adapter.adapterId) continue;
      final ch = ChapterInfo<T>.fromMeta(
        meta,
        readRaf: _indexDB.readRaf,
        adapter: _adapter,
      );
      yield ch;
    }
  }

  @override
  Future<ChapterInfo<T>?> getOne(
    bool Function(ChapterInfo<T> value) test, {
    int? parentId,
    int? langCode,
  }) async {
    for (var value in await getAll(parentId: parentId, langCode: langCode)) {
      if (test(value)) {
        return value;
      }
    }
    return null;
  }

  @override
  Stream<ChapterInfo<T>?> getOneStream(
    bool Function(ChapterInfo<T> value) test, {
    int? parentId,
    int? langCode,
  }) async* {
    await for (var value in getAllStream(
      parentId: parentId,
      langCode: langCode,
    )) {
      if (test(value)) {
        yield value;
      }
    }
    yield null;
  }

  @override
  Future<List<ChapterInfo<T>>> getQuery(
    bool Function(ChapterInfo<T> value) test, {
    int? parentId,
    int? langCode,
  }) async {
    final list = <ChapterInfo<T>>[];
    for (var value in await getAll(parentId: parentId, langCode: langCode)) {
      if (test(value)) {
        list.add(value);
      }
    }
    return list;
  }

  @override
  Stream<List<ChapterInfo<T>>> getQueryStream(
    bool Function(ChapterInfo<T> value) test, {
    int? parentId,
    int? langCode,
  }) async* {
    final list = <ChapterInfo<T>>[];
    await for (var value in getAllStream()) {
      if (test(value)) {
        list.add(value);
      }
    }
    yield list;
  }

  @override
  Future<bool> updateById(int id, T value) async {
    try {
      // delete old
      await _indexDB.deleteById(id);

      final map = _adapter.setId(id, _adapter.toMap(value));
      await _indexDB.add(
        ChapterRecord(
          id: id,
          title: utf8.encode(_adapter.getTitle(value)),
          adapterId: _adapter.adapterId,
          parentId: _adapter.parentId(value),
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
