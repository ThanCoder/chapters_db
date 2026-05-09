class DefaultChapter {
  final int id;
  final String title;
  final int chapterNumber;
  final int languageCode;
  final int parentId;
  final String body;
  final Map<String, dynamic>? extras;

  const DefaultChapter({
    required this.title,
    required this.chapterNumber,
    required this.body,
    this.languageCode = 0,
    this.id = -1,
    this.extras,
    this.parentId = -1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'chapterNumber': chapterNumber,
      'languageCode': languageCode,
      'body': body,
      if (extras != null) 'extras': extras,
    };
  }

  factory DefaultChapter.fromJson(Map<String, dynamic> json) {
    return DefaultChapter(
      id: json['id'] ?? -1,
      parentId: json['parentId'] ?? -1,
      title: json['title'],
      chapterNumber: json['chapterNumber'] ?? 0,
      languageCode: json['languageCode'] ?? 0,
      body: json['body'],
      extras: json['extras'],
    );
  }
}
