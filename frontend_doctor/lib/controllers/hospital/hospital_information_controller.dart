import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getter;
import '../auth/auth_interceptor.dart';

class HospitalInformationController extends getter.GetxController {
  CustomInterceptor customInterceptor = getter.Get.find<CustomInterceptor>();

  var isLoading = true.obs;
  var isReviewLoading = true.obs;

  var name = '';
  var pid = '';
  bool isPremiumPsy = false;
  Map<String, dynamic> address = {'postcode': 42271,
    'detailAddress': '',
    'address': '',
    'extraAddress': '',
    'longitude': '',
    'latitude': '',
    '_id': ''
  };
  var phone = '';
  var stars;
  var psyProfileImage = [];
  var breakTime = '';
  var openTime = '';

  var starsNum = List<int>.filled(6, 0);
  var reviews; /* = <Map<String, dynamic>>[];*/


  Future<bool> getInfo() async{
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    try {
      final response = await dio.get(
        '${Apis.baseUrl}mapp/doctor/psyProfile/myPsyInfo',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');

        var data = json.decode(response.data);
        print(data);

        name = data['content']['name'];
        pid = data['content']['_id'];
        isPremiumPsy = data['content']['isPremiumPsy'];
        address = data['content']['address'];
        phone = data['content']['phone'];
        stars = data['content']['stars'];
        psyProfileImage = data['content']['psyProfileImage'];
        breakTime = data['breakTime'] ?? 'XX:XX/XX:XX';
        openTime = data['openTime'] ?? 'XX:XX/XX:XX';

        isLoading.value = false;
        return true;

      } else {
        return false;
      }
    } catch (error) {
      print('An error occurred: $error');
      return false;
    }
  }


  Future<bool> editMyHospitalInformation(String name, String address, String phone, String openTime, String breakTime) async{
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    try {
      final response = await dio.patch(
        '${Apis.baseUrl}mapp/doctor/psyProfile/myPsyInfo',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },),
        data : json.encode({
          'name' : name,
          'address' : address,
          'phone' : phone,
          'openTime' : openTime,
          'breakTime' : breakTime,
        }),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');

        isLoading.value = false;
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('An error occurred: $error');
      return false;
    }
  }

  Future<bool> uploadImage(dynamic imageLink) async {
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    print('upload---------------------------------------');
    print(imageLink);

    var formData = FormData.fromMap({'files': await MultipartFile.fromFile(imageLink)});

    try {
      dio.options.maxRedirects.isFinite;

      final response = await dio.post(
          '${Apis.baseUrl}mapp/doctor/psyProfile/upload/$pid',
          options: Options(headers: {
            'Content-Type': 'multipart/form-data',
            'accessToken': 'true',
          },),
          data: formData
      );
      if (response.statusCode == 200) {
        print('성공적으로 업로드했습니다');
        return true;
      }
      else {
        print('ERR');
      }
      return response.data;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> deleteImage(String imageName) async {
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    print('delete--------------------------------------');
    print(imageName);

    try {
      final response = await dio.delete(
          '${Apis.baseUrl}mapp/doctor/psyProfile/delete/$imageName',
          options: Options(headers: {
            'Content-Type':'application/json',
            'accessToken': 'true',
          },),
          data: json.encode({
            'psyId' : pid,
          }),
      );

      if (response.statusCode == 200) {
        print('성공적으로 삭제했습니다');
        return true;
      }
      else {
        print('ERR');
      }
      return response.data;
    } catch (e) {
      print(e);
    }
    return false;
  }


  Future<bool> getReviewList() async {
    isReviewLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    try {
      final response = await dio.get(
        '${Apis.baseUrl}mapp/doctor/review/list',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.data);
        //print(data);

        reviews = data['content']['reviews'];

        starsNum = List<int>.filled(6, 0);
        for (var review in reviews) {
          print(review);
          starsNum[review['stars']]++;
        }
        isReviewLoading.value = false;
        return true;
      }
      else {
        print('ERR');
      }
      return response.data;
    } catch (e) {
      print(e);
    }
    return false;
  }
}
