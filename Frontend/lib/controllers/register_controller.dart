import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import '../auth/auth_dio.dart';

class RegisterController extends GetxController{
  final Dio dio;

  RegisterController({required this.dio});

  @override
  void onInit() {
    super.onInit();
    dio.interceptors.add(CustomInterceptor());
  }

   Future<Map<String, dynamic>> register(String id, String password, String password2, String nickname, String postcode
   ,String address, String detailAddress, String extraAddress, String email) async{

    String? _token;
    final url = Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/register');


    try{
      final response = await dio.post(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/register',
        options:
          Options(headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          'id' : id,
          'password' : password,
          'password2' : password2,
          'nickname' : nickname,
          'postcode': postcode,
          'address': address,
          'detailAddress' : detailAddress,
          'extraAddress' : extraAddress,
          'email' : email,
        }),
      );

      /*
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          
        },
        body: json.encode({
          'id' : id,
          'password' : password,
          'password2' : password2,
          'nickname' : nickname,
          'postcode': postcode,
          'address': address,
          'detailAddress' : detailAddress,
          'extraAddress' : extraAddress,
          'email' : email,
        }),
      );
       */
      
      
      print('register debug: $id $email $password $password2 $postcode $address $extraAddress $nickname');
      print('register response code ${response.statusCode}');
      print('register response code ${response.data}');
      
      if(response.statusCode == 200){

        final data = json.decode(response.data);

        _token = data['content']['token'];
        ///_refreshToken = data['content']['refreshToken'];
        ///
        print(_token); 

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);

        return{
          'success': true,
          'data': data,
        };
      }else{
        return{
          'success': false,
        };

      }
    }catch(e){
      print('Error!: $e');
      return{
        'success':false,
      };
    }
  } 


  Future<bool> dupidIDCheck(String userid) async {
    try {
      final response = await dio.post(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/dupidcheck',
        options:
          Options(headers: {
              'Content-Type': 'application/json',
            },
          ),
        data: json.encode({
          'userid': userid,
        }),
      );

      /*
      final response = await http.post(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/dupidcheck'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userid': userid,
        }),
      );
       */
     
      final data = json.decode(response.data);
      print('id responsecode: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (data['error'] == false) {
          print('아이디 중복 없음');
          return true; // 사용 가능한 ID
        } 
        else {
          Get.snackbar('Error', '서버 에러가 발생했습니다.');
          return false; // 서버 에러
        }
      } else if (response.statusCode == 402) {
        if (data['result'] == 'id_already_exists') {
          Get.snackbar('실패', '이미 존재하는 아이디입니다.');
          return false; 
        } else {
          Get.snackbar('Error', '서버 에러가 발생했습니다.');
          return false; 
        }
      } else {
        Get.snackbar('Error', '서버 에러가 발생했습니다. 코드: ${response.statusCode}');
        return false; 
      }
    } catch (e) {
      Get.snackbar('Error', '예외가 발생했습니다: $e');
      return false; 
    }
    //{error: true, result: id_already_exists, content: 이미 존재하는 아이디입니다.}
  }

  Future<bool> dupidEmailCheck(String email) async {
    try {
      final response = await dio.post(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/dupemailcheck',
        options:
          Options(headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          'email': email,
        }),
      );
      /*
      final response = await http.post(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/dupemailcheck'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      );
       */

      print('email responsecode: ${response.statusCode}');
      final data = json.decode(response.data);
      
      print(data);
      if (response.statusCode == 200) {
        if (data['error'] == false) { //성공공
          print('이메일 중복 없음');
          return true; 
        } 
        else {
          Get.snackbar('Error', '서버 에러가 발생했습니다.');
          return false; // 서버에러
        }
      } else if (response.statusCode == 402) {
        if (data['result'] == 'email_already_exists') {
          Get.snackbar('실패', '이미 존재하는 이메일입니다.');
          return false; 
        } else {
          Get.snackbar('Error', '서버 에러가 발생했습니다.');
          return false; 
        }
      } else {
        Get.snackbar('Error', '서버 에러가 발생했습니다. 코드: ${response.statusCode}');
        return false; 
      }
    } catch (e) {
      Get.snackbar('Error', '예외가 발생했습니다: $e');
      return false; 
    }
    
  }
}