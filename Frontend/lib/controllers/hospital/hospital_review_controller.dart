import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_dio.dart';

class HospitalReviewController extends GetxController{
  var isLoading = true.obs;
  var isReviewLoading = true.obs;

  var isMyReviewExisted = false;
  late List<dynamic> myReview;


  var starsNum = List<int>.filled(6, 0);
  var reviews;

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  Future<bool> postUserReview(String placeId, double rating, String review) async {
    isLoading = true.obs;

    print(placeId);
    print(rating);
    print(review);

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.post(
        '${Apis.baseUrl}mapp/review/write',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },),
        data: json.encode({
          'pid' : placeId,
          'stars' : rating,
          'content' : review,
        })
    );

    if (response.statusCode == 200) {
      print('SUCCESS POST');

      isLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> editUserReview(String pid, String reviewId, double rating, String review) async {
    isLoading = true.obs;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.patch(
        '${Apis.baseUrl}mapp/review/edit/$reviewId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },),
        data: json.encode({
          'stars' : rating,
          'content' : review,
          'pid' : pid,
        })
    );

    if (response.statusCode == 200) {
      print('SUCCESS EDITED');

      isLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }


  Future<bool> getHospitalReviewList(String pid) async {
    isReviewLoading = true.obs;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.get(
      '${Apis.baseUrl}mapp/review/listing/$pid',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.data);

      print(data);
      reviews = data['content']['reviews'];

      starsNum = List<int>.filled(6, 0);
      for (var review in reviews) {
        print(review);
        starsNum[review['stars']]++;
      }

      isReviewLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> deleteMyReview(String reviewId) async {
    isReviewLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.delete(
      '${Apis.baseUrl}mapp/review/delete/$reviewId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      print('SUCCESS DELETE');

      myReview.removeWhere((review)=>review['_id'] == 'reviewId');

      isReviewLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }


  Future<bool> getMyReviewList() async {
    isReviewLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.get(
      '${Apis.baseUrl}mapp/review/myReviews',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      print('SUCCESS GET');
      final data = json.decode(response.data);

      print('MYREVIEW');

      myReview = data['content']['reviews'];
      print(myReview);

      isReviewLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }
}