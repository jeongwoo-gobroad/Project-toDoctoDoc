class ChatContent {
  final String userId;
  final String userName;
  final DateTime date;
  final String cid;
  final bool isBanned;
  final Map<String, dynamic> recentChat;

  ChatContent({
    required this.userId,
    required this.userName,
    required this.date,
    required this.cid,
    required this.isBanned,
    required this.recentChat,
  });

  factory ChatContent.fromMap(map, temp) {
    return ChatContent(
      userId: map['userId'].toString(),
      userName: map['userName'].toString(),
      date: DateTime.parse(map['date'] as String),
      cid: map['cid'].toString(),
      isBanned: map['isBanned'] ?? false,
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
