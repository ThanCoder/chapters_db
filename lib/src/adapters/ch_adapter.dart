import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chapters_db/src/databases/record_meta.dart';

abstract class ChAdapter<T> {
  Map<String, dynamic> toMap(T value);
  T fromMap(Map<String, dynamic> map);

  int get adapterId;

  ///
  /// ### `-1` is Default
  ///
  int parentId(T value) => -1;
  int getId(T value);
  int getChapter(T value);
  String getTitle(T value);

  ///
  ///### `0` is original language
  ///
  int getLangCode(T value) => 0;

  // auto id
  Map<String, dynamic> setId(int id, Map<String, dynamic> map) {
    map['id'] = id;
    return map;
  }

  // get chapter content
  Future<T> getContentData(RecordMeta meta, RandomAccessFile raf) async {
    final data = await meta.readData(raf);
    final map = fromJson(decodeData(data));
    return fromMap(setId(meta.id, map));
  }

  // to json
  String toJson(Map<String, dynamic> map) => jsonEncode(map);
  Map<String, dynamic> fromJson(String source) => jsonDecode(source);

  // encoder
  Uint8List encodeData(String jsonSource) =>
      Uint8List.fromList(gzip.encode(utf8.encode(jsonSource)));
  String decodeData(Uint8List dataBytes) => utf8.decode(zlib.decode(dataBytes));
}
