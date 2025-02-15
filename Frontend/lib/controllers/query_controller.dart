import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:dio/dio.dart';
import '../auth/auth_dio.dart';

class QueryController extends GetxController {

  var title = RxString("");
  var context = RxString("");
  var isLoading = false.obs;
  String? nickname;
  RxBool isLimited = false.obs;

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();


  Future<void> sendQuery(String input) async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final prefs = await SharedPreferences.getInstance();
    nickname = prefs.getString('usernick');

    final response = await dio.post('${Apis.baseUrl}mapp/query',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },
      ),
      data: json.encode({
        'input': input,
      })
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      isLimited = false.obs;
      final data = json.decode(response.data);
      title.value = data['content']['title'];
      context.value = data['content']['context'];
      // print(title);
      // print("\n");
      // print(context);
    }

    isLoading.value = false;
  }
  

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  bool _isLimited(){
    if(query.value == userTotal.value){
      return true;
    }
    else{
      return false;
    }
  }
  RxInt query = 0.obs;
  RxInt userTotal = 0.obs;
  RxString userDate = "".obs;
  

  Future<void> queryLimit() async {
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final prefs = await SharedPreferences.getInstance();

    final response = await dio.get(
      '${Apis.baseUrl}mapp/limits/query',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },
      ),
    );

    if (response.statusCode == 200) {
      isLimited.value = false;
      final data = json.decode(response.data);

      print(data);
      query.value = data['content']['query'];

      DateTime serverDate = DateTime.parse(data['content']['userDate']);
      DateTime today = DateTime.now();
      // print(serverDate);
      // print(today);

      if (!_isSameDay(serverDate, today)) {
        userTotal.value = 0;
      } else {
        print('같은 날짜');
        userTotal.value = data['content']['userTotal'];
      }
      if(_isLimited()){
        isLimited.value = true;
      }
      else{
        isLimited.value = false;
      }
      userDate.value = data['content']['userDate'];

      print('query: ${query}, userTotal: ${userTotal}, userDate: ${userDate}');
    }
  }
}
/*
"error":false,"result":"ai_answer","content":{"title":"마음이 아파요","context":"걱정하지 않으셔도 됩니다. 마음이 아프실 때는 누구나 그런 감정을 느낄 수 있답니다. 그런 감정을 느끼는 것은 자연스러운 일이니, 자신을 탓하지 않으셨으면 해요. 마음이 아픈 순간은 결국 더 나은 내일을 위한 과정이기도 해요. 조금씩 자신을 돌보면서 긍정적인 생각을 해보시는 것도 좋을 것 같습니다. 언제든지 마음의 짐을 풀고 싶으실 때, 말씀해 주시면 함께 이야기 나눌 수 있고, 도움이 되어드릴 수 있을 거예요. 마음이 조금 더 편안해지길 바라겠습니다."}
 */
