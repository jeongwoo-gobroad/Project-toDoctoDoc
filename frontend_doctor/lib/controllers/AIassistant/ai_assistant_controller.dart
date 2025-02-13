import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_detail_model.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_model.dart';




class AiAssistantController extends GetxController {
  var isLoading = true.obs;
  RxString summary = "".obs;

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
      summary.value = data['content'];
      assistantDailyLimit();
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
  

   bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  bool _isLimited(){
    if(patientTotal.value == dailyPatientLimit){
      return true;
    }
    else{
      return false;
    }
  }
  RxInt patientTotal = 0.obs;
  int dailyPatientLimit = 30;
  RxBool patientLimited = false.obs;

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
      patientLimited.value = false;
      final data = json.decode(response.data);
      print(data);
      DateTime serverDate = DateTime.parse(data['content']['dailyPatientStateSummationDate']).toLocal();
      print(serverDate);
      DateTime today = DateTime.now();

      if(!_isSameDay(serverDate, today)){
        patientTotal.value = 0;
      }else{
        patientTotal.value = data['content']['dailyPatientStateSummationCount'];
      }
      if(_isLimited()){
        patientLimited.value = true;
      
      }else{
        patientLimited.value = false;
      }
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