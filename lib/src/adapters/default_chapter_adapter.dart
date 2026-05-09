import 'package:chapters_db/chapters_db.dart';
import 'package:chapters_db/src/models/default_chapter.dart';

class DefaultChapterAdapter extends ChAdapter<DefaultChapter> {
  @override
  int get adapterId => 0;

  @override
  int getLangCode(DefaultChapter value) {
    return value.languageCode;
  }

  @override
  int parentId(DefaultChapter value) {
    return value.parentId;
  }

  @override
  DefaultChapter fromMap(Map<String, dynamic> map) {
    return DefaultChapter.fromJson(map);
  }

  @override
  int getChapter(DefaultChapter value) {
    return value.chapterNumber;
  }

  @override
  int getId(DefaultChapter value) {
    return value.id;
  }

  @override
  String getTitle(DefaultChapter value) {
    return value.title;
  }

  @override
  Map<String, dynamic> toMap(DefaultChapter value) {
    return value.toJson();
  }
}
