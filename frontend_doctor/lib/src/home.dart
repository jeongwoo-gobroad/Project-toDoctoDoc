import 'package:flutter/material.dart';
import 'package:get/get.dart';


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
          onPressed: (){/* to DM page */},
          child: const Icon(Icons.chat_bubble_outline_rounded),
          
          
      ),
      

      appBar: AppBar(
        centerTitle: true,
        title: Text('토닥toDoc - Doctor', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),


      

    );
  }
}