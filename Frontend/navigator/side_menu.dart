import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/home.dart';
import 'package:to_doc/screens/chat/dm_list.dart';
import 'package:to_doc/screens/myPost.dart';
import 'package:to_doc/screens/user_edit.dart';

class SideMenu extends StatelessWidget {
  final String? usernick, email;
  const SideMenu(this.usernick, this.email ,{super.key});



  @override
  Widget build(BuildContext context) {
    return Drawer(
      //backgroundColor: ,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usernick.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
            accountEmail: Text(email.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
            decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(1), bottomRight: Radius.circular(1)),
            

            ),
            //onDetailsPressed: (){},
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('홈'),
            onTap: (){Get.to(()=> Home());},
            trailing: Icon(Icons.navigate_next),

          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('내 프로필'),
            onTap: (){
              Get.to(()=> UserEdit());
            },
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text('포스트'),
            onTap: (){Get.to(()=> MypostTemp());},
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.chat_outlined),
            title: Text('DM 리스트'),
            onTap: (){Get.to(()=>DMList(controller: ChatController(),));},
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('설정'),
            onTap: (){},
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
}