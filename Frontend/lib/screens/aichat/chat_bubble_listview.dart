import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import '../../chat_object.dart';

class ChatMaker extends StatelessWidget {
  final scrollController;
  final List<ChatObject> messageList;

  const ChatMaker({super.key, required this.scrollController, required this.messageList});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            shrinkWrap: true,
            reverse: true,
            itemCount: messageList.length,
            controller: scrollController,
            itemBuilder: (_, int index) {
              return Bubble(
                borderColor: Colors.white,
                shadowColor: Colors.white,
                nip: messageList[messageList.length-index-1].role == 'user' ? BubbleNip.rightBottom : BubbleNip.leftBottom,
                alignment: messageList[messageList.length-index-1].role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                color: messageList[messageList.length-index-1].role == 'user'
                    ? Color.fromRGBO(225, 234, 205, 100)
                    : Color.fromRGBO(244, 242, 248, 20) ,

                margin: const BubbleEdges.only(top: 8),
                child: Text('${messageList[messageList.length-index-1].content}',
                  style: TextStyle(fontSize: 15,
                      color: messageList[messageList.length-index-1].role == 'user'
                          ? Colors.black
                          : Colors.black),),
              );
            }),
      ),
    );
  }
}


