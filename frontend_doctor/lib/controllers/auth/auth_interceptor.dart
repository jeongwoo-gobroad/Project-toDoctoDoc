import 'dart:convert';
import 'package:get/get.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_doc_for_doc/screen/auth/login_screen.dart';

import 'auth_secure.dart';

class Apis {
  // static const baseUrl = 'https://project-todoctodoc-10934714252.asia-northeast3.run.app/';
  static const baseUrl = 'http://jeongwoo-kim-web.myds.me:3000/'; // for developer's debug
  static const dmUrl =  'http://jeongwoo-kim-web.myds.me:5000/';
}

class CustomInterceptor extends Interceptor {
  static SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());
  List<ErrorInterceptorHandler> requestQueue = [];

  static Future<bool>? refreshTokenLock; // 동시성 제어를 위한 static변수

  @override void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final accessToken = await storage.readAccessToken();

      print('dio accessToken');
      print(accessToken);

      options.headers.addAll({
        'authorization': 'Bearer $accessToken',
      });
    } else if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');

      final refreshToken = await storage.readRefreshToken();

      options.headers.addAll({
        'authorization': 'Bearer $refreshToken',
      });
    }

    //print('test');
    super.onRequest(options, handler);
  }


  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('ERror');

    print(err.response?.statusCode);
    print(err.message);

    // 인증 오류가 발생했을 경우: AccessToken의 만료
    if (err.response?.statusCode == 419) {
      //final options = err.requestOptions;

      print('await');
      if (!await refreshLockFunc()) {
        print('ERROR');
        storage.deleteEveryToken();

        print('리프래시 토큰 오류');
        Get.snackbar('Error', '로그인이 만료되었습니다.');
        Get.off(()=> LoginPage());
        return;
      }

      print('Redo token authorization');
      final _accessToken = await storage.readAccessToken();

      final options = err.requestOptions;
      options.headers.addAll({'authorization' : 'Bearer $_accessToken'});

      Dio dio = Dio();
      final clonedRequest = await dio.fetch(options);
      return handler.resolve(clonedRequest);
    }
  }


  static Future<bool> refreshLockFunc() async {
    if (refreshTokenLock != null) {
      await refreshTokenLock;
      return true; // 이전 토큰 갱신 요청의 결과를 기다린 후, true 반환
    }

    await getNewToken();


    refreshTokenLock = getNewToken();


    return refreshTokenLock!.then((value) {
      refreshTokenLock = null;
      return value;
    }).catchError((error) {
      refreshTokenLock = null;
      return false;
    });
  }

  static  Future<bool> getNewToken() async {
    final refreshToken = await storage.readRefreshToken();

    var refreshDio = Dio();

    refreshDio.interceptors.clear();
    refreshDio.interceptors.add(InterceptorsWrapper(onError: (error, handler) async {
      // 다시 인증 오류가 발생했을 경우: RefreshToken의 만료
      if (error.response?.statusCode == 419) {
        // 기기의 자동 로그인 정보 삭제
        storage.deleteEveryToken();

        print('리프래시 토큰 오류');
        Get.snackbar('Error', '로그인이 만료되었습니다.');
        Get.off(()=> LoginPage());
      }
      return handler.next(error);
    }));


    print('wait refresh response');
    print(refreshToken);

    try {
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

        await storage.saveAccessToken(_accessToken);
        await storage.saveRefreshToken(_refreshToken);

        print('accessToken');
        print(data['content']['accessToken']);

        print('refreshToken');
        print(data['content']['refreshToken']);
        return true;
      }
      return true;
    } on DioException catch (e) {
      return false;
    }
  }
}