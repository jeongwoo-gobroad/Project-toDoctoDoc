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
    try {
      final decodedOnce = json.decode(responseBody);
      //final decodedTwice = json.decode(decodedOnce);
      return ContentResponse(
        error: decodedOnce['error'] ?? false,
        result: decodedOnce['result'] ?? '',
        content: (decodedOnce['content'] as List)
            .map((item) => ContentItem.fromJson(item))
            .toList(),
      );
    } catch (e) {
      print('Parsing error: $e');
      return ContentResponse(
        error: true,
        result: 'parsing_error',
        content: [],
      );
    }
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
    id: json['_id']?.toString() ?? '',
    users: (json['user'] as List?)
            ?.map((user) => User.fromJson(user))
            .toList()
        ?? [],
    comments: json['comments'] ?? [],
    date: json['date']?.toString() ?? '',
    createdAt: json['createdAt']?.toString() ?? '',
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