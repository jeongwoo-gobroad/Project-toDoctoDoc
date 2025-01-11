import 'package:flutter/material.dart';
import 'chat_model.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;
  const ChatListItem(this.chat, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${chat.createdAt.hour}:${chat.createdAt.minute}',
          style: const TextStyle(color: Colors.grey),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text( 
            chat.content,
            style: const TextStyle(color: Colors.white),
          ),
          
        ),
      ],
    );
  }
}