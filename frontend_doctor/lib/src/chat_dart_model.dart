import 'dart:convert';

// chat_response.dart
class ChatResponse {
  final bool? error;
  final dynamic result;
  final List<ChatContent> content;

  ChatResponse({
    this.error,
    this.result,
    required this.content,
  });

  factory ChatResponse.fromJson(String jsonString) {
    final decodedJson = json.decode(jsonString);
    return ChatResponse.fromMap(decodedJson);
  }

  factory ChatResponse.fromMap(Map<String, dynamic> map) {
    return ChatResponse(
      error: map['error'],
      result: map['result'],
      content: (map['content'] as List?)
          ?.map((item) => ChatContent.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

// chat_content.dart
class ChatContent {
  final String id;
  final String? doctor;
  final User user;
  final DateTime date;
  final List<ChatMessage> chatList;
  final int? v;

  ChatContent({
    required this.id,
    this.doctor,
    required this.user,
    required this.date,
    required this.chatList,
    this.v,
  });

  factory ChatContent.fromMap(Map<String, dynamic> map) {
    return ChatContent(
      id: map['_id'].toString(),
      doctor: map['name']?.toString(),
      user: User.fromMap(map['user'] as Map<String, dynamic>),
      date: DateTime.parse(map['date'] as String),
      chatList: (map['chatList'] as List?)
          ?.map((item) => ChatMessage.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      v: map['__v'],
    );
  }
}

// doctor.dart
class User {
  final String? id;
  final String? name;

  User({
    this.id,
    this.name,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id']?.toString(),
      name: map['usernick']?.toString(),
    );
  }
}

// chat_message.dart
class ChatMessage {
  final String? role;
  final String? message;
  final String? id;

  ChatMessage({
    this.role,
    this.message,
    this.id,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      role: map['role']?.toString(),
      message: map['message']?.toString(),
      id: map['_id']?.toString(),
    );
  }
}
