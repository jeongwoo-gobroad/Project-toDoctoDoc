import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:to_doc/controllers/register_controller.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/home.dart';
import 'package:to_doc/navigation_menu.dart';
import 'package:to_doc/provider/auth_provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final authProvider = Get.put(AuthProvider(dio: Dio()));
  final UserinfoController user = Get.find<UserinfoController>();
  final TextEditingController idController = TextEditingController(); //추후 수정
  final TextEditingController pwController = TextEditingController(); //추후 수정

  bool _autoLogin = true;

  //테스트용
  RegisterController registerController = Get.put(RegisterController());

  _submit(bool autologin) async{
    print('login test');

    //await registerController.dupidCheck(idController.text);
    Map result = await authProvider.login(
      idController.text,
      pwController.text,
      autologin, true,
    );
    if(result['success'] == true){
      print('test succ');
      Get.snackbar('Login', '로그인에 성공하였습니다.');
      user.getInfo();
      Get.offAll(()=> NavigationMenu(startScreen : 0));
    }
    else{
      Get.snackbar('Login', '로그인에 실패하였습니다.',
      backgroundColor: const Color.fromARGB(255, 217, 107, 99), barBlur: 100, boxShadows: List.filled(3, BoxShadow(blurRadius: BorderSide.strokeAlignOutside)), 
      colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                  ],
                ),
                const SizedBox(height: 40),
                // Login Form
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:Color(0xFF1D4044),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ID Field
                      TextField(
                        controller: idController,
                        decoration: InputDecoration(
                          hintText: '아이디를 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Password Field
                      TextField(
                        controller: pwController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('자동 로그인',style: TextStyle(fontSize:15),),
                          Checkbox(value: _autoLogin, onChanged: (bool? value) {
                            setState(() {
                              _autoLogin = value!;
                            });
                          }),
                        ],
                      ),


                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(

                          onPressed: () => _submit(_autoLogin),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 212, 212, 212),
                            foregroundColor: const Color.fromARGB(255, 35, 40, 35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              
                            ),
                          ),
                        ),
                      ),
                    ],),
                ),
              ],),
          ),
        ),
      ),
    );
  }
}
  