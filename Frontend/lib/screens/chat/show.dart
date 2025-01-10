import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/screens/chat/tempcontroller.dart';

import 'chat_list.dart';

class ChatShow extends StatefulWidget {
  const ChatShow({super.key});

  @override
  State<ChatShow> createState() => _ChatShowState();
}

class _ChatShowState extends State<ChatShow> {
  final TempController chatController = Get.put(TempController());
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatController.scrollController = _scrollController;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    
    chatController.sendMessage(text);
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
              controller: _scrollController,
              itemCount: chatController.messages.length,
              itemBuilder: (context, index) {
                return ChatListItem(chatController.messages[index]);
              },
            )),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _handleSubmit,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmit(_textEditingController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}