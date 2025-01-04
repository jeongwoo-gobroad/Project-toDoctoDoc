import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class QueryController extends GetxController{
  var title = RxString("");
  var context = RxString("");
  var isLoading = false.obs;

  Future<void> sendQuery(String input) async{

    //로딩
    isLoading.value = true;

    //토큰? Access Token으로 접근하고 1회 실패하면 Refresh Token으로 접근하면 되고, Refresh Token으로 접근하면 헤더에 Access_Token에 Access Token을 담고 Refresh_token에 Refresh Token을 담아서 줌. 
    /* if token == null -> 로그인이 필요합니다. */

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if(token == null){

      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
    }


    final response = await http.post(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/query'),
      headers: {
        'Content-Type':'application/json',
        'authorization':'Bearer $token',
      },

      body: json.encode({

        'input': input,

      })

      
      
      
    );

    if(response.statusCode == 200){
      final data = json.decode(json.decode(response.body));
      
      title.value = data['content']['title'];
      context.value = data['content']['context'];
      // print(title);
      // print("\n");
      // print(context);
    }
    
    isLoading.value = false;
    
  }





}
/*
"error":false,"result":"ai_answer","content":{"title":"마음이 아파요","context":"걱정하지 않으셔도 됩니다. 마음이 아프실 때는 누구나 그런 감정을 느낄 수 있답니다. 그런 감정을 느끼는 것은 자연스러운 일이니, 자신을 탓하지 않으셨으면 해요. 마음이 아픈 순간은 결국 더 나은 내일을 위한 과정이기도 해요. 조금씩 자신을 돌보면서 긍정적인 생각을 해보시는 것도 좋을 것 같습니다. 언제든지 마음의 짐을 풀고 싶으실 때, 말씀해 주시면 함께 이야기 나눌 수 있고, 도움이 되어드릴 수 있을 거예요. 마음이 조금 더 편안해지길 바라겠습니다."}
 */