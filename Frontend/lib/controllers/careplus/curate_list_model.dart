class CurateItem {
  final String id; //해당 큐레이팅 id (curateId)
  final List<String> posts;
  final List<String> aiChats;
  final List<dynamic> comments; //추후 수정필요
  final bool isNotRead;
  final bool isPublic;
  final List<String> ifNotPublicOpenedTo;
  final DateTime date;
  final DateTime createdAt;
  final String user;
  final String? deepCurate;
  final int? v;

  CurateItem({
    required this.id,
    required this.posts,
    required this.aiChats,
    required this.comments,
    required this.isNotRead,
    required this.isPublic,
    required this.ifNotPublicOpenedTo,
    required this.date,
    required this.createdAt,
    required this.user,
    this.deepCurate,
    this.v,
  });

  factory CurateItem.fromJson(Map<String, dynamic> json) {
    return CurateItem(
      id: json['_id'] as String,
      posts: (json['posts'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      aiChats: (json['ai_chats'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      comments: json['comments'] as List<dynamic>,
      isNotRead: json['isNotRead'] as bool,
      isPublic: json['isPublic'] as bool,
      ifNotPublicOpenedTo: (json['ifNotPublicOpenedTo'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] as String,
      deepCurate: json['deepCurate'] as String?,
      v: json['__v'] == null ? null : json['__v'] as int,
    );
  }

  CurateItem copyWith({bool? isPublic}) {
    return CurateItem(
      id: this.id,
      isPublic: isPublic ?? this.isPublic,
      aiChats: this.aiChats,
      comments: this.comments,
      createdAt: this.createdAt,
      date: this.date,
      ifNotPublicOpenedTo: this.ifNotPublicOpenedTo,
      isNotRead: this.isNotRead,
      posts: this.posts,
      user: this.user,
      deepCurate: this.deepCurate,
      v: this.v,
    );
  }
}

List<CurateItem> parseCurateContent(Map<String, dynamic> json) {
  return (json['content'] as List<dynamic>)
      .map((item) => CurateItem.fromJson(item as Map<String, dynamic>))
      .toList();
}