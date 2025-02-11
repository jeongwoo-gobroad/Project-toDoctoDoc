import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/screen/hospital/star_rating_editor.dart';

import '../../controllers/hospital/hospital_information_controller.dart';

class HospitalReviewList extends StatefulWidget {
  const HospitalReviewList({super.key});

  @override
  State<HospitalReviewList> createState() => _HospitalReviewListState();
}

class _HospitalReviewListState extends State<HospitalReviewList> {
  HospitalInformationController hospitalInformationController = Get.put(HospitalInformationController());

  Widget chartRow(BuildContext context, String label, double pct) {
    return Row(
      children: [
        //Text(label),
        //SizedBox(width: ),
        //Icon(Icons.star, size: 8,),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 5, 8, 0),
          child:
          Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(''),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width / 2)* pct,
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(''),
                ),
              ]

          ),
        ),
        //Text('${pct * 100}%',),
      ],
    );
  }
  reviewWidget(String name, double rating, String content, DateTime time, bool isEdited) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // PROFILE NICKNAME TIME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.profile_circled, size: 40,),
                  SizedBox(width: 5,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, ),
                      SizedBox(height: 2),
                      StarRating(
                        rating: rating,
                        starSize: 20,
                        isControllable: false,
                        onRatingChanged: (rating) => {},
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (isEdited) Text('(수정됨) ', style: TextStyle(color: Colors.grey, fontSize: 10),),
                  Text(DateFormat.yMd().format(time)),
                  IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),

          // STAR RATING
          SizedBox(height: 10),

          // TODO 더보기 기능 추가
          Text(content),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('내 병원 리뷰',), ),
      body: Column(
        children: [
          Obx(() {
            if (hospitalInformationController.isReviewLoading.value) {
              return Center(child: CircularProgressIndicator(),);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                  child: Text('내 병원 리뷰', style: TextStyle(fontSize: 20),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(hospitalInformationController.stars.toDouble().toStringAsFixed(1),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50, height: 1),),
                        StarRating(
                          rating: hospitalInformationController.stars.toDouble(),
                          starSize: 20,
                          isControllable: false,
                          onRatingChanged: (rating) => {},
                        ),
                    //SizedBox(height: 5,),
                        Text('(${hospitalInformationController.reviews.length} 개)'),
                      ],
                    ),
                    Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int i = 5; i > 0; i--) ...[
                          chartRow(context, '$i', hospitalInformationController.starsNum[i]/hospitalInformationController.reviews.length)
                        ],
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 10,),

                SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return reviewWidget('익명 ${index+1}',
                          hospitalInformationController.reviews[index]['stars'],
                          hospitalInformationController.reviews[index]['content'],
                          DateTime.parse(hospitalInformationController.reviews[index]['updatedAt']), false);
                    },
                    itemCount: hospitalInformationController.reviews.length,
                  ),
                ),

              ],
            );
          }),
        ],
      ),
    );
  }
}
