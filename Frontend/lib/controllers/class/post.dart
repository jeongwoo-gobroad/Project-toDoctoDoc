class Post {
  String postId;
  String title;
  String details;
  String additionalMaterial;
  String createdAt;
  String editedAt;
  String tag;
  String userNick;
  String userId;
  bool isOwner;

  Post({
    required this.postId,
    required this.title,
    required this.details,
    required this.additionalMaterial,
    required this.createdAt,
    required this.editedAt,
    required this.tag,
    required this.userNick,
    required this.userId,
    required this.isOwner,
  });

  // JSON 데이터를 Post 객체로 변환
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postid'],
      title: json['title'],
      details: json['details'],
      additionalMaterial: json['additional_material'] ?? '',
      createdAt: json['createdAt'],
      editedAt: json['editedAt'],
      tag: json['tag'] ?? '',
      userNick: json['usernick'],
      userId: json['userid'],
      isOwner: json['isOwner'],
    );
  }
}
