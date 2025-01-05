/// id usernick email address limits isPremium
/// userInfo, 로그인, 회원가입시 바로 저장, 수정시 다시 불러와야함
/// 
library;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserinfoController extends GetxController {
  var id = "".obs;
  var usernick = "".obs;
  var email = "".obs;
  //limit, isPremium 추후후


  Future<void> getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }

    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/userinfo'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(json.decode(response.body));
      print(data);
      id.value = data['content']['id'];
      usernick.value = data['content']['usernick'];
      email.value = data['content']['email'];
      print(id.value);
      //로컬 저장
      await saveUserInfo(data);

    }
  }
  Future<void> saveUserInfo(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', data['content']['id']);
    await prefs.setString('email', data['content']['email']);
    await prefs.setString('usernick', data['content']['usernick']);
    
  }
  // //load
  // Future<void> loadUserInfo() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.getString('id');
  //   await prefs.setString('userEmail', data['content']['email'] ?? '');
  //   await prefs.setString('userNick', data['content']['usernick'] ?? '');
    
  // }
}