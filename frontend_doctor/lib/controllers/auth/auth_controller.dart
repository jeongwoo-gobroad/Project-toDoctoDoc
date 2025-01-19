import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:to_doc_for_doc/controllers/auth/doctor_info_controller.dart';

class AuthController extends GetxController {
  String? _token;
  DoctorInfoController doctorInfoController = Get.put(DoctorInfoController());

  Future<bool> register(String id, String password, String password2, String name, String phone, String personalID, String doctorID, String postcode
   ,String address, String detailAddress, String extraAddress, String email) async{

    //personal id : 주민번호, doctorID : 의사 면허 번호

    String? _token;
    final url = Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/register');

    try{
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          
        },
        body: json.encode({
          'id' : id,
          'password' : password,
          'password2' : password2,
          'name' : name,
          'phone': phone,
          'personalID': personalID,
          'doctorID': doctorID,
          'postcode': postcode,
          'address': address,
          'detailAddress' : detailAddress,
          'extraAddress' : extraAddress,
          'email' : email,
        }),
      );
      //print('register debug: $id $email $password $password2 $postcode $address $extraAddress $nickname');
      print('register response code ${response.statusCode}');
      print('register response code ${response.body}');
      
      if(response.statusCode == 200){

        final data = json.decode(json.decode(response.body));

        _token = data['content']['token'];
        ///_refreshToken = data['content']['refreshToken'];
        ///
        print(_token); 

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);

        return true;
          
      }else{

        return false;
          
      }

      
    }catch(e){
      print('Error!: $e');
      return false;
    }

    

  } 


  Future<bool> login(String userid, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userid': userid,
          'password': password,
        }),
      );

      if(response.statusCode == 200){
        final data = json.decode(json.decode(response.body));

        print(data);

        _token = data['content']['token'];
        ///_refreshToken = data['content']['refreshToken'];
        ///
       
        Get.snackbar('Success', '로그인 성공');
        await doctorInfoController.getInfo();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);

        return true;
      }else if(response.statusCode ==601) {

        Get.snackbar('Failed', '현재 인증 절차 진행 중인 계정입니다.');
        return false;

      }else if(response.statusCode == 403){
        Get.snackbar('Failed', '등록된 유저가 없습니다.');
        return false;
      }
      else if(response.statusCode == 401){
        Get.snackbar('Failed', '서버 오류');
        return false;
      }
      else{
        Get.snackbar('Failed', '실패패');
        return false;
      }

    } catch (e) {
      Get.snackbar('Error', '예외가 발생했습니다: $e');
      return false;
    }


  }





  Future<bool> dupidIDCheck(String id) async {
    try {
      final response = await http.post(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/dupidcheck'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': id,
        }),
      );

      final data = json.decode(json.decode(response.body));
      print('id responsecode: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (data['error'] == false) {
          print('아이디 중복 없음');
          return true; // 사용 가능한 ID
        } else {
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
    
  }

  Future<bool> dupidEmailCheck(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/dupemailcheck'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      );

      print('email responsecode: ${response.statusCode}');
      final data = json.decode(json.decode(response.body));

      print(data);
      if (response.statusCode == 200) {
        if (data['error'] == false) {
          //성공공
          print('이메일 중복 없음');
          return true;
        } else {
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
