import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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

    print('test');
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


          print('리프래시 토큰 오류');

          // . . .
          // 로그인 만료 dialog 발생 후 로그인 페이지로 이동
          // . . .
        }
        return handler.next(error);
      }));


      print('refresh token authorization');

      final options = error.requestOptions;
      options.headers.addAll({'authorization' : 'Bearer $refreshToken'});

      // 수행하지 못했던 API 요청 복사본 생성
      final clonedRequest = await refreshDio.fetch(options);

      // API 복사본으로 재요청
      return handler.resolve(clonedRequest);
    }
  }
}