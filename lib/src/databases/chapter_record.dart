import 'dart:io';
import 'dart:typed_data';

import 'package:chapters_db/src/databases/record_meta.dart';

/// Add Record
class ChapterRecord {
  /// header() -> [status(1),id(8),adapterId(1),parentId(8),langCode(4),chapter(4),dataSize(4),titleSize(4)]
  static final headerSize = 34;

  final RecordStatus status;
  final int id;
  final int adapterId;
  final int parentId;
  final int langCode;
  final int chapter;
  final Uint8List title;
  final Uint8List data;

  const ChapterRecord({
    this.status = RecordStatus.active,
    this.id = -1,
    this.adapterId = -1,
    this.parentId = -1,
    this.langCode = 0,
    required this.title,
    required this.chapter,
    required this.data,
  });
  //header() -> [status(1),id(8),adapterId(1),parentId(8),langCode(4),chapter(4),dataSize(4),titleSize(4)]
  Future<int> write(RandomAccessFile raf) async {
    final offset = await raf.position();

    // print('write adapterId: $adapterId');

    final header = ByteData(headerSize);
    header.setUint8(0, status.index);
    header.setInt64(1, id, Endian.big);
    header.setInt8(9, adapterId);
    header.setInt64(10, parentId, Endian.big);
    header.setInt32(18, langCode, Endian.big);
    header.setInt32(22, chapter, Endian.big);
    header.setInt32(26, data.length, Endian.big);
    header.setInt32(30, title.length);

    final builder = BytesBuilder(copy: false);
    //add
    builder.add(header.buffer.asUint8List());
    builder.add(title);
    builder.add(data);

    await raf.writeFrom(builder.takeBytes());

    return offset;
  }
}
