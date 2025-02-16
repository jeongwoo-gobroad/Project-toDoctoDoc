import 'package:get/get.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/auth_dio.dart';

class AiChatController extends GetxController{
  var chatId = '';
  var firstChat = '';

  var isLoading = false.obs;

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  Future<void> getNewChat() async{
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);
    isLoading.value = true;

    final response = await dio.get(
      '${Apis.baseUrl}mapp/aichat/new',
      options : Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },
      )
    );

    if(response.statusCode == 200){
      final data = json.decode(response.data);
      print(data);

      chatId = data['content']['chatid'];
      firstChat = data['content']['startingMessage'];
    }
    else {
      Get.snackbar('Error', '채팅을 생성하지 못했습니다. ${response.statusCode})');
      return;
    }
    isLoading.value = false;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  bool _isLimited(){
    if(chats.value == userTotal.value){
      return true;
    }
    else{
      return false;
    }
  }

  RxBool isLimited = false.obs;
  RxInt chats = 0.obs;
  RxInt userTotal = 0.obs;
  RxString userDate = "".obs;
  RxBool isLoadingLimit = false.obs;

  Future<void> chatLimit() async {
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    isLoadingLimit.value = true;

    final response = await dio.get(
      '${Apis.baseUrl}mapp/limits/chats',
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

      print('CHAT LIMIT $data');
      chats.value = data['content']['chats'];

      DateTime serverDate = DateTime.parse(data['content']['userDate']).toLocal();
      DateTime today = DateTime.now();
      print(serverDate);
      print(today);
      userTotal.value = data['content']['userTotal'];
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

      print('chats: ${chats}, userTotal: ${userTotal}, userDate: ${userDate}');
      isLoadingLimit.value = false;
    }
    isLoadingLimit.value = false;
  }
}
