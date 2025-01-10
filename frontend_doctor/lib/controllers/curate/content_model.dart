import 'dart:convert';

class ContentResponse {
  final bool error;
  final String result;
  final List<ContentItem> content;

  ContentResponse({
    required this.error,
    required this.result,
    required this.content,
  });

  // 이중 디코딩된 응답을 처리하는 팩토리 메서드
  factory ContentResponse.fromResponseBody(String responseBody) {
    // 첫 번째 디코딩
    final decodedOnce = json.decode(responseBody);
    // 두 번째 디코딩
    final decodedTwice = json.decode(decodedOnce);
    
    return ContentResponse.fromJson(decodedTwice);
  }

  factory ContentResponse.fromJson(Map<String, dynamic> json) {
    return ContentResponse(
      error: json['error'] ?? false,
      result: json['result'] ?? '',
      content: (json['content'] as List)
          .map((item) => ContentItem.fromJson(item))
          .toList(),
    );
  }
}

class ContentItem {
  final String id;
  final List<User> users;
  final List<dynamic> comments;
  final String date;
  final String createdAt;
  final bool isRead;

  ContentItem({
    required this.id,
    required this.users,
    required this.comments,
    required this.date,
    required this.createdAt,
    required this.isRead,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['_id'] ?? '',
      users: (json['user'] as List)
          .map((user) => User.fromJson(user))
          .toList(),
      comments: json['comments'] ?? [],
      date: (json['date']),
      createdAt: (json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}

class User {
  final String userNick;

  User({required this.userNick});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userNick: json['usernick'] ?? '',
    );
  }
}