import 'dart:convert';
import 'package:get/get.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../screens/intro.dart';

/*
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  //final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add();

  return dio;
});

 */

class CustomInterceptor extends Interceptor {

  @override void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // TODO: implement onRequest
    final prefs = await SharedPreferences.getInstance();

    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');
      final accessToken = prefs.getString('jwt_token');

      print('dio login');
      print(accessToken);

      options.headers.addAll({
        'authorization': 'Bearer $accessToken',
      });
    } else if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');

      final refreshToken = prefs.getString('ref_token');
      options.headers.addAll({
        'authorization': 'Bearer $refreshToken',
      });
    }

    //print('test');
    super.onRequest(options, handler);
  }


  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('jwt_token');
    final refreshToken = prefs.getString('ref_token');

    print('ERror');

    print(error.response?.statusCode);

    // 인증 오류가 발생했을 경우: AccessToken의 만료
    if (error.response?.statusCode == 419) {
      print('419');

      var refreshDio = Dio();

      refreshDio.interceptors.clear();
      refreshDio.interceptors
          .add(InterceptorsWrapper(onError: (error, handler) async {
        // 다시 인증 오류가 발생했을 경우: RefreshToken의 만료
        if (error.response?.statusCode == 419) {
          // 기기의 자동 로그인 정보 삭제

          await prefs.clear();


          print('리프래시 토큰 오류');
          Get.snackbar('Error', '로그인이 만료되었습니다.');
          Get.off(()=> Intro());

          // . . .
          // 로그인 만료 dialog 발생 후 로그인 페이지로 이동
          // . . .
        }
        return handler.next(error);
      }));


      print('wait refresh response');
      print(refreshToken);

      final refreshResponse = await refreshDio.post(
          'http://jeongwoo-kim-web.myds.me:3000/mapp/tokenRefresh',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $refreshToken',
          }
        )
      );

      print('refreshtoken');
      print(refreshResponse.statusCode);

      if (refreshResponse.statusCode == 200) {
        final data = json.decode(refreshResponse.data);

        print(data);

        final _accessToken = data['content']['accessToken'];
        final _refreshToken = data['content']['refreshToken'];

        await prefs.setString('jwt_token', _accessToken);
        await prefs.setString('ref_token', _refreshToken);

        print(data['content']['accessToken']);
        print(data['content']['refreshToken']);

        print('Redo token authorization');

        final options = error.requestOptions;
        options.headers.addAll({'authorization' : 'Bearer $_accessToken'});

        // 수행하지 못했던 API 요청 복사본 생성
        final clonedRequest = await refreshDio.fetch(options);

        // API 복사본으로 재요청
        return handler.resolve(clonedRequest);

      }

      print('ERR');

    }
  }
}