import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';

class MapController extends GetxController{
  
  var psychiatryList = <Map<String, dynamic>>[].obs;
  RxBool isradiusNotSelected = true.obs;
  RxBool isLoading = false.obs;
  int currentPage = 1;
  String currentRadius = '1';
  final RxSet<Marker> markers = <Marker>{}.obs;

  Future<bool> getMapInfo(String radius, {int page = 1}) async{
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if(token == null){

      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return false;
    }
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/curate/around?radius=$radius'),
        headers: {
          'Content-Type':'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(json.decode(response.body));
        markers.clear(); //초기화화

        print(data);

        if(data is Map<String,dynamic> && data['content']['list'] is List){
        List<dynamic> contentList = data['content']['list'];
        //데이터
        // for(var post in contentList){
        //   psychiatryList.value = (data['content']['list'] as List).map((e) => e as Map<String,dynamic>).toList();
        //   //print('Title: ${post['title']} Tag : ${post['tag']}');
        // }

        for(var item in contentList) { //순회하면서 marker add
        if(item is Map<String, dynamic> && item.containsKey('x') && item.containsKey('y')) {
            print(item['x']);
            print(item['y']);
            if(item['x'] is double){print('double인데요');}
            double longitude = double.parse(item['x']);
            //if(latitude is double){print('이제야 double인데요');}
            double latitude = double.parse(item['y']);

            String markerId = 'marker_${item['place_name']}';
            //print(markerId);
            if(item['isPremiumPsychiatry'] != true){
              
              markers.add(Marker(
                markerId: markerId, 
                latLng: LatLng(latitude, longitude),
                )
              );

            }else{
              print('premium이네요');
              markers.add(Marker(
                  markerId: markerId,
                  latLng: LatLng(latitude, longitude),
                  width: 24,
                  height: 35,
                  markerImageSrc:
                  'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
                  zIndex: 4,
            ));
            }
            print(markers.toList());
            markers.refresh();
            update();

        }
    }
          if (page == 1) {
              psychiatryList.value = contentList.map((e) => e as Map<String, dynamic>).toList();
          } else {
              psychiatryList.addAll(contentList.map((e) => e as Map<String, dynamic>).toList());
          }
        
        psychiatryList.refresh();
        print(psychiatryList.value);
        //시간형식: "2025-01-02T11:17:48.062Z\"
        } else{
          print('Error: ${response.statusCode}');
        }
        return true;

      } else if(response.statusCode == 404){
        
        print('Error, noSuchUser'); //디버깅깅
        
      } else if(response.statusCode == 405){
        print('Error, errorAtAroundAlgorithm'); //디버깅
      }

    } catch (error) {
      print('An error occurred: $error');
    } finally{
      isLoading.value = false;
    }


    return false;


  }

  void loadNextPage() {
    if (!isLoading.value) {
      currentPage++;
      print('currentPage Changed:  $currentPage');
      getMapInfo(currentRadius, page: currentPage);
    }
  }

}