import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/provider/aboutpage_provider.dart';


class Aboutpage extends StatelessWidget {

  Aboutpage({super.key});
  final AboutpageProvider aboutProvider = Get.put(AboutpageProvider());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('About Page'),

      ),
      body: Obx((){
        if(aboutProvider.isLoading.value == true){
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child : Text(aboutProvider.aboutData.value),
          ),
        );


      }),
    
    );
  }
}