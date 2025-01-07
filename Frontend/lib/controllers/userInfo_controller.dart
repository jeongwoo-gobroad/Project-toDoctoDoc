/**
 * id usernick email address limits isPremium
 * userInfo, 로그인, 회원가입시 바로 저장, 수정시 다시 불러와야함
 * 
 */
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserinfoController extends GetxController {
  RxString id = "".obs;
  RxString usernick = "".obs;
  RxString email = "".obs;
  RxString postcode = "".obs;
  RxString detailAddress = "".obs;
  RxString extraAddress = "".obs;
  RxString address = "".obs;
  final RxBool isLoading = false.obs;
  RxBool isPremium = false.obs;
  //RxString address = "".obs;
 /*error: false, result: info, content: {_id: 67763d058b0c374bed083641, id: test1234, usernick: jun, email: j123@21, address: {postcode: 41196, address: 대구 동구 경대로 2, detailAddress: 1, extraAddress:  (신암동), longitude: 128.612188721856, latitude: 35.8819379527752, _id: 67763d058b0c374bed083642}, limits: {dailyRequestDate: 2025-01-02T07:15:17.044Z, dailyRequestCount: 4, dailyChatDate: 2025-01-03T06:27:50.340Z, dailyChatCount: 1, _id: 67763d058b0c374bed083643}, isPremium: true}} */
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
      postcode.value = data['content']['address']['postcode'].toString();
      address.value = data['content']['address']['address'];
      detailAddress.value = data['content']['address']['detailAddress'];
      extraAddress.value = data['content']['address']['extraAddress'];
      isPremium.value = data['content']['isPremium'];

      print(address.value);
      print(extraAddress.value);
      print(email.value);
      print(detailAddress.value);
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


  Future<bool> editInfo(String usernick, String email, String postcode, String address, String detailAddress, String extraAddress
  , String password, String password2) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    isLoading.value = true;

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return false;
    }
    Map<String, dynamic> body = {
        'usernick': usernick,
        'email': email,
        'postcode': postcode,
        'address': address,
        'detailAddress': detailAddress,
        'extraAddress': extraAddress,
    };
    print(usernick+ " " + email+ " " + postcode+ " " + address+ " " + detailAddress+ " " + extraAddress+ " " + password + " " + password2 );

    if (password.isNotEmpty) {
        body['password'] = password;
        body['password2'] = password2;
    }

    final response = await http.patch(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/editUserInfo'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: json.encode(body)
      
    );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    if (response.statusCode == 200) {
    
        
        
          await getInfo();  // 새로운정보 가져오기
          return true;
        
         
    } 
    
    return false;
  
  }
  
}