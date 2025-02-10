import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';
import 'package:to_doc_for_doc/controllers/curate/curate_detail_model.dart';
import 'content_model.dart';

class CurateController extends GetxController {
  Rx<CurateDetail?> curateDetail = Rx<CurateDetail?>(null);
  var isLoading      = true.obs;
  var forHomeLoading = true.obs;
  RxBool isPremium   = false.obs;

  var CurateList = <Map<String, dynamic>>[].obs;
  var chatList   = <Map<String, dynamic>>[].obs;
  var comments   = <Map<String, dynamic>>[].obs;
  var posts      = <Map<String, dynamic>>[].obs;

  RxString filterStatus = RxString('all');
  RxString sortOrder = RxString('desc');

  var curateItems = <ContentItem>[].obs;

  List<ContentItem> get sortedAndFilteredItems {
    final tempList = [...filteredItems];
    
    if (sortOrder.value == 'desc') {
      tempList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      tempList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return tempList;
  } 
  List<ContentItem> get filteredItems {
    switch (filterStatus.value) {
      case 'read':
        return curateItems.where((item) => item.isRead).toList();
      case 'unread':
        return curateItems.where((item) => !item.isRead).toList();
      default:
        return curateItems;
    }
  }

  Future<bool> getCurateInfo(String radius) async{
    forHomeLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    try {
      final response = await dio.get(
        '${Apis.baseUrl}mapp/doctor/curate?radius=$radius',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data);
        print(data);

        final contentResponse = ContentResponse.fromResponseBody(response.data);
        curateItems.value = contentResponse.content;

        //print(curateItems);
        

        // if(data is Map<String,dynamic> && data['content']['list'] is List){
        // List<dynamic> contentList = data['content']['list'];
        forHomeLoading.value = false;
        return true;

      } else {

        return false;
      }

    } catch (error) {
      print('An error occurred: $error');
      return false;
    }
  }

  Future<void> addComment(String id, String comment) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    //isLoading.value = true;
    final response = await dio.post(
      '${Apis.baseUrl}mapp/doctor/curate/comment/$id',
      options: Options(headers: {
        'Content-Type':'application/json',
        'accessToken':'true',
      },),
      data: json.encode({
          'comment': comment,
      }),
    );

    if (response.statusCode == 200) {
      Get.snackbar('Success', '댓글을 남겼습니다.');
      await getCurateDetails(id);
      await getCurateInfo('5'); //추후에 5가아닌 radius인자로로
      refresh();
    }
    else{
      Get.snackbar('Failed', '댓글을 남기지 못했습니다.');
    }
  }
  Future<void> commentModify(String comment_id, String detail_id, String updatedComment) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    //isLoading.value = true;
    final response = await dio.patch(
      '${Apis.baseUrl}mapp/doctor/curate/commentModify/$comment_id',
      options: Options(headers: {
        'Content-Type':'application/json',
        'accessToken':'true',
      },),
      data: json.encode({
          'comment': updatedComment,
      }),
    );

    if (response.statusCode == 200) {
      Get.snackbar('Success', '댓글이 수정되었습니다.');
      await getCurateDetails(detail_id);
      refresh();
    }
    else if(response.statusCode == 401) {
      Get.snackbar('Failed', '본인의 댓글이 아닙니다.');
    }
    else if(response.statusCode == 403){
      Get.snackbar('Failed', '에러 발생');
    }
  }
  Future<void> commentDelete(String comment_id, String detail_id) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    // try {
    //isLoading.value = true;
    final response = await dio.delete(
      '${Apis.baseUrl}mapp/doctor/curate/commentModify/$comment_id',
      options: Options(headers: {
        'Content-Type':'application/json',
        'accessToken':'true',
      },),
      
    );
    //마찬가지로 내 댓글임을 확인하는 로직 구현할것


    if (response.statusCode == 200) {
      Get.snackbar('Success', '댓글이 삭제되었습니다.');
      await getCurateDetails(detail_id);
      await getCurateInfo('5'); //추후에 5가아닌 radius인자로
      refresh();
    }
    else if(response.statusCode == 401) {
      Get.snackbar('Failed', '본인의 댓글이 아닙니다.');
    }
    else if(response.statusCode == 403){
      Get.snackbar('Failed', '에러 발생');
    }
  }

  Future<void> getCurateDetails(String id) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    // try {
    //isLoading.value = true;
    isLoading(true);
    final response = await dio.get(
      '${Apis.baseUrl}mapp/doctor/curate/details/$id',
      options: Options(headers: {
        'Content-Type':'application/json',
        'accessToken':'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      print(data['content']['deepCurate']);
      final curateResponse = CurateDetailResponse.fromJson(data);
      curateDetail.value = curateResponse.content;

      //print(curateDetail[]);
    }
    isLoading(false);
  }
  
  
}
