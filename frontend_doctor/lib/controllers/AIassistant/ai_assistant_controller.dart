import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';

class AiAssistantController extends GetxController {
  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  var isLoading = true.obs;
  RxString summary      = "".obs;
  RxString dailySummary = "저장된 AI 요약이 없습니다.".obs;

  RxInt dailySumCount = 0.obs;
  int dailySumLimit = 5;


  RxBool isDailySumExist = false.obs;
  RxBool isDailySumRemain = false.obs;
  Map<String, dynamic> dailySumMap = {};

  void loadDailySummary() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('summaryTime');

    if (savedDate != null) {
      if (DateFormat.yM().format(DateTime.now()) == savedDate) {
        final tempMap = prefs.getString('dailySummary');

        if (tempMap != null) {
          isDailySumExist.value = true;
          dailySumMap = json.decode(tempMap);
        }
      }
    }
    else {
      dailySummary.value = '저장된 AI 요약이 없습니다.';
    }
  }

  Future<bool> detailsSummary(String pid) async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

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
    dio.interceptors.add(customInterceptor);

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
        dailySumCount.value = data['content']['dailySummationCount'];
      }

      if (dailySumCount.value == dailySumLimit) {
        isDailySumRemain.value = false;
      }
      else {
        isDailySumRemain.value = true;
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

  Future<bool> dailySummation() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.post(
      '${Apis.baseUrl}mapp/v2/doctor/aiAssistant/dailySummation',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);


      dailySumMap = data['content'];



      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('summaryTime', DateFormat.yM().format(DateTime.now()));
      await prefs.setString('dailySummary', json.encode(dailySumMap));

      isDailySumExist.value = true;
      assistantDailyLimit();
      //isLoading.value = false;
      return true;
    }
    else if (response.statusCode == 201){
      //Get.snackbar('오류', '오늘은 약속이 존재하지 않습니다.');



      isLoading.value = false;
      return false;
    }
    else {
      isLoading.value = false;
      return false;
    }
  }
}