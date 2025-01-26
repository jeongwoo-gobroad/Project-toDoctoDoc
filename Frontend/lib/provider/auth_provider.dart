import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_secure.dart';
import '../device_info.dart';

class AuthProvider extends ChangeNotifier{
  SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());

  String? _token;
  String? _refreshToken;
  String? _pushToken;

  final Dio dio;

  AuthProvider({required this.dio});

  Future<Map<String, dynamic>> login(String userid, String password, bool autoLogin, bool firstLogin) async{
    _pushToken = await storage.readPushToken();

    if (_pushToken == null) {
      FirebaseMessaging fbMsg = FirebaseMessaging.instance;
      String? fcmToken = await fbMsg.getToken(
          vapidKey: "BENM2B6kWL-_t2ATlZN2JXE2c4wn0JohHDLTuSUJC5hsKZF-aGUHeBKUW9PPHfukDtb18JLmn1n3yzTj2u5TpHg");
      print("fcm token revisited ---- : $fcmToken");

      storage.savePushToken(fcmToken!);
      _pushToken = fcmToken;
    }

    var deviceId = '';
    deviceId = await initPlatformState();

    print('AUTOLOGIN $autoLogin\nFIRSTLOGIN $firstLogin');
    print('PUSHTOKEN $_pushToken');
    print('DEVICE_ID $deviceId');

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
          'deviceId' : (autoLogin)? deviceId : null,
          'pushToken' : (autoLogin)? _pushToken : null,
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
    _pushToken = await storage.readPushToken();

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/login',
      options:
      Options(headers: {
        'Content-Type': 'application/json',
      },),
      data: json.encode({
        'pushToken' : _pushToken,
      }),
    );

    if (response.statusCode == 200) {
      await storage.deleteEveryToken();
    }
    else {
      print('Logout Err');
    }
  }

}