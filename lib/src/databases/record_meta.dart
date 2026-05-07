import 'dart:io';
import 'dart:typed_data';

import 'package:chapters_db/src/databases/chapter_record.dart';

enum RecordStatus { delete, active }

class RecordMeta {
  final int offset;
  final int dataStartOffset;
  final int id;
  final int adapterId;
  final int parentId;
  final int langCode;
  final int chapter;
  final int dataSize;
  final int recordSize;
  final RecordStatus status;

  const RecordMeta({
    required this.offset,
    required this.dataStartOffset,
    required this.id,
    required this.adapterId,
    required this.parentId,
    required this.langCode,
    required this.chapter,
    required this.dataSize,
    required this.recordSize,
    required this.status,
  });

  factory RecordMeta.createFromRecord(ChapterRecord record, int offset) {
    return RecordMeta(
      offset: offset,
      dataStartOffset: ChapterRecord.headerSize + offset,
      id: record.id,
      adapterId: record.adapterId,
      parentId: record.parentId,
      langCode: record.langCode,
      chapter: record.chapter,
      dataSize: record.data.length,
      recordSize: ChapterRecord.headerSize + record.data.length,
      status: record.status,
    );
  }

  Future<Uint8List> readData(RandomAccessFile raf) async {
    await raf.setPosition(dataStartOffset);

    final data = await raf.read(dataSize);
    return data;
  }

  Future<void> deleteMark(RandomAccessFile raf) async {
    await raf.setPosition(offset);
    // delete
    await raf.writeByte(RecordStatus.delete.index);
    // 2. Pointer ကို အဆုံးကို ပြန်ပို့မယ် (နောက်ထပ် Append လုပ်မယ့်သူတွေအတွက်)
    final fileLength = await raf.length();
    await raf.setPosition(fileLength);
  }

  // ---- static ----

  static Future<RecordMeta> read(RandomAccessFile raf) async {
    final offset = await raf.position();

    final headerBytes = await raf.read(ChapterRecord.headerSize);
    if (headerBytes.length < ChapterRecord.headerSize) {
      throw Exception("Header missing");
    }

    final header = ByteData.sublistView(headerBytes);
    final flag = header.getUint8(0);
    final id = header.getInt64(1, Endian.big);
    final adapterId = header.getInt8(2);
    final parentId = header.getInt64(10, Endian.big);
    final langCode = header.getInt32(18, Endian.big);
    final chapter = header.getInt32(22, Endian.big);
    final dataSize = header.getInt32(26, Endian.big);

    final dataStartOffset = offset + ChapterRecord.headerSize;
    // skip data
    await raf.setPosition(dataStartOffset + dataSize);

    final recordSize = ChapterRecord.headerSize + dataSize;

    return RecordMeta(
      offset: offset,
      dataStartOffset: dataStartOffset,
      status: RecordStatus.values[flag],
      id: id,
      adapterId: adapterId,
      parentId: parentId,
      langCode: langCode,
      chapter: chapter,
      dataSize: dataSize,
      recordSize: recordSize,
    );
  }
}
