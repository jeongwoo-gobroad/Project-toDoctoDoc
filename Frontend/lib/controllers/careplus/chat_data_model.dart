class ChatContent {
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String cid;
  final bool isBanned;
  final Map<String, dynamic> recentChat;

  ChatContent({
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.cid,
    required this.isBanned,
    required this.recentChat,
  });

  factory ChatContent.fromMap(map, temp) {
    return ChatContent(
      doctorId: map['doctorId'].toString() ?? '',
      doctorName: map['doctorName'].toString() ?? '',
      date: DateTime.parse(map['date'] as String) ?? DateTime.now(),
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
