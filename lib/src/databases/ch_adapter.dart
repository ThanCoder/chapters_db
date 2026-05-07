import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

abstract class ChAdapter<T> {
  Map<String, dynamic> toMap(T value);
  T fromMap(Map<String, dynamic> map);

  int get getAdapterId;

  ///
  /// ### `-1` is Default
  ///
  int get getParentId => -1;
  int getId(T value);
  int getChapter(T value);

  ///
  ///### `0` is original language
  ///
  int getLangCode(T value) => 0;

  // auto id
  Map<String, dynamic> setId(int id, Map<String, dynamic> map) {
    map['id'] = id;
    return map;
  }

  String toJson(Map<String, dynamic> map) => jsonEncode(map);
  Map<String, dynamic> fromJson(String source) => jsonDecode(source);

  // encoder
  Uint8List encodeData(String jsonSource) =>
      Uint8List.fromList(gzip.encode(utf8.encode(jsonSource)));
  String decodeData(Uint8List dataBytes) => utf8.decode(zlib.decode(dataBytes));
}
