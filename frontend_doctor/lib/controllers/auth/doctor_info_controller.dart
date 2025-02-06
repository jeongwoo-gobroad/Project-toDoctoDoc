import 'package:dio/dio.dart';
import 'package:get/get.dart' as getter;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';

class DoctorInfoController extends getter.GetxController {
  getter.RxString id = "".obs;
  getter.RxString name = "".obs;
  getter.RxString email = "".obs;
  getter.RxString postcode = "".obs;
  getter.RxString detailAddress = "".obs;
  getter.RxString extraAddress = "".obs;
  getter.RxString address = "".obs;
  getter.RxString personalID = "".obs;
  getter.RxString phone = "".obs;
  getter.RxString profileImage = "".obs;


  final getter.RxBool isLoading = false.obs;
  getter.RxBool isPremium = false.obs;
  getter.RxDouble longitude = 0.0.obs;
  getter.RxDouble latitude = 0.0.obs;

  //RxString address = "".obs;
  
  Future<void> getInfo() async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    print('GETINFO----------------------------------------');

    final response = await dio.get(
      '${Apis.baseUrl}mapp/doctor/doctorInfo',
      options: Options(headers: {
        'Content-Type':'application/json',
        'accessToken':'true',
      },
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      id.value = data['content']['id'];
      name.value = data['content']['name'];
      email.value = data['content']['email'];
      personalID.value = data['content']['personalID'];
      phone.value = data['content']['phone'];
      postcode.value = data['content']['address']['postcode'];
      address.value = data['content']['address']['address'];
      detailAddress.value = data['content']['address']['detailAddress'];
      //extraAddress.value = data['content']['address']['extraAddress'];
      //isPremium.value = data['content']['isPremium'];
      latitude.value = data['content']['address']['latitude'];
      longitude.value = data['content']['address']['longitude'];

      print(data['content']['myProfileImage']);
      profileImage.value = data['content']['myProfileImage'];


      // print(address.value);
      // print(extraAddress.value);
      // print(email.value);
      // print(detailAddress.value);
      // print(id.value);
      // print(latitude.value);
      // print(longitude.value);

      //로컬 저장
      //await saveUserInfo(data);

    }
  }
  Future<void> saveUserInfo(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', data['content']['id']);
    await prefs.setString('email', data['content']['email']);
    await prefs.setString('usernick', data['content']['usernick']);
  }

  Future<bool> editInfo(String usernick, String email, String postcode, String address, String detailAddress, String extraAddress
  , String password, String password2) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    Map<String, dynamic> body = {
        'usernick': usernick,
        'email': email,
        'postcode': postcode,
        'address': address,
        'detailAddress': detailAddress,
        'extraAddress': extraAddress,
    };
    print(usernick+ " " + email+ " " + postcode+ " " + address+ " " + detailAddress+ " " + extraAddress+ " " + password + " " + password2 );

    if (password.isNotEmpty) {
        body['password'] = password;
        body['password2'] = password2;
    }

    final response = await dio.patch(
      '${Apis.baseUrl}mapp/editUserInfo',
      options: Options(headers: {
        'Content-Type':'application/json',
        'accessToken':'true',
      },),
      data: json.encode(body)
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.data}');

    if (response.statusCode == 200) {
      await getInfo();  // 새로운정보 가져오기
      return true;
    }
    return false;
  }

  Future<bool> uploadProfileImage(dynamic imageLink) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    print('upload---------------------------------------');
    print(imageLink);

    var formData = FormData.fromMap({'file': await MultipartFile.fromFile(imageLink)});

    print(formData);

    try {
      dio.options.maxRedirects.isFinite;

      final response = await dio.post(
          '${Apis.baseUrl}mapp/doctor/profile/upload',
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

}