import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chapters_db/src/databases/record_meta.dart';

///Chapter Adapter For Extends Sub Class
abstract class ChAdapter<T> {
  ///T to Map
  Map<String, dynamic> toMap(T value);

  /// Map from T
  T fromMap(Map<String, dynamic> map);

  ///register adapter id for binary db
  int get adapterId;

  ///
  /// ### `-1` is Default
  ///
  int parentId(T value) => -1;

  ///id for binary db
  int getId(T value);

  ///chapter number field
  int getChapter(T value);

  ///title field
  String getTitle(T value);

  ///
  ///### `0` is original language
  ///
  int getLangCode(T value) => 0;

  /// auto id
  Map<String, dynamic> setId(int id, Map<String, dynamic> map) {
    map['id'] = id;
    return map;
  }

  /// get chapter content
  Future<T> getContentData(RecordMeta meta, RandomAccessFile raf) async {
    final data = await meta.readData(raf);
    final map = fromJson(decodeData(data));
    return fromMap(setId(meta.id, map));
  }

  /// to json
  String toJson(Map<String, dynamic> map) => jsonEncode(map);

  /// json from map
  Map<String, dynamic> fromJson(String source) => jsonDecode(source);

  /// encoder
  Uint8List encodeData(String jsonSource) =>
      Uint8List.fromList(gzip.encode(utf8.encode(jsonSource)));

  /// decoder
  String decodeData(Uint8List dataBytes) => utf8.decode(gzip.decode(dataBytes));
}
