import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/screens/hospital/star_rating_editor.dart';

import '../../controllers/hospital/hospital_review_controller.dart';
import '../../controllers/hospital/hospital_visited_controller.dart';
import 'hospital_rating_screen.dart';


enum reviewMenuType {
  edit(tostring: '수정', toIcon: Icon(CupertinoIcons.scissors)),
  delete(tostring: '삭제', toIcon: Icon(Icons.phonelink_erase));

  final String tostring;
  final Icon toIcon;
  const reviewMenuType({required this.tostring, required this.toIcon});
}

class ReviewWidget extends StatelessWidget {
  HospitalVisitedController hospitalVisitedController = Get.put(HospitalVisitedController());
  HospitalReviewController hospitalReviewController = Get.put(HospitalReviewController());

  ReviewWidget({super.key,
    required this.reviewId,
    required this.name,
    required this.rating,
    required this.content,
    required this.time,
    required this.isEdited,
    required this.isMine,
    required this.setState
  });

  final Function setState;
  final String reviewId;
  final String name;
  final double rating;
  final String content;
  final DateTime time;
  final bool isEdited;
  final bool isMine;



  Widget popUpMenu(String reviewId) {
    if (isMine) {
      return PopupMenuButton<reviewMenuType>(
          onSelected: (reviewMenuType result) async {
            if (result.tostring == '수정') {
              print('edit');
              Get.to(()=>HospitalRatingScreen(reviewId: reviewId, hospitalId: '병원 id', hospitalName: '병원 이름', isMakeNewReview: false, content: content, rating: rating,))
                  ?.whenComplete(() async {
                await hospitalReviewController.getMyReviewList();
                setState();
              });
            }
            else if (result.tostring == '삭제') {
              print('delete');
              await hospitalReviewController.deleteMyReview(reviewId);
              await hospitalReviewController.getMyReviewList();
              setState();
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
    return Container();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                        isCentered: true,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (isEdited) Text('(수정됨) ', style: TextStyle(color: Colors.grey, fontSize: 10),),
                  Text(DateFormat.yMd().format(time)),
                  popUpMenu(reviewId)
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
}