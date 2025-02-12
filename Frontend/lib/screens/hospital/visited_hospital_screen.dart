import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/hospital/hospital_information_controller.dart';
import 'package:to_doc/controllers/hospital/hospital_visited_controller.dart';
import 'package:to_doc/screens/hospital/hospital_detail_view.dart';
import 'package:to_doc/screens/hospital/hospital_rating_screen.dart';
import 'package:to_doc/screens/hospital/review_widget.dart';
import 'package:to_doc/screens/hospital/star_rating_editor.dart';

import '../../controllers/hospital/hospital_review_controller.dart';

class VisitedHospitalScreen extends StatefulWidget {
  const VisitedHospitalScreen({super.key});

  @override
  State<VisitedHospitalScreen> createState() => _VisitedHospitalScreenState();
}

class _VisitedHospitalScreenState extends State<VisitedHospitalScreen> with SingleTickerProviderStateMixin {
  HospitalVisitedController hospitalVisitedController = Get.put(HospitalVisitedController());
  HospitalReviewController hospitalReviewController = Get.put(HospitalReviewController());

  ScrollController scrollController = ScrollController();
  late TabController tabController = TabController(length: 2, vsync: this, initialIndex: 0, animationDuration: const Duration(milliseconds: 300));

  resetScreen() {
    hospitalReviewController.getMyReviewList();
    hospitalVisitedController.getVisitedHospitals();
  }


  @override
  void initState() {
    super.initState();
    hospitalReviewController.getMyReviewList();
    hospitalVisitedController.getVisitedHospitals();
    
/*    tabController.addListener(() {
      hospitalVisitedController.getMyReviewList();
      hospitalVisitedController.getVisitedHospitals();
    });*/
    //setState(() {});
  }

  Widget popUpMenu(String reviewId, bool isMine) {
    return PopupMenuButton<reviewMenuType>(
        onSelected: (reviewMenuType result) {
          if (result.tostring == '수정') {



          }
          else if (result.tostring == '삭제') {
            print('delete');
            hospitalReviewController.deleteMyReview(reviewId);
            hospitalReviewController.getMyReviewList();
          }
        },
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) {
          return [
            for (final value in reviewMenuType.values)
              PopupMenuItem(
                value: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value.tostring),
                    value.toIcon,
                  ],
                ),
              ),
          ];
        }
    );
  }


  hospitalDetailSheet(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {//(BuildContext context) => HospitalDetailView(),
        return DraggableScrollableSheet(
          expand: false,
          snap: true,
          snapSizes: [0.4, 1.0],
          initialChildSize: 0.4,
          minChildSize: 0.4,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(height: 2000, child: HospitalDetailView(hospital: hospital))
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('방문한 병원들 (가)', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        bottom: TabBar(controller: tabController, tabs: [Tab(text: '방문한 병원',), Tab(text: '쓴 리뷰들',)])
      ),

      body: TabBarView(
        controller: tabController,
        children: [
          SingleChildScrollView(
            child: Obx(() {
              if (hospitalVisitedController.isLoading.value) {
                return Center(child: CircularProgressIndicator(),);
              }
              if (hospitalVisitedController.hospitals.isEmpty) {
                return Center(child: Text('방문한 병원이 없습니다'));
              }
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: hospitalVisitedController.hospitals.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          hospitalDetailSheet(hospitalVisitedController.hospitals[index]);
                          //Get.to(()=>HospitalRatingScreen());
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
                          ),
                          child: Column(
                            children: [
                              Text(hospitalVisitedController.hospitals[index]['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              //Text(, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              //Text(hospitalVisitedController.hospitals[index]['isPremiumPsy'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              Text(hospitalVisitedController.hospitals[index]['place_id'], style: TextStyle(fontSize: 15, color: Colors.grey),),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ],
              );
            }),
          ),
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                hospitalReviewController.getMyReviewList();
              });
            },
            child: SingleChildScrollView(
              child: Obx(() {
                if (hospitalReviewController.isReviewLoading.value) {
                  return Center(child: CircularProgressIndicator(),);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: hospitalReviewController.myReview.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('병원명: ${hospitalReviewController.myReview[index]['place_id']}'),
                          ),
                          ReviewWidget(
                              reviewId: hospitalReviewController.myReview[index]['_id'],
                              name: '내 리뷰',
                              rating: hospitalReviewController.myReview[index]['stars'].toDouble(),
                              content: hospitalReviewController.myReview[index]['content'],
                              time: DateTime.parse(hospitalReviewController.myReview[index]['updatedAt']),
                              isEdited: hospitalReviewController.myReview[index]['updatedAt'] != hospitalReviewController.myReview[index]['createdAt'],
                              isMine: true,
                              setState: resetScreen
                          ),
                        ],
                      )
                    );
                  }
                );
            
              }),
            ),
          ),



        ],
      ),

    );
  }
}
