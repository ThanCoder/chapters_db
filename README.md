# Chapters Database

## Example

```dart
final db = ChaptersDB.getInstance();
await db.open('chapters.db');

db.registerAdapterNotExists<Chapter>(ChapterAdapter());

final box = db.getBox<Chapter>();

// await box.deleteAll([1,2]);

for (var ch in await box.getAll()) {
    print(ch);
}
print('deletedCount: ${db.deletedCount}');
print('deleteSize: ${db.deleteSize}');

await db.close();
```

## Adapter

```dart
class ChapterAdapter extends ChAdapter<Chapter> {
  @override
  Chapter fromMap(Map<String, dynamic> map) {
    return Chapter.fromJson(map);
  }

  @override
  int get getAdapterId => 1; //adaper unique field id

  @override
  int getLangCode(Chapter value) {
    return value.languageCode; //custom language code
  }

  @override
  int getChapter(Chapter value) {
    return value.chapter; //chapter number
  }

  @override
  int getId(Chapter value) {
    return value.id; //chapter auto id
  }

  @override
  Map<String, dynamic> toMap(Chapter value) {
    return value.toJson();
  }
}
```

## Chapter Type

```dart
class Chapter {
  final int id; //auto id
  final String title;
  final int chapter;
  final int languageCode;
  final String body;

  const Chapter({
    this.id = -1,
    required this.title,
    required this.chapter,
    required this.languageCode,
    required this.body,
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

```
