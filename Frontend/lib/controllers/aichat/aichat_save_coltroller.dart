import 'package:get/get.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import '../../auth/auth_dio.dart';

class AiChatSaveController extends GetxController{
  var isLoading = false.obs;

  Future<void> saveChat(String chatId) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());
    print(chatId);

    try {
      final response = await dio.post(
        '${Apis.baseUrl}mapp/aichat/save',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accessToken': 'true',
          },
        ),
        data: json.encode({'chatid': chatId,}),
      );

      //print('response code ${response.statusCode}');

      if (response.statusCode == 200) {
        print('saved');
        Get.snackbar('Success', '채팅을 저장했습니다. ${response.statusCode})');
      }
      else {
        Get.snackbar('Error', '채팅을 저장하지 못했습니다. ${response.statusCode})');
        return;
      }
      isLoading.value = false;
    } catch (e) {
      Get.snackbar("오류", "문제가 발생했습니다. 다시 시도해주세요.");
      return;
    }
  }
}
