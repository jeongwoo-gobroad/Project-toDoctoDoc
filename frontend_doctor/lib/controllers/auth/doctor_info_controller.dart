
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';

class DoctorInfoController extends GetxController {
  RxString id = "".obs;
  RxString name = "".obs;
  RxString email = "".obs;
  RxString postcode = "".obs;
  RxString detailAddress = "".obs;
  RxString extraAddress = "".obs;
  RxString address = "".obs;
  RxString personalID = "".obs;
  RxString phone = "".obs;
  final RxBool isLoading = false.obs;
  RxBool isPremium = false.obs;
  RxDouble longitude = 0.0.obs;
  RxDouble latitude = 0.0.obs;

  final Dio dio;

  DoctorInfoController({required this.dio});

  @override
  void onInit() {
    super.onInit();
    dio.interceptors.add(CustomInterceptor());
  }
  
  //RxString address = "".obs;
  
  Future<void> getInfo() async {
/*    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }*/

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/doctorInfo',
      options: Options(headers: {
        'Content-Type':'application/json',
        'accessToken':'true',
      },
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      id.value = data['content']['id'];
      name.value = data['content']['name'];
      email.value = data['content']['email'];
      personalID.value = data['content']['personalID'];
      phone.value = data['content']['phone'];
      postcode.value = data['content']['address']['postcode'];
      address.value = data['content']['address']['address'];
      detailAddress.value = data['content']['address']['detailAddress'];
      //extraAddress.value = data['content']['address']['extraAddress'];
      //isPremium.value = data['content']['isPremium'];
      latitude.value = data['content']['address']['latitude'];
      longitude.value = data['content']['address']['longitude'];

      // print(address.value);
      // print(extraAddress.value);
      // print(email.value);
      // print(detailAddress.value);
      // print(id.value);
      // print(latitude.value);
      // print(longitude.value);

      //로컬 저장
      //await saveUserInfo(data);

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
/*    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    isLoading.value = true;

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return false;
    }*/

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
      'http://jeongwoo-kim-web.myds.me:3000/mapp/editUserInfo',
      options: Options(headers: {
        'Content-Type':'application/json',
        'accessToken':'true',
      },),
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