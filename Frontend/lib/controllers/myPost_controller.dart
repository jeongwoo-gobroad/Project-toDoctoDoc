import 'package:get/get.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../auth/auth_dio.dart';


class MypostController extends GetxController{

  var posts = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isTagLoading = false.obs;


  Future<bool> fetchMyPost() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/myPosts',
      options: Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
    );

    if(response.statusCode==200){
      final data = json.decode(response.data);
      
      print(data);
      
      if(data is Map<String,dynamic> && data['content'] is List){
        List<dynamic> contentList = data['content'];
        //데이터
        for(var post in contentList){
          posts.value = (data['content'] as List).map((e) => e as Map<String,dynamic>).toList();
          //print('Title: ${post['title']} Tag : ${post['tag']}');
        }
        posts.value.sort((a, b) => 
        DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])) //정렬
        );
        posts.refresh();
        //시간형식: "2025-01-02T11:17:48.062Z\"
      }
      //print('게시물 data: ${posts.value}');
      isLoading.value = false;
      return true;
    }
    else{
      Get.snackbar('Error', '게시물을 불러오지 못했습니다. ${response.statusCode})');
      return false;
    }
    /*TypeError: "{\"error\":false,\"result\":\"myposts\",\"content\":[{\"_id\":\"67767dfb6a4a8b2b5fe85785\",\"title\":\"만사가 귀찮아\",\"createdAt\":\"2025-01-02T11:17:48.062Z\",\"tag\":\"힘들어\"},{\"_id\":\"6778e0b96804ede7b7ae0b50\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:07:44.833Z\",\"tag\":\"\"},{\"_id\":\"6778e14f6804ede7b7ae0b71\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:07:44.833Z\",\"tag\":\"\"},{\"_id\":\"6778e27ce86459c4e32add96\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:23:04.415Z\",\"tag\":\"\"},{\"_id\":\"6778e2a5e86459c4e32adda6\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:23:04.415Z\",\"tag\":\"\"},{\"_id\":\"6778e4cae19925a908da5d9a\",\"title\":\"혹시 통신이 되니?\",\"createdAt\":\"2025-01-04T07:32:47.960Z\",\"tag\":\"\"},{\"_id\":\"6778e4ece19925a908da5db9\",\"title\":\"혹시 통신이 되니?\",\"createdAt\":\"2025-01-04T07:32:47.960Z\",\"tag\":\"\"},{\"_id\":\"6778f95b5a158a9d6d819a0e\",\"title\":\"낯선 환경에서 생활하는게 걱정돼\",\"createdAt\":\"2025-01-04T08:54:27.801Z\",\"tag\":\"ㅇㅇ\"},{\"_id\":\"67790ae43e2e645912c03a7c\",\"title\":\"피곤해\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"\"},{\"_id\":\"67791a303e2e645912c03dab\",\"title\":\"마음이 힘들어\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"\"},{\"_id\":\"67791a9f3e2e645912c03df4\",\"title\":\"다른 걱정거리\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"걱정거리\"},{\"_id\":\"67791bed3e2e645912c03e69\",\"title\":\"테스트용입니다.\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"testtotest\"}]}" */
  }


  Future<void> editMyPost(String postID, String additional_material, String? tag) async {

    print('myPost: $postID $additional_material $tag');


    /** ID다를시 error */
    
    tag = (tag != null && tag.trim().isEmpty) ? null : tag; //공백 지우기기

    final Map<String, dynamic> body = {
        '_id': postID,
        'content_additional': additional_material,
        'tags': tag,
    };
    print('this is $body');

    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    try {
      final response = await dio.patch(
        '${Apis.baseUrl}mapp/edit/$postID',
        options: Options(
          headers: {
            'Content-Type':'application/json',
            'accessToken': 'true',
          },
        ),
        data: json.encode(body),
      );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.data}');

    if (response.statusCode == 200) {
      Get.snackbar('Success', '게시물이 성공적으로 수정되었습니다.');
      //editedAt 정보 불러오기
      //String d = response.body['content']['editedAt'];
      fetchMyPost();
      refresh();
      print('수정 성공');
    } else if (response.statusCode == 401) {
      Get.snackbar('Error', '게시물 수정에 실패');
      print('401 Unauthorized');
    } else {
      Get.snackbar('Error', '게시물 수정에 실패했습니다.');
      print('Error: ${response.statusCode}, ${response.data}');
    }
  } catch (e) {
    print('Exception: $e');
    Get.snackbar('Error', '오류가 발생했습니다.');
  } finally {
    isLoading.value = false;
  }
     
    //isLoading.value = false;
    /*TypeError: "{\"error\":false,\"result\":\"myposts\",\"content\":[{\"_id\":\"67767dfb6a4a8b2b5fe85785\",\"title\":\"만사가 귀찮아\",\"createdAt\":\"2025-01-02T11:17:48.062Z\",\"tag\":\"힘들어\"},{\"_id\":\"6778e0b96804ede7b7ae0b50\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:07:44.833Z\",\"tag\":\"\"},{\"_id\":\"6778e14f6804ede7b7ae0b71\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:07:44.833Z\",\"tag\":\"\"},{\"_id\":\"6778e27ce86459c4e32add96\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:23:04.415Z\",\"tag\":\"\"},{\"_id\":\"6778e2a5e86459c4e32adda6\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:23:04.415Z\",\"tag\":\"\"},{\"_id\":\"6778e4cae19925a908da5d9a\",\"title\":\"혹시 통신이 되니?\",\"createdAt\":\"2025-01-04T07:32:47.960Z\",\"tag\":\"\"},{\"_id\":\"6778e4ece19925a908da5db9\",\"title\":\"혹시 통신이 되니?\",\"createdAt\":\"2025-01-04T07:32:47.960Z\",\"tag\":\"\"},{\"_id\":\"6778f95b5a158a9d6d819a0e\",\"title\":\"낯선 환경에서 생활하는게 걱정돼\",\"createdAt\":\"2025-01-04T08:54:27.801Z\",\"tag\":\"ㅇㅇ\"},{\"_id\":\"67790ae43e2e645912c03a7c\",\"title\":\"피곤해\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"\"},{\"_id\":\"67791a303e2e645912c03dab\",\"title\":\"마음이 힘들어\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"\"},{\"_id\":\"67791a9f3e2e645912c03df4\",\"title\":\"다른 걱정거리\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"걱정거리\"},{\"_id\":\"67791bed3e2e645912c03e69\",\"title\":\"테스트용입니다.\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"testtotest\"}]}" */
 
  }


  Future<bool> deleteMyPost(String postID) async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.delete(
      '${Apis.baseUrl}mapp/delete/$postID',
      options: Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
    );


    if(response.statusCode==200){
      //ID기반
      int index = posts.indexWhere((feed) => feed['_id'] == postID);
      if(index != -1){
        posts.removeAt(index);
        Get.snackbar('Success', '게시물이 성공적으로 삭제되었습니다.');

        fetchMyPost(); //delete후에는 fetch
        return true;
      } else {
        Get.snackbar('Error', '해당 게시물을 찾을 수 없습니다.');
        return false;
      }
      } else {
        Get.snackbar('Error', '게시물을 삭제하지 못했습니다. (${response.statusCode})');
        return false;
      }
    isLoading.value = false;
  }


  Future<List<Map<String, dynamic>>> tagSearch(String tag) async {
    isTagLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/tagSearch/$tag',
      options: Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      )
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      var tagList = <Map<String, dynamic>>[];

      if (data is Map<String,dynamic> && data['content'] is List) {
        List<dynamic> contentList = data['content'];
        for(var post in contentList){
          tagList = (data['content'] as List).map((e) => e as Map<String,dynamic>).toList();
          print(post);
          //print('Title: ${post['title']} Tag : ${post['tag']}');
        }
        isTagLoading.value = false;
        return tagList;
      }
    } else {
      Get.snackbar('Error', '태그 검색에 실패했습니다. ${response.statusCode})');
    }
    isTagLoading.value = false;
    return [];
  }
}