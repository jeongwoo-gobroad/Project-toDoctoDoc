import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/navigation_menu.dart';
import 'package:to_doc/provider/auth_provider.dart';



  

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final authProvider = Get.put(AuthProvider());

  final TextEditingController idController = TextEditingController(); //추후 수정
  final TextEditingController pwController = TextEditingController(); //추후 수정

  _submit() async{
    Map result = await authProvider.login(
      idController.text,
      pwController.text,
    );
    if(result['success'] == true){
      Get.offAll(()=> NavigationMenu());
    }
    else{
      Get.snackbar('Login', '로그인에 실패하였습니다.');
    }
  }
  
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: pwController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('로그인'),
            ),
            ElevatedButton(
              onPressed: (){}, 
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}