import 'package:flutter/material.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:get/get.dart';
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    //final UserinfoController userinfoController = Get.put(UserinfoController());
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Obx(
            //   (){
            //     if(userinfoController.usernick.value == null){
            //       return const CircularProgressIndicator();
            //     }else{
                  

            //     }
            //   }
            // )



          ],
        ),
      )


    );
  }
}