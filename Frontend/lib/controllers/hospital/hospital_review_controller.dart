import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_dio.dart';

class HospitalReviewController extends GetxController{
  var isLoading = true.obs;

  var isMyReviewExisted = false;
  late Map<String,dynamic> myReviews;

  Future<bool> postUserReview(String placeId, double rating, String review) async {
    isLoading = true.obs;

    print(placeId);
    print(rating);
    print(review);

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

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

  Future<bool> editUserReview(String reviewId, double rating, String review) async {
    isLoading = true.obs;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.post(
        '${Apis.baseUrl}mapp/review/edit/$reviewId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },),
        data: json.encode({
          'stars' : rating,
          'content' : review,
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

  Future<bool> getMyReviewList(String reviewId, double rating, String review) async {
    isLoading = true.obs;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

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
      print(data);

      // TODO MY REVIEW LIST


/*      if (data['content'] == null) {
        isMyReviewExisted = false;
        return true;
      }

      List<dynamic> myReviews = data['content'];

      print(myReviews);*/

      isLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }
}