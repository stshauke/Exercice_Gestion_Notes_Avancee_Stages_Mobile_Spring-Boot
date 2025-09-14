class Note {
  int id;
  String title;
  String contentMd;
  bool isPublic;

  Note({
    required this.id,
    required this.title,
    required this.contentMd,
    this.isPublic = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      contentMd: json['contentMd'],
      isPublic: (json['visibility'] ?? 'PRIVATE') == 'PUBLIC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'contentMd': contentMd,
      'visibility': isPublic ? 'PUBLIC' : 'PRIVATE',
    };
  }
}
