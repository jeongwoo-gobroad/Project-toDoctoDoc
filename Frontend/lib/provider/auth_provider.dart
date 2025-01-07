import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider extends ChangeNotifier{
  String? _token;



  Future<Map<String, dynamic>> login(String userid, String password) async{
    final url = Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/login');
    print(url);

    try{
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          
        },
        body: json.encode({
          'userid' : userid,
          'password' : password,
        }),
      );

      if(response.statusCode == 200){

        final data = json.decode(json.decode(response.body));
        //token, refreshToken
        // _token = data;
        _token = data['content']['token'];
        ///_refreshToken = data['content']['refreshToken'];
        ///
        print(_token); 
        // _token = data['content'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);


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