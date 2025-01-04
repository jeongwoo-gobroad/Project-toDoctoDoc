import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/aboutpage.dart';
import 'package:to_doc/controllers/query_controller.dart';
import 'package:to_doc/screens/airesult.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //final AboutpageProvider aboutpage = Get.put(AboutpageProvider());
  final TextEditingController queryController = TextEditingController(); 
 //추후 수정
  final QueryController query = Get.put(QueryController());
  String? id;
  String? usernick;

  Future<void> _getUserInfo() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id');
      usernick = prefs.getString('usernick');
      
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserInfo();
  }






  Home({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      //floating 아이콘 
        floatingActionButton: FloatingActionButton(
          onPressed: (){/* to DM page */},
          child: const Icon(Icons.chat_bubble_outline_rounded),
          
          
        ),




      //appBar
      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
          onTap: (){
            /*to about page*/
            Get.to(()=> Aboutpage());
          },
          child: Text('토닥toDoc', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        actions: [
          
        ],
      ),

      
      body: Center(
        
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '반가워요! ${usernick ?? '로그인이 필요합니다.'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
          
          
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: queryController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 20,
                      ),
                      hintText: '샘플 텍스트',
                      suffixIcon: IconButton(
                        
                        onPressed: () async{
                          /*쿼리*/
                          //input 
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('jwt_token');
          
                            if (token == null) {
                              Get.defaultDialog(
                                title: '로그인 필요',
                                middleText: '로그인이 필요합니다. 로그인 후 다시 시도해 주세요.',
                                confirm: ElevatedButton(
                                  onPressed: () {
                                    Get.back(); // 다이얼로그 닫기
                                    // 로그인 페이지로 이동 코드 추가
                                  },
                                  child: Text('로그인'),
                                ),
                                cancel: TextButton(
                                  onPressed: () {
                                    Get.back(); // 다이얼로그 닫기
                                  },
                                  child: Text('취소'),
                                ),
                              );
                            } else {
                              // 로그인 되어 있을 때
                              query.sendQuery(queryController.text);
                              Get.to(() => Airesult());
                            }
                        },
                      
                        icon: Icon(Icons.arrow_circle_right_outlined, size: 45)
                      ),
                    ),
          
          
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  '샘플 텍스트',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

