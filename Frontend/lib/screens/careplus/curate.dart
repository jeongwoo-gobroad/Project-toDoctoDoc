
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';
import 'package:to_doc/screens/careplus/curate_feed.dart';

class Curate extends StatelessWidget {

  Curate({super.key});
  CurateListController curateListController = Get.put(CurateListController(dio:Dio()));

  Future<void> _getList() async {

    await curateListController.getList();
    
  }
  Future<void> _getPost() async {

    await curateListController.getPost('677d595269eb1515eb40c500');
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: _getList,
               child: Text('누르세요'),
            ),
            ElevatedButton(
              onPressed: _getPost,
               child: Text('누르세요'),
            ),
            ElevatedButton(
              onPressed: (){Get.to(()=> CurateFeed());},
               child: Text('누르세요'),
            ),
          ],
        ),


      ),
      

    );
  }
}