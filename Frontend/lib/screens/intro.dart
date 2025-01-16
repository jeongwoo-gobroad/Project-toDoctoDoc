import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_secure.dart';
import 'package:to_doc/auth/login_page.dart';
import 'package:to_doc/auth/register_page.dart';
import 'package:to_doc/home.dart';

import '../provider/auth_provider.dart';



class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final authProvider = Get.put(AuthProvider(dio: Dio()));
  final SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());


  void autoLogin() async {
    final userId = await storage.readUserId();
    final userPw = await storage.readUserPw();
    
    if (userId != null && userPw != null) {
      var result = await authProvider.login(userId, userPw, false, false);

      if (result['success'] == true) {
        Get.off(()=> Home());
      }
    }
    else {

    }
  }


  @override
  void initState() {
    super.initState();
    //autoLogin();
    _animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    //페이드인
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    //애니메이션시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              
              child: FadeTransition(
                opacity: _animation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('asset/images/logo.jpeg',width: 300, height: 300),
                    const SizedBox(height: 20),
                    const Text(
                      '당신 곁의 상담사',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '누구나 감기에 걸리듯 마음 또한 아플 수 있습니다.\n 편하게 털어놓으세요.',
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 212, 212, 212),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    foregroundColor: const Color.fromARGB(255, 58, 68, 58),
                    minimumSize: const Size(double.infinity, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    )
                  ),
                  onPressed: (){
                    Get.to(()=> RegisterPage());
                    },
                  child: Text('시작하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  ),
                

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 계정이 있나요?'),
                    TextButton(
                      style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 58, 68, 58),

                      ),
                      onPressed: () => {Get.to(()=> LoginPage())},
                      child: Text('로그인',style: TextStyle(fontWeight: FontWeight.bold,),)
                    )

                  ],
                )
              ],
            ),
          
          )
        ],
      ),



    );
  }
}
