import 'dart:io';
import 'dart:typed_data';

import 'package:chapters_db/src/databases/ch_config.dart';
import 'package:chapters_db/src/databases/chapter_record.dart';
import 'package:chapters_db/src/databases/record_meta.dart';

class IndexDB {
  late File dbFile;
  late RandomAccessFile _writeRaf;
  late RandomAccessFile _readRaf;
  late ChConfig _config;

  RandomAccessFile get readRaf => _readRaf;

  int _lastId = 0;
  int _deletedCount = 0;
  int _deletedSize = 0;

  final Map<int, RecordMeta> _records = {};
  final Map<int, List<RecordMeta>> _parentOfChild = {};
  final Map<int, List<RecordMeta>> _languageOfChild = {};
  Map<int, RecordMeta> get records => _records;
  Map<int, List<RecordMeta>> get parentOfChild => _parentOfChild;
  Map<int, List<RecordMeta>> get languageOfChild => _languageOfChild;

  int get lastId => _lastId;
  int get deletedCount => _deletedCount;
  int get deleteSize => _deletedSize;

  void setConfig(String dbPath, {required ChConfig config}) {
    dbFile = File(dbPath);
    _config = config;
  }

  Future<void> load() async {
    // if (!dbFile.existsSync()) {
    //   // မရှိရင်
    // }
    _writeRaf = await dbFile.open(mode: FileMode.append);
    _readRaf = await dbFile.open(mode: FileMode.read);

    await _buildIndex();
  }

  Future<void> _buildIndex() async {
    final size = await _readRaf.length();

    while (await _readRaf.position() < size) {
      final meta = await RecordMeta.read(_readRaf);
      if (meta.status == RecordStatus.active) {
        _records[meta.id] = meta;
        // print('lang: ${meta.langCode}');
        _languageOfChild.putIfAbsent(meta.langCode, () => []).add(meta);
        if (meta.parentId != -1) {
          _parentOfChild.putIfAbsent(meta.parentId, () => []).add(meta);
        }
      } else {
        //delete
        _deletedCount++;
        _deletedSize += meta.recordSize;
      }
      // last id
      if (meta.id > _lastId) _lastId = meta.id;
    }
  }

  Future<void> add(ChapterRecord record, {bool callFlush = true}) async {
    final headerOffset = await record.write(_writeRaf);
    _records[record.id] = RecordMeta.createFromRecord(record, headerOffset);

    _reIndexRecords();

    // 5. Disk ထဲ တကယ်ရောက်အောင် Flush လုပ်မယ်
    if (callFlush) {
      await _writeRaf.flush();
    }
  }

  Future<void> deleteById(int id, {bool callFlush = true}) async {
    final record = records[id];

    if (record == null) {
      throw Exception('ID: `$id` Not Found!!!');
    }

    await record.deleteMark(_writeRaf);

    // 4. RAM ပေါ်ကနေ ဖယ်ထုတ်မယ်
    _records.remove(id);

    _reIndexRecords();

    // 5. Disk ထဲ တကယ်ရောက်အောင် Flush လုပ်မယ်
    if (callFlush) {
      await _writeRaf.flush();
    }
  }

  Future<void> deleteMultiple(List<int> ids) async {
    for (final id in ids) {
      try {
        // Flush မလုပ်သေးဘဲ Mark တွေပဲ လိုက်လုပ်သွားမယ်
        await deleteById(id, callFlush: false);
      } catch (e) {
        print('Error deleting ID $id: $e');
      }
    }
    // အားလုံးပြီးမှ Disk ထဲ တခါတည်း ရေးချမယ်
    await _writeRaf.flush();

    _reIndexRecords();
  }

  void _reIndexRecords() {
    _languageOfChild.clear();
    _parentOfChild.clear();

    for (var meta in _records.values) {
      _languageOfChild.putIfAbsent(meta.langCode, () => []).add(meta);
      if (meta.parentId != -1) {
        _parentOfChild.putIfAbsent(meta.parentId, () => []).add(meta);
      }
    }
  }

  Iterable<RecordMeta> getAll({int? parentId, int? langCode}) {
    if (parentId != null) {
      return _parentOfChild[parentId] ?? [];
    }
    if (langCode != null) {
      return _languageOfChild[langCode] ?? [];
    }
    return _records.values;
  }

  int get generatedId {
    _lastId++;
    return _lastId;
  }

  bool get isOpened {
    try {
      _readRaf;
      _writeRaf;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> writeFlush() async {
    if (!isOpened) return;
    await _writeRaf.flush();
  }

  Future<void> close() async {
    await _writeRaf.close();
    await _readRaf.close();
  }

  ///// ----- Compact -----

  Future<void> mabyCompact() async {
    if (_config.willCompact(deletedCount, deleteSize)) {
      await compact();
    }
  }

  Future<void> compact() async {
    if (deletedCount == 0) return;

    final compactFile = File('${dbFile.path}.cpf');
    final compactRaf = await compactFile.open(mode: FileMode.write);

    final buffSize = 1024 * 1024;
    final buff = Uint8List(buffSize);
    for (var meta in _records.values) {
      // go header offset
      await _readRaf.setPosition(meta.offset);

      int bytesToRead = meta.recordSize;

      while (bytesToRead > 0) {
        final currentReadSize = bytesToRead > buffSize ? buffSize : bytesToRead;
        //ဖတ်လိုက်မယ်
        final bytesRead = await _readRaf.readInto(buff, 0, currentReadSize);

        await compactRaf.writeFrom(buff, 0, bytesRead);
        //read ပြီးသားကို နှုန်ချထားမယ်
        bytesToRead -= currentReadSize;
      }
    }

    await compactRaf.close();
    await _readRaf.close();
    await _writeRaf.close();

    await dbFile.rename('${dbFile.path}.bk');
    await compactFile.rename(dbFile.path);

    await reSetConfig();

    await load();
  }

  Future<void> reSetConfig() async {
    _lastId = 0;
    _deletedCount = 0;
    _deletedSize = 0;
    _languageOfChild.clear();
    _records.clear();
    _parentOfChild.clear();
  }
}
