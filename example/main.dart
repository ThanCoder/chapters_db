import 'package:chapters_db/chapters_db.dart';

void main() async {
  final db = ChaptersDB.getInstance();

  //register adapter
  db.registerAdapterNotExists<Chapter>(ChapterAdapter());
  // Initialize the database
  await db.open('chapters.db');

  // await db.compact();

  final box = db.getDefaultBox();
  final cBox = db.getBox<Chapter>();

  // await box.deleteById(1);
  await box.deleteById(2);

  // await cBox.deleteAll([1,2,5]);

  await box.add(
    DefaultChapter(
      title: 'one 0',
      chapterNumber: 1,
      body: 'default chapter one',
    ),
  );
  await box.add(
    DefaultChapter(
      title: 'two 0',
      chapterNumber: 2,
      body: 'default chapter two',
    ),
  );

  await cBox.add(
    Chapter(title: 'one', chapter: 1, body: 'default chapter one'),
  );
  await cBox.add(
    Chapter(title: 'two', chapter: 2, body: 'default chapter two'),
  );

  print('default box 0');
  for (var ch in await box.getAll()) {
    print(ch);
    print('data: ${await ch.getContent()}');
  }
  print('custom box 1');
  for (var ch in await cBox.getAll()) {
    print(ch);
    print('data: ${await ch.getContent()}');
  }
  print('deletedCount: ${db.deletedCount}');
  print('deleteSize: ${db.deleteSize}');

  await db.close();
}

class ChapterAdapter extends ChAdapter<Chapter> {
  @override
  Chapter fromMap(Map<String, dynamic> map) {
    return Chapter.fromJson(map);
  }

  @override
  int get adapterId => 1;

  @override
  int getLangCode(Chapter value) {
    return value.languageCode;
  }

  @override
  int getChapter(Chapter value) {
    return value.chapter;
  }

  @override
  int getId(Chapter value) {
    return value.id;
  }

  @override
  Map<String, dynamic> toMap(Chapter value) {
    return value.toJson();
  }

  @override
  String getTitle(Chapter value) {
    return value.title;
  }
}

class Chapter {
  final int id;
  final String title;
  final int chapter;
  final int languageCode;
  final String body;

  const Chapter({
    this.id = -1,
    required this.title,
    required this.chapter,
    required this.body,
    this.languageCode = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chapter': chapter,
      'languageCode': languageCode,
      'body': body,
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      chapter: json['chapter'],
      languageCode: json['languageCode'],
      body: json['body'],
    );
  }

  @override
  String toString() {
    return '''Chapter(id: $id, title: $title, chapter: $chapter, languageCode: $languageCode, body: $body)''';
  }
}
