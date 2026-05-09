import 'dart:io';

import 'package:chapters_db/chapters_db.dart';
import 'package:chapters_db/src/databases/record_meta.dart';

class ChapterInfo<T> {
  final RandomAccessFile _readRaf;
  final RecordMeta _meta;
  final ChAdapter<T> _adapter;
  final int id;
  final int adapterId;
  final int parentId;
  final int langCode;
  final String title;
  final int chapterNumber;

  ChapterInfo({
    required RandomAccessFile readRaf,
    required RecordMeta meta,
    required ChAdapter<T> adapter,
    required this.id,
    required this.adapterId,
    required this.parentId,
    required this.langCode,
    required this.title,
    required this.chapterNumber,
  }) : _readRaf = readRaf,
       _meta = meta,
       _adapter = adapter;

  factory ChapterInfo.fromMeta(
    RecordMeta meta, {
    required RandomAccessFile readRaf,
    required ChAdapter<T> adapter,
  }) {
    return ChapterInfo<T>(
      readRaf: readRaf,
      meta: meta,
      adapter: adapter,
      id: meta.id,
      adapterId: meta.adapterId,
      parentId: meta.parentId,
      langCode: meta.langCode,
      title: meta.title,
      chapterNumber: meta.chapter,
    );
  }

  Future<T> getContent() async {
    return await _adapter.getContentData(_meta, _readRaf);
  }

  @override
  String toString() {
    return '''ChapterInfo(id: $id, adapterId: $adapterId, parentId: $parentId, langCode: $langCode, title: $title, chapterNumber: $chapterNumber)''';
  }
}
