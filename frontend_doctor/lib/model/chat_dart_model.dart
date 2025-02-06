class ChatContent {
  final String chatId;
  final String userName;
  final String userId;
  final DateTime date;
  final int unreadChat;
  final recentChat;

  ChatContent({
    required this.chatId,
    required this.unreadChat,
    required this.userId,
    required this.userName,
    required this.date,
    required this.recentChat
  });

  factory ChatContent.fromMap(Map<String, dynamic> map) {
    return ChatContent(
      chatId: map['cid'].toString(),
      userName: map['userName'],
      userId: map['userId'],
      date: DateTime.parse(map['date'] as String),
      unreadChat: (map['unreadChat'] == -1) ? 0 : map['unreadChat'],
      recentChat: map['recentChat'],
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
