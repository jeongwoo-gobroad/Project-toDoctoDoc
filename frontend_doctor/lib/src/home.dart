import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dm_list.dart';

// jeongwoox7
// aa860104

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Get.to ( () => DMList());
            },
          child: const Icon(Icons.chat_bubble_outline_rounded),


          ),
      

      appBar: AppBar(
        centerTitle: true,
        title: Text('토닥toDoc - Doctor', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),


      

    );
  }
}