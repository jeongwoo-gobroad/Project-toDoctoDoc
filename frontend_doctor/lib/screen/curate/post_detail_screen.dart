import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.post});

  final post;

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toUtc().add(Duration(hours: 9));
      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      //minChildSize: 0.4,
      //maxChildSize: 1.0,
      builder: (BuildContext context, ScrollController scrollController) {
        return DefaultTextStyle(
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
          child: Wrap(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20,),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10,),
                //height: 400,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20),),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                          Text(
                            post.tag,
                            style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline,),
                          ),
                          SizedBox(height: 10,),
                          Text('생성 시간 : ${formatDate(post.createdAt)}'),
                          Text('수정 시간 : ${formatDate(post.editedAt)}'),
                        ],
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                    ),

                    //if (post.tag)

                    SizedBox(height: 10,),
                    Text('내용:', style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    Text(post.details),
                    SizedBox(height: 10,),
                    Text(
                      '추가 내용:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(post.additionalMaterial == '' ? '없음' : post.additionalMaterial),


                  ],
                ),

              ),
            ],
          ),
        );
      }
    );
  }
}
