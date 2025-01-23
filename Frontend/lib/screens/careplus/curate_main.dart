import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/careplus/curate_list_controller.dart';
import 'package:get/get.dart';

import '../chat/dm_list.dart';
import 'curate_feed.dart';
import 'curate_list.dart';



class CurateMain extends StatefulWidget {
  const CurateMain({super.key});

  @override
  State<CurateMain> createState() => _CurateMainState();
}

class _CurateMainState extends State<CurateMain> {
  bool isLoading = true;
  late ScrollController _scrollController;
  final CurateListController curateListController = Get.put(CurateListController(dio:Dio()));

  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date).toLocal();
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    return formattedDate;
  }


  void initState() {
    super.initState();
    curateListController.getList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        //centerTitle: true,
        title: InkWell(
          child: Text('큐레이팅',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        //shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
        backgroundColor: Colors.grey.shade100,
      ),

      body: Obx(
      () => Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10,),

            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,),
              width: MediaQuery.of(context).size.width - 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.fromLTRB(20, 15, 0, 0),
                      child: Text('최근 큐레이팅 목록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    height: 150,
                    child: ListView.builder(
                      itemCount: (curateListController.CurateList.length > 3) ? 3 : curateListController.CurateList.length,
                      itemBuilder: (context, index) {
                        final curateList = curateListController.CurateList[index];
                        final commentCount = curateList['comments']?.length ?? 0;
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatDate(curateList['date'])}에 신청한 큐레이팅',
                                style: TextStyle(
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.comment, size: 16),
                                  SizedBox(width: 3),
                                  Text('$commentCount'),
                                ],
                              ),
                            ],
                          ),
                          onTap: (){
                            curateListController.getPost(curateList['_id']);
                            Get.to(()=> CurationScreen(currentId: curateList['_id']));
                          },
                        );
                      },

                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border( top: BorderSide(color: Colors.grey.withAlpha(50)),)
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                          onPressed: () {
                            Get.to(()=> CurateFeed());
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.all(Radius.circular(0)),
                            ),
                            //minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('전체보기', style: TextStyle(color: Colors.black),)),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 10,),

            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.fromLTRB(20, 15, 0, 0),
                        child: Text('최근 DM 목록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      height: 180,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          //final curateList = curateListController.CurateList[index];
                          //final commentCount = curateList['comments']?.length ?? 0;
                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'ㅇㅇㅇ',
                                    style: TextStyle(
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                                Text('1'),
                              ],
                            ),
                            subtitle: Text('TEST'),
                            onTap: (){
                              //curateListController.getPost(curateList['_id']);
                              //Get.to(()=> CurationScreen(currentId: curateList['_id']));
                            },

                          );
                        },
                        itemCount: curateListController.CurateList.length,
                      ),
                    ),

                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border( top: BorderSide(color: Colors.grey.withAlpha(50)),)
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Get.to(()=> DMList());
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.all(Radius.circular(0)),
                            ),
                            //minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('전체보기', style: TextStyle(color: Colors.black),)),
                      ),
                    )


                  ],
                ),
              ),
            ),
          ],
        ),
      )
    )
    );
  }
}
