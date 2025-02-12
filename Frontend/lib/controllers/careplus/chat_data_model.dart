class ChatContent {
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String cid;
  final String profilePic;
  final bool isBanned;
  final Map<String, dynamic> recentChat;

  ChatContent({
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.cid,
    required this.isBanned,
    required this.recentChat,
    required this.profilePic
  });

  factory ChatContent.fromMap(dynamic map, Map<String, dynamic> temp) {
    return ChatContent(
      doctorId: map != null && map['doctorId'] != null ? map['doctorId'].toString() : '',
      doctorName: map != null && map['doctorName'] != null ? map['doctorName'].toString() : '',
      date: map != null && map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
      cid: map != null && map['cid'] != null ? map['cid'].toString() : '',
      isBanned: map != null && map['isBanned'] != null ? map['isBanned'] : false,
      recentChat: temp,
      profilePic: map != null && map['doctorProfilePictureLink'] != null ? map['doctorProfilePictureLink'].toString() : ''
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
