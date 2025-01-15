import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dm_list.dart';

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
        onPressed: () {
          Get.to(() => DMList());
        },
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
      
      appBar: AppBar(
        centerTitle: true,
        title: Text('토닥toDoc - Doctor', 
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
         
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text('디가오는 예약',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 16),
            
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  //내 병원정보 부분분
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text('내 병원정보',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text('나의 처방전',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text('큐레이팅 피드',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}