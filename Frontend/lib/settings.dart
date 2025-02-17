import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/screens/graph_tag_list.dart';
import 'package:to_doc/screens/user_edit.dart';
import 'package:to_doc/withdrawal_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserinfoController userController = Get.find<UserinfoController>();
  final _themeColor = Color.fromARGB(255, 225, 234, 205);
  final _accentColor = Color.fromARGB(255, 80, 110, 80);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정',
            style: TextStyle(
                
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        elevation: 0,
      ),
      //backgroundColor: _themeColor,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            _buildSectionTitle('그래프보드 설정'),

            ListTile(
            leading: Icon(Icons.block_outlined),
            title: Text('차단된 태그 목록',
                style: TextStyle(fontSize: 16)),
            trailing: Icon(Icons.arrow_forward_ios,
              size: 18),
            onTap: () {
              Get.to(()=> GraphTagList());
              
            
            
            },
            contentPadding: EdgeInsets.zero,
          ),
           SizedBox(height: 20),
            _buildSectionTitle('계정 관리'),
            ListTile(
              title: Text(
                '탈퇴하기',
                style: TextStyle(fontSize: 16, color: Colors.grey,),

              ),
              //trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.red),
              onTap: () {
                Get.to(()=> WithdrawalScreen());
              },
              contentPadding: EdgeInsets.zero,
            ),
           
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: TextStyle(
              //color: _accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProfileCard() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: (){Get.to(()=>UserEdit());},
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: _accentColor, size: 30),
            ),
             SizedBox(width: 16),

            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                   '${userController.usernick}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '내 정보 수정하기',
                  style: TextStyle(
                    fontSize: 14,
                    color: _accentColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    
  );
}

  
}