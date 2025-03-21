import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/screens/hospital/star_rating_editor.dart';

import '../../controllers/hospital/hospital_review_controller.dart';

class HospitalRatingScreen extends StatefulWidget {
  const HospitalRatingScreen({super.key,
    required this.hospitalId,
    required this.hospitalName,
    required this.isMakeNewReview,
    required this.content,
    required this.rating,
    required this.reviewId,
  });

  final String hospitalId;
  final String hospitalName;
  final bool isMakeNewReview;
  final String content;
  final double rating;
  final String reviewId;

  @override
  State<HospitalRatingScreen> createState() => _HospitalRatingScreenState();
}

class _HospitalRatingScreenState extends State<HospitalRatingScreen> {
  double rating = 3;
  bool willReVisit = false;

  late TextEditingController textEditingController = TextEditingController(text: widget.content);
  HospitalReviewController hospitalReviewController = Get.put(HospitalReviewController());

  @override
  void initState() {
    print(widget.hospitalId);
    print(widget.hospitalName);
    print(widget.isMakeNewReview);
    print(widget.content);
    print(widget.reviewId);
    print(widget.rating);


    if (widget.isMakeNewReview) {
      rating = widget.rating;
    }

    super.initState();
  }

  Future<void> sendReviewApprovalAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '리뷰를 정말 제출하시겠습니까?',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (widget.isMakeNewReview) {
                  hospitalReviewController.postUserReview(widget.hospitalId, rating, textEditingController.text);
                }
                else {
                  await hospitalReviewController.editUserReview(widget.hospitalId, widget.reviewId, rating, textEditingController.text);
                }

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green)),
              child: Text('승낙', style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              child: Text('취소', style: TextStyle(color: Colors.grey),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.hospitalName,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              //Text('별점을 남겨주세요', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

              SizedBox(height: 50,),
              Center(
                child: StarRating(
                  rating: rating,
                  starSize: 50,
                  isControllable: true,
                  onRatingChanged: (rating) => setState(() => this.rating = rating),
                  isCentered: true,
                ),
              ),
              SizedBox(height: 20,),
              TextButton(
                onPressed: () {
                  setState(() {
                    willReVisit = !willReVisit;
                  });
                },
                style: TextButton.styleFrom(
                  //minimumSize: Size(10, 10),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  backgroundColor: (willReVisit)? Colors.green : null,
                ),
                child: SizedBox(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: (willReVisit)? Colors.white : null,),
                      Text('다시 방문히고 싶어요', style: TextStyle(color: (willReVisit)? Colors.white : null),)
                    ],
                  ),
                )
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width - 100,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
                ),
              ),
            ],
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Text('리뷰를 작성해 보세요', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),

                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  height: 200,
                  child: TextField(
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical(y: -1.0),
                    controller: textEditingController,
                    decoration: InputDecoration(
                        hintText: '여기에 리뷰를 작성해 보세요.\n소중한 리뷰는 다른 유저들에게 도움이 됩니다.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                    ),
                  ),
                ),


                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        sendReviewApprovalAlert(context);

                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      ),
                      child: Text('작성완료', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold,)),
                  ),
                ),
              ],
            ),
          )



        ],
      )



      ,



    );
  }
}
