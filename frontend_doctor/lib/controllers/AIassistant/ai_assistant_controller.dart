import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_detail_model.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_model.dart';




class AiAssistantController extends GetxController {
  var isLoading = true.obs;
 

  Future<bool> detailsSummary(String pid) async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.post(
      '${Apis.baseUrl}mapp/v2/doctor/aiAssistant/detailSummation',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
      data: json.encode({
          'memoId' : pid,
          
      })
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      
      isLoading.value = false;
      return true;
    }
    else if(response.statusCode == 201){
      isLoading.value = false;
      return false;
    }
    else{
      isLoading.value = false;
      return false;
    }
  }
  
  Future<bool> assistantDailyLimit() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/v2/doctor/aiAssistant/dailyLimit',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
      
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      
      isLoading.value = false;
      return true;
    }
    else if(response.statusCode == 201){
      isLoading.value = false;
      return false;
    }
    else{
      isLoading.value = false;
      return false;
    }
  }
 
}