class ChatObject {
  String content = '';
  String role = '';
  DateTime? createdAt;

  ChatObject({required this.content, required this.role, required this.createdAt});

  factory ChatObject.send({required message}) =>
      ChatObject(content: message, role: 'user', createdAt: DateTime.now());

}