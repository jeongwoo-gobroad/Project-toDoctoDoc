import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_dio.dart';

class HospitalInformationController extends GetxController{
  var isLoading = true.obs;

  late String placeId;

  late Map<String,dynamic> hospital;
  late Map<String,dynamic> review;

  var isReviewExisted = false;
  var isMyReviewExisted = false;


  List<int> reviewRatingArr = [];


  Future<bool> getHospitalReview(String chatId) async {
    isLoading = true.obs;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/review/listing/$placeId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
      data: json.encode({
        '?isPremium' : '',
      })
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);

      /*
      if (data['content'] == null) {
        isReviewExisted.value = false;
        return true;
      }

      for (var review in data['content']) {

      TODO : 리뷰 정렬 및 총합 계산 (리뷰 별점 : 0~4)


      }
      */


      isLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }


}