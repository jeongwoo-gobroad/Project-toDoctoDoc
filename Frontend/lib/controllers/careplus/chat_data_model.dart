// chat_response.dart
/*class ChatResponse {
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
}*/

// chat_content.dart
import 'dart:convert';

class ChatContent {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final DateTime date;
  final int unreadChat;
  final recentChat;

  ChatContent({
    required this.chatId,
    required this.unreadChat,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.recentChat
  });

  factory ChatContent.fromMap(Map<String, dynamic> map) {
    return ChatContent(
      chatId: map['cid'].toString(),
      doctorName: map['doctorName'],
      doctorId: map['doctorId'],
      date: DateTime.parse(map['date'] as String),
      unreadChat: (map['unreadChat'] == -1) ? 0 : map['unreadChat'],
      recentChat: json.decode(map['recentChat']),
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
