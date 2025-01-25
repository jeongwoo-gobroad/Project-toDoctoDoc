import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_controller.dart';
import 'package:to_doc_for_doc/navigators/navigation_menu.dart';

import '../../controllers/auth/auth_secure.dart';



  

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final AuthController authController = Get.put(AuthController(dio: Dio()));
  //final UserinfoController user = Get.find<UserinfoController>();
  final TextEditingController idController = TextEditingController(); 
  final TextEditingController pwController = TextEditingController();

  bool _autoLogin = false;

  /// 환자용 앱에서 INTRO 파트에서 사용되던 코드입니다 인트로 스크린 완성될 시 이동 바랍니다. ///
  final SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());
  bool awaitLogin = false;

  void autoLogin() async {
    awaitLogin = true;

    final userId = await storage.readUserId();
    final userPw = await storage.readUserPw();

    if (userId != null && userPw != null) {
      var result = await authController.login(userId, userPw, false, false);

      if (result == true) {
        awaitLogin = false;
        Get.offAll(()=> NavigationMenu());
      }
      else {
        Get.snackbar('자동 로그인 실패', '재로그인해주세요.');
      }
    }
    setState(() {
      awaitLogin = false;
    });
  }

  void initState() {
    super.initState();
    autoLogin();
  }
  /// /////////////////////////////////////////////////////////////////////////////// ///

  _submit(bool autologin) async{
    //await registerController.dupidCheck(idController.text);
    bool result = await authController.login(
      idController.text,
      pwController.text,
      true, autologin,
    );
    if(result == true){
      //Get.snackbar('Login', '로그인에 성공하였습니다.');
      //user.getInfo();
      Get.to(()=> NavigationMenu());
    }
    else{
      // //Get.snackbar('Login', '로그인에 실패하였습니다.',
      // backgroundColor: const Color.fromARGB(255, 217, 107, 99), barBlur: 100, boxShadows: List.filled(3, BoxShadow(blurRadius: BorderSide.strokeAlignOutside)), 
      // colorText: Colors.white);
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

                          onPressed: () {
                            _submit(_autoLogin);
                            },
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
  