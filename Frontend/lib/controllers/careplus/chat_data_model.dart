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
  final String? user;
  final Doctor doctor;
  final DateTime date;
  final List<ChatMessage> chatList;
  final int? v;
  final int unreadMsg;

  ChatContent({
    required this.id,
    this.user,
    required this.doctor,
    required this.date,
    required this.chatList,
    this.v,
    required this.unreadMsg,
  });

  factory ChatContent.fromMap(Map<String, dynamic> map) {
    int tempunread = 0;
    if (map['unread'] != null) {
      tempunread = map['unread'];
    }

    return ChatContent(
      id: map['_id'].toString(),
      user: map['user']?.toString(),
      doctor: Doctor.fromMap(map['doctor'] as Map<String, dynamic>),
      date: DateTime.parse(map['date'] as String),
      chatList: (map['chatList'] as List?)
          ?.map((item) => ChatMessage.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      v: map['__v'],
      unreadMsg: tempunread,
    );
  }
}

// doctor.dart
class Doctor {
  final String? id;
  final String? name;

  Doctor({
    this.id,
    this.name,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['_id']?.toString(),
      name: map['name']?.toString(),
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
