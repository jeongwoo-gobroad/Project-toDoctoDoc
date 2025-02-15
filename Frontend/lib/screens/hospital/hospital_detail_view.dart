import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:to_doc/controllers/hospital/hospital_review_controller.dart';
import 'package:to_doc/controllers/map_controller.dart';
import 'package:to_doc/screens/hospital/hospital_rating_screen.dart';
import 'package:to_doc/screens/hospital/review_widget.dart';
import 'package:to_doc/screens/hospital/star_rating_editor.dart';


class HospitalDetailView extends StatefulWidget {
  const HospitalDetailView({super.key, required this.hospital});
  final Map<String, dynamic> hospital;

  @override
  State<HospitalDetailView> createState() => _HospitalDetailViewState();
}

class _HospitalDetailViewState extends State<HospitalDetailView> {
  HospitalReviewController hospitalReviewController = Get.put(HospitalReviewController());
  ScrollController rowScrollController = ScrollController();
  late KakaoMapController mapController;
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
  Widget placeInform(Icon thisIcon, String description) {
    return Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
    child: Row(
      // Row 내부에서 직접 너비를 확장해야 하므로, Expanded/Flexible 사용
      children: [
        thisIcon,
        const SizedBox(width: 10),
        // Text를 Expanded로 감싸서 가로 공간이 부족할 때 자동으로 줄임표 처리
        Expanded(
          child: Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
  }
  Widget imageList() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        itemCount: widget.hospital['psyProfileImage'].length,
        scrollDirection: Axis.horizontal,
        controller: rowScrollController,
        /*              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),*/
        itemBuilder: (context, index) {
          var nowImage = widget.hospital['psyProfileImage'][index];
          return Image.network(
            nowImage,
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }


  void refreshScreen() {
    hospitalReviewController.getHospitalReviewList(widget.hospital['_id']);
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    hospitalReviewController.getHospitalReviewList(widget.hospital['_id']);
  }
  Set<Marker> markers = {};

  void showMapOverlay(BuildContext context) {
   
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          height: 600,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 500,
                      child: KakaoMap(
                        onMapCreated: (controller) async {
                          mapController = controller;
                          markers.add(Marker(
                            markerId: 'hosptial',
                            latLng: LatLng(
                          widget.hospital['address']['latitude'],
                          widget.hospital['address']['longitude'],
                        ),
                          ));
                            
                          setState(() {});

                        },
                        markers: markers.toList(),
                        
                        center: LatLng(
                          widget.hospital['address']['latitude'],
                          widget.hospital['address']['longitude'],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '닫기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
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
        // TODO 간단한 병원 주소 및 연락처
        Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          /*decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
          ),*/
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: placeInform(Icon(Icons.fmd_good_outlined, size: 30),
                        '${widget.hospital['address']['address']} ${widget.hospital['address']['detailAddress']} ${widget.hospital['address']['extraAddress']}, ${widget.hospital['address']['postcode']}'),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
            onPressed: () {
              showMapOverlay(context);
            },
            child: Text(
              '지도에서 보기',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                
              ),
            ),
          ),
                ],
              ),
              placeInform(
                  Icon(CupertinoIcons.time, size: 30), '영업시간 : '),
              placeInform(
                  Icon(CupertinoIcons.phone, size: 30), widget.hospital['phone']),
            ],

          ),
        ),

        imageList(),

        TextButton(
            onPressed: () {
              Get.to(()=>HospitalRatingScreen(reviewId: '', hospitalId: widget.hospital['_id'], hospitalName: widget.hospital['name'], isMakeNewReview: true, content: '', rating: 3.0,));
            },
            child: Text('리뷰 쓰기 (예외처리 안함 조심)'),
        ),
        
        
        // TODO 리뷰 평균 평점 및 별점 리스트

        Obx(() {
          if (hospitalReviewController.isReviewLoading.value) {
            return Center(child: CircularProgressIndicator(),);
          }
          if (hospitalReviewController.reviews.length == 0) {
            return Text('리뷰가 없습니다');
          }
          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                          isCentered: true,
                        ),
                        //SizedBox(height: 5,),
                        Text('(${hospitalReviewController.reviews.length} 개)'),
                      ],
                    ),

                    //SizedBox(width: 10,),

                    Column(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int i = 5; i > 0; i--) ...[
                          chartRow(context, '$i', hospitalReviewController.starsNum[i]/hospitalReviewController.reviews.length)
                          //hospitalInformationController.reviewRatingArr[i]/hospitalInformationController.review.length),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              Text('내 리뷰'),
              Text('내 리뷰'),

              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ReviewWidget(
                      reviewId: hospitalReviewController.reviews[index]['_id'],
                      name: '익명 ${index+1}',
                      rating: hospitalReviewController.reviews[index]['stars'].toDouble(),
                      content: hospitalReviewController.reviews[index]['content'],
                      time: DateTime.parse(hospitalReviewController.reviews[index]['updatedAt']),
                      isEdited: hospitalReviewController.reviews[index]['updatedAt'] != hospitalReviewController.reviews[index]['createdAt'],
                      isMine: false,
                      setState: refreshScreen,
                  );
                },
                itemCount: hospitalReviewController.reviews.length,
              ),

            ],
          );
        }),
      ],
    )
    );
  }
}
