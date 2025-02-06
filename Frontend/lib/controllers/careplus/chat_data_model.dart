class ChatContent {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final DateTime date;
  final int unreadChat;
  final Map<String, dynamic> recentChat;

  ChatContent({
    required this.chatId,
    required this.unreadChat,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.recentChat
  });

  factory ChatContent.fromMap(map, temp) {
    return ChatContent(
      chatId: map['cid'].toString(),
      doctorName: map['doctorName'],
      doctorId: map['doctorId'],
      date: DateTime.parse(map['date'] as String),
      unreadChat: (map['unreadChat'] == -1) ? 0 : map['unreadChat'],
      recentChat: temp,
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
