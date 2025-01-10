class ChatModel {
  final String content;
  final DateTime createdAt;
  final bool isMe;

  ChatModel({
    required this.content,
    required this.createdAt,
    this.isMe = true,
  });
}