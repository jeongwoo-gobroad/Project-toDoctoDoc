import 'package:get/get.dart';
import 'chat_model.dart';
import 'package:flutter/material.dart';

class TempController extends GetxController {
  final messages = <ChatModel>[].obs;
  ScrollController? scrollController;

  void sendMessage(String content) {
    messages.add(
      ChatModel(
        content: content,
        createdAt: DateTime.now(),
      ),
    );
    
    // 스크롤을 최하단으로
    scrollController?.animateTo(
      scrollController!.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}