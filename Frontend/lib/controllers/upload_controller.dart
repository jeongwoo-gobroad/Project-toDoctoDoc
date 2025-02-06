import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../auth/auth_dio.dart';

class UploadController extends GetxController {
  var title = "".obs;
  var context = "".obs; // content 필드

  Future<bool> uploadResult(String title, String content, String additionalContent, String tags) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    var body = {
      'title': title,
      'content': content,
      'content_additional': additionalContent,
      'tags': tags,
    };


    // POST 요청 전송
    try {
      var response = await dio.post(
          '${Apis.baseUrl}mapp/upload',
          data: json.encode(body),
          options:
            Options(headers: {
              'Content-Type':'application/json',
              'accessToken': 'true',
            }),
          );

      if (response.statusCode == 200) {
        Get.snackbar("성공", "결과가 성공적으로 공유되었습니다!");
        return true;
      } else {
        Get.snackbar("오류", "결과 공유에 실패했습니다. 다시 시도해주세요.");
        return false;
      }
    } catch (e) {
      Get.snackbar("오류", "문제가 발생했습니다. 다시 시도해주세요.");
      return false;
    }
  }
}