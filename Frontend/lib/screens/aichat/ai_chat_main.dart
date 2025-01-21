import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/aboutpage.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/navigator/side_menu.dart';
import 'ai_chat_list.dart';
import '../../chat_object.dart';
import '../../controllers/aichat/aichat_controller.dart';

import 'ai_chat_list.dart';

class AichatMain extends StatefulWidget {
  const AichatMain({super.key});

  @override
  State<AichatMain> createState() => _AichatMain();
}
class _AichatMain extends State<AichatMain> {
  UserinfoController userinfoController = Get.find<UserinfoController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Obx(() => SideMenu(
          userinfoController.usernick.value,
          userinfoController.email.value
        )),

      appBar: AppBar(
        //centerTitle: true,
        title: InkWell(
          child: Text('Ai와 채팅',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
      ),

      body: AiChatList(),
    );
  }

}