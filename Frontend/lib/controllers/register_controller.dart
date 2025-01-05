import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends GetxController{
   Future<Map<String, dynamic>> register(String id, String password, String password2, String nickname, String postcode
   ,String address, String detailAddress, String extraAddress, String email) async{

    String? token;
    final url = Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/register');
    

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
          'nickname' : nickname,
          'postcode': postcode,
          'address': address,
          'detailAddress' : detailAddress,
          'extraAddress' : extraAddress,
          'email' : email,
        }),

        
      );

      print('response code ${response.statusCode}');


      if(response.statusCode == 200){

        final data = json.decode(json.decode(response.body));
        //token, refreshToken


        // _token = data;
       

        token = data['content']['token'];
        ///_refreshToken = data['content']['refreshToken'];
        ///
        print(token); 
        


        // _token = data['content'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token!);


        //notifyListeners();
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



}