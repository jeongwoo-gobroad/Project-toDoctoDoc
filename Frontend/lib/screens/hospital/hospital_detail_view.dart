import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/screens/hospital/hospital_rating_screen.dart';
import 'package:to_doc/screens/hospital/star_rating_editor.dart';

class HospitalDetailView extends StatefulWidget {
  const HospitalDetailView({super.key, required this.hospital});
  final Map<String, dynamic> hospital;
  
  @override
  State<HospitalDetailView> createState() => _HospitalDetailViewState();
}

class _HospitalDetailViewState extends State<HospitalDetailView> {
  ScrollController pictureScrollController = ScrollController();


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
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
      ),
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

  Widget placeInform(Icon thisIcon, String description) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
              //width: MediaQuery.of(context).size.width * 1 / 20,
              child: thisIcon,
          ),
          SizedBox(width: 10,),
          Container(
              //color: Colors.blue,
              width: MediaQuery.of(context).size.width * 3 / 4,
              child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      titleSpacing: 20,
      automaticallyImplyLeading: false,
      title: Text(widget.hospital['name'], style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.verified, size: 25,
              color: (widget.hospital['isPremiumPsy']) ? Colors.amber : Colors.grey
          ),
        ),
      ],
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // TODO 병원 사진 LIST
        //(height: 40, color: Colors,),

        // TODO 간단한 병원 주소 및 연락처
        Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          /*decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
          ),*/
          child: Column(
            children: [
              placeInform(Icon(Icons.fmd_good_outlined, size: 30),
                  '${widget.hospital['address']['address']} ${widget.hospital['address']['detailAddress']} ${widget.hospital['address']['extraAddress']}, ${widget.hospital['address']['postcode']}'),
              placeInform(
                  Icon(CupertinoIcons.time, size: 30), '영업시간 : ${widget.hospital['openTime'][0]} ~ ${DateTime.parse(widget.hospital['breakTime'])}'),
              placeInform(
                  Icon(CupertinoIcons.phone, size: 30), widget.hospital['phone']),
            ],

          ),
        ),

        Container(
          height: 250,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            //controller: pictureScrollController,
            child: Row(
              children: [
                Container(decoration: BoxDecoration(color: Colors.black),
                  width: 100,),
                Container(decoration: BoxDecoration(color: Colors.grey),
                  width: 200,),
                Container(decoration: BoxDecoration(color: Colors.blue),
                  width: 300,),
                Container(decoration: BoxDecoration(color: Colors.red),
                  width: 200,),
              ],
            ),
          ),
        ),

        TextButton(
            onPressed: () {
              Get.to(()=>HospitalRatingScreen(hospitalId: widget.hospital['_id'],));
            },
            child: Text('리뷰 쓰기 (예외처리 안함 조심)'),
        ),
        
        
        // TODO 리뷰 평균 평점 및 별점 리스트
        Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(widget.hospital['stars'].toDouble().toStringAsFixed(1),
                    //${{hospitalInformationController.averageRating}}',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 50,
                        height: 1),),
                  StarRating(
                    rating: widget.hospital['stars'].toDouble(),
                    starSize: 20,
                    isControllable: false,
                    onRatingChanged: (rating) => {},
                  ),
                  //SizedBox(height: 5,),
                  Text('(${widget.hospital['reviews'].length ?? 0}개)'),
                ],
              ),

              //SizedBox(width: 10,),

              Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 5; i > 0; i--) ...[
                    chartRow(context, '$i', 0.2)
                    //hospitalInformationController.reviewRatingArr[i]/hospitalInformationController.review.length),
                  ],
                ],
              ),
            ],
          ),
        ),


        // TODO 리뷰 리스트
        // TODO 맨위에 본인거 있으면 그거 따로 띄우기
        Text('내 리뷰'),
        Column(
          children: [
            reviewWidget('성이름', 3.5, 'ㅁㄴㅇㅇㄻㄴㄴㅁㄹㄴ', DateTime.now(), true),
            reviewWidget('dd', 2.0, 'adsggaggdgagasggagsgadsgagasgas',
                DateTime.now(), false),
            reviewWidget('dd', 2.0, 'adsggaggdgagasggagsgadsgagasgas',
                DateTime.now(), false),
            reviewWidget(
                'dafd', 1.5, 'asdgagsagagasgdagagagddgag\nafsadfafa',
                DateTime.now(), false),
            reviewWidget('dafd', 1.5,
                'asdgagsagagasgdagagagddgagafsadfafaasdgagsagagasgdagagagddgagafsadfafaasdgagsagagasgdagagagddgagafsadfafa',
                DateTime.now(), true),
            reviewWidget(
                'dafd', 1.5, 'asdgagsagagasgdagagagddgag\nafsadfafa',
                DateTime.now(), false),
          ],
        ),


        /*
      ListView.builder(
        controller : scrollController,
        itemCount: 0,
        itemBuilder: (context, index) {
          return reviewWidget();
        },
      ),
      */


      ],
    )
    );
  }
}
