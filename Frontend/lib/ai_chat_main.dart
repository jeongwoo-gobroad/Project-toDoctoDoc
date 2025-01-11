import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/aboutpage.dart';
import 'ai_chat_screen.dart';
import 'ai_chat_list.dart';
import 'chat_object.dart';
import 'controllers/aichat_controller.dart';

import 'ai_chat_list.dart';

class AichatMain extends StatefulWidget {
  const AichatMain({super.key});

  @override
  State<AichatMain> createState() => _AichatMain();
}
class _AichatMain extends State<AichatMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.chat_bubble_outline_rounded),

      ),

      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
          onTap: () {
            /*to about page*/
            Get.to(() => Aboutpage());
          },
          child: Text('Ai와 채팅',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        actions: [
        ],
      ),

      body: AiChatList(),

      /*
      Center(




        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Icon(Icons.chat_rounded, size: 100,),
              Text(
                'Ai 챗봇',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),

              ),
              SizedBox(height: 50),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      foregroundColor: const Color.fromARGB(255, 51, 51, 51),
                      minimumSize: const Size(double.infinity, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                  onPressed: (){
                    Get.to(()=> AiChatSub(isNewChat : true, chatId : '', messageList: [],));
                    },

                  child: Text('시작하기', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                  ),
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    foregroundColor: const Color.fromARGB(255, 51, 51, 51),
                    minimumSize: const Size(double.infinity, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                ),
                onPressed: (){
                  Get.to(()=> AiChatList());
                  },
                child: Text('채팅 목록', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),),
              ),

            ],
          ),
        )


       */

      //),
    );
  }

}