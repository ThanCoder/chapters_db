import 'package:chapters_db/src/adapters/ch_adapter.dart';
import 'package:chapters_db/src/adapters/default_chapter_adapter.dart';
import 'package:chapters_db/src/boxs/ch_box.dart';
import 'package:chapters_db/src/databases/ch_config.dart';
import 'package:chapters_db/src/databases/index_db.dart';
import 'package:chapters_db/src/models/default_chapter.dart';

///Main Database Class
class ChaptersDB {
  static ChaptersDB? _instance;

  ///instance for singleton
  static ChaptersDB getInstance() {
    _instance ??= ChaptersDB();
    return _instance!;
  }

  final _indexDB = IndexDB();
  final Map<Type, ChBox> _box = {};
  final Map<Type, ChAdapter<dynamic>> _adapter = {};

  ///
  /// ### Open Database
  ///
  Future<void> open(String dbPath, {ChConfig? config}) async {
    if (isOpened) return;
    _indexDB.setConfig(dbPath, config: config ?? ChConfig.empty());
    await _indexDB.load();
  }

  ///
  /// ### Refersh Database
  ///
  Future<void> refresh() async {
    if (!isOpened) return;
    _indexDB.reSetConfig();
    await _indexDB.load();
  }

  ///
  /// ### Get Record Box
  ///
  ChBox<T> getBox<T>() {
    final box = _box[T];
    if (box == null) {
      if (T == DefaultChapter) {
        _adapter[T] = DefaultChapterAdapter();
        _box[T] = ChBox<T>(
          adapter: _adapter[T] as ChAdapter<T>,
          indexDB: _indexDB,
        );
      } else {
        throw Exception(
          "Adapter for `$T` not found. Please register it first.",
        );
      }
    }
    return _box[T] as ChBox<T>;
  }

  ///
  /// ### Get Default Box
  ///
  ChBox<DefaultChapter> getDefaultBox() {
    return getBox<DefaultChapter>();
  }

  ///
  /// ### Register Adapter
  ///
  void registerAdapterNotExists<T>(ChAdapter<T> adapter) {
    final ids = _adapter.values.map((e) => e.adapterId).toList();
    if (ids.contains(adapter.adapterId)) return;
    _adapter[T] = adapter;
    _box[T] = ChBox<T>(adapter: adapter, indexDB: _indexDB);
  }

  ///
  /// ### Check Database Opened
  ///
  bool get isOpened => _indexDB.isOpened;

  ///
  /// ### Close Database
  ///
  Future<void> close() async {
    if (!isOpened) return;
    await _indexDB.close();
  }

  ///
  /// ### Database Clean Up
  ///
  Future<void> compact() async {
    await _indexDB.compact();
  }

  /// db deleted size
  int get deleteSize => _indexDB.deleteSize;

  /// db deleted count
  int get deletedCount => _indexDB.deletedCount;

  /// db last id
  int get lastId => _indexDB.lastId;

  /// all record counts
  int getAllCount({int? parentId, int? langCode}) =>
      _indexDB.getAllCount(parentId: parentId, langCode: langCode);
}
