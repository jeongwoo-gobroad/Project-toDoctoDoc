import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:to_doc/navigation_menu.dart';
import 'package:to_doc/screens/myPost.dart';
import 'package:to_doc/screens/user_edit.dart';

import '../auth/auth_secure.dart';
import '../screens/chat/dm_list.dart';
import '../screens/intro.dart';

class SideMenu extends StatelessWidget {
  final String? usernick, email;
  const SideMenu(this.usernick, this.email ,{super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      //backgroundColor: ,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usernick.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
            accountEmail: Text(email.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(1), bottomRight: Radius.circular(1)),
              color: Color.fromARGB(255, 225, 234, 205),

            ),
            //onDetailsPressed: (){},
          ),
          ListTile(
            leading: Icon(Icons.workspace_premium, color: Colors.yellow,),
            title: Text('프리미엄', style: TextStyle(color: Colors.yellow),),
            onTap: (){

            },
            trailing: Icon(Icons.navigate_next, color: Colors.yellow,),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('홈'),
            onTap: (){Get.to(()=> NavigationMenu());},
            trailing: Icon(Icons.navigate_next),

          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('계정 설정'),
            onTap: (){
              Get.to(()=> UserEdit());
            },
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text('내 게시물'),
            onTap: (){Get.to(()=> MypostTemp());},
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('큐레이팅 DM'),
            onTap: (){Get.to(()=>DMList());},
            trailing: Icon(Icons.navigate_next),
          ),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('설정'),
            onTap: (){},
            trailing: Icon(Icons.navigate_next),
          ),

          ListTile(
            leading: Icon(Icons.logout, color: Colors.red,),
            title: Text('로그아웃', style: TextStyle(color:Colors.red,)),
            onTap: (){
              _logoutAlert(context);
              },
            trailing: Icon(Icons.navigate_next, color: Colors.red,),
          ),

        ],
      ),
    );
  }

  void onLogout() async {
    SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());
    await storage.deleteEveryToken();
    Get.offAll(()=> Intro());
  }

  Future<void> _logoutAlert(BuildContext context) async {
    return showDialog<void>(
      //다이얼로그 위젯 소환
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                Text('정말 로그아웃하시겠습니까?', style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('로그아웃', style: TextStyle(color:Colors.white),),
              onPressed: () {
                onLogout();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
            ),
            TextButton(
              child: Text('취소', style: TextStyle(color: Colors.grey),),
              onPressed: () {
                Navigator.of(context).pop();
              },
              //style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey)),
            ),
          ],
        );
      },
    );
  }
}