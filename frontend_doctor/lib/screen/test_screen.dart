import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/curate/curate_controller.dart';


class TestScreen extends StatelessWidget {
  TestScreen({super.key});

  CurateController curateController = Get.put(CurateController(dio: Dio()));
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Row(
        children: [
          ElevatedButton(
            onPressed: (){curateController.getCurateInfo('5');}, 
            child: Text('curate정보'),
          ),
          ElevatedButton(
            onPressed: (){curateController.getCurateDetails('677f70349714ac29d8164db3');}, 
            child: Text('curate detail'),
          ),
          ElevatedButton(
            onPressed: (){}, 
            child: Text('curate screen'),
          ),








        ],



      ),


    );
  }
}