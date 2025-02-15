import 'package:get/get.dart';

import 'package:dio/dio.dart';
import '../../auth/auth_dio.dart';

class AiChatDeleteController extends GetxController{
  var isLoading = false.obs;

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  Future<void> deleteOldChat(String chatId) async{
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);
    //로딩
    isLoading.value = true;

    print(chatId);

    final response = await dio.delete(
      '${Apis.baseUrl}mapp/aichat/delete/$chatId',
      options: Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
    );

    if(response.statusCode == 200){
      Get.snackbar('Success', '채팅을 삭제했습니다. ${response.statusCode})');
    }
    else {
      Get.snackbar('Error', '채팅을 삭제하지 못했습니다. ${response.statusCode})');
      return;
    }
    isLoading.value = false;
  }

}
