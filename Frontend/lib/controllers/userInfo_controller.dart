import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_dio.dart';

class UserinfoController extends GetxController {
  RxString uid = "".obs;
  RxString id = "".obs;
  RxString usernick = "".obs;
  RxString email = "".obs;
  RxString postcode = "".obs;
  RxString detailAddress = "".obs;
  RxString extraAddress = "".obs;
  RxString address = "".obs;
  final RxBool isLoading = false.obs;
  RxBool isPremium = false.obs;
  RxDouble longitude = 0.0.obs;
  RxDouble latitude = 0.0.obs;
  //RxString address = "".obs;
 /*error: false, result: info, content: {_id: 67763d058b0c374bed083641, id: test1234, usernick: jun, email: j123@21, address: {postcode: 41196, address: 대구 동구 경대로 2, detailAddress: 1, extraAddress:  (신암동), longitude: 128.612188721856, latitude: 35.8819379527752, _id: 67763d058b0c374bed083642}, limits: {dailyRequestDate: 2025-01-02T07:15:17.044Z, dailyRequestCount: 4, dailyChatDate: 2025-01-03T06:27:50.340Z, dailyChatCount: 1, _id: 67763d058b0c374bed083643}, isPremium: true}} */

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  Future<void> getInfo() async {
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.get(
      '${Apis.baseUrl}mapp/userinfo',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      )
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);

      print('UserINfo');
      print(data);
      uid.value = data['content']['_id'];
      id.value = data['content']['id'];
      usernick.value = data['content']['usernick'];
      email.value = data['content']['email'];
      postcode.value = data['content']['address']['postcode'].toString();
      address.value = data['content']['address']['address'];
      detailAddress.value = data['content']['address']['detailAddress'];
      extraAddress.value = data['content']['address']['extraAddress'];
      isPremium.value = data['content']['isPremium'];
      latitude.value = data['content']['address']['latitude'];
      longitude.value = data['content']['address']['longitude'];

      // print(address.value);
      // print(extraAddress.value);
      // print(email.value);
      // print(detailAddress.value);
      // print(id.value);
      // print(latitude.value);
      // print(longitude.value);
      print(uid.value);
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
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

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

    final response = await dio.patch(
      '${Apis.baseUrl}mapp/editUserInfo',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
      data: json.encode(body)
    );


    print('Response status: ${response.statusCode}');
    print('Response body: ${response.data}');
    if (response.statusCode == 200) {
      await getInfo();  // 새로운정보 가져오기
      return true;
    }
    return false;
  }


  
  
}