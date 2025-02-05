import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../auth/auth_interceptor.dart';

class HospitalInformationController extends GetxController {
  var isLoading = true.obs;

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
  var breakTime = -1;
  var openTime = -1;


  Future<bool> getInfo() async{
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    //isLoading.value = true;

    try {
      final response = await dio.get(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/psyProfile/myPsyInfo',
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
        //breakTime = data['breakTime'];
        //openTime = data['openTime'];


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
    dio.interceptors.add(CustomInterceptor());

    //isLoading.value = true;

    try {
      final response = await dio.patch(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/psyProfile/myPsyInfo',
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


}
