import 'package:flutter/material.dart';
import 'package:to_doc/screens/hospital/star_rating_editor.dart';

import '../../controllers/hospital/hospital_review_controller.dart';

class HospitalRatingScreen extends StatefulWidget {
  const HospitalRatingScreen({super.key, required this.hospitalId});

  final String hospitalId;

  @override
  State<HospitalRatingScreen> createState() => _HospitalRatingScreenState();
}

/*
  TODO : UI 완성



  Object 구조
  user
  createdAt
  updatedAt
  place_id
  stars
  content
*/


class _HospitalRatingScreenState extends State<HospitalRatingScreen> {
  double rating = 3.5;
  bool willReVisit = false;

  TextEditingController textEditingController = TextEditingController();
  HospitalReviewController hospitalReviewController = HospitalReviewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('병원명 (가)',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                //Text('별점을 남겨주세요', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

                SizedBox(height: 50,),
                StarRating(
                  rating: rating,
                  starSize: 50,
                  isControllable: true,
                  onRatingChanged: (rating) => setState(() => this.rating = rating),
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
                        hospitalReviewController.postUserReview(widget.hospitalId, rating, textEditingController.text);
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
