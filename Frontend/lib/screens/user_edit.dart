import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
class UserEdit extends StatefulWidget {
  const UserEdit({super.key});
  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  final UserinfoController userController = Get.put(UserinfoController());
  final _nameController = TextEditingController();

  _submit() async {
    bool result = await userController.editInfo(/**수정 정보들들 */);
    @override
    void initState() {
      super.initState();
      
    }
  }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('프로필 수정'),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            TextFormField(
              
              //~
              controller: _nameController,
            ),
            // 버튼
            ElevatedButton(
              onPressed: _submit,
              child: const Text('저장'),
            ),
          ],
        ),
      );
    }

  
}