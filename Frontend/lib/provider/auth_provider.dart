import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../auth/auth_dio.dart';
import '../auth/auth_secure.dart';

class AuthProvider extends ChangeNotifier{
  SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());
  String? _token;
  String? _refreshToken;

  final Dio dio;

  AuthProvider({required this.dio});

  Future<Map<String, dynamic>> login(String userid, String password, bool autoLogin, bool firstLogin) async{

    try{
      final response = await dio.post(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/login',
        options:
          Options(headers: {
            'Content-Type': 'application/json',
          },),
        data: json.encode({
          'userid' : userid,
          'password' : password,
        }),
      );

      if(response.statusCode == 200){

        final data = json.decode(response.data);
        //token, refreshToken
        // _token = data;
        _token = data['content']['token'];
        _refreshToken = data['content']['refreshToken'];
        ///
        print(_token);
        print(_refreshToken);

        // _token = data['content'];


        await storage.saveAccessToken(_token!);
        await storage.saveRefreshToken(_refreshToken!);

        if (autoLogin && firstLogin) {
          await storage.userSave(userid, password);
        }


/*        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await prefs.setString('ref_token', _refreshToken!);*/


        notifyListeners();
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
//토큰 로드
  Future<void> loadToken() async{
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    notifyListeners();
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = '';
  }

}