import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AiChatDetailScreen extends StatelessWidget {
  const AiChatDetailScreen({super.key, required this.chat});

  final chat;

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
        initialChildSize: 0.9,
        //minChildSize: 0.4,
        //maxChildSize: 1.0,
        builder: (BuildContext context, ScrollController scrollController) {
          return DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
            child: Wrap(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20,),
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20,),
                  height: MediaQuery.of(context).size.height - 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20),),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chat.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, ),),
                        SizedBox(height: 10,),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: chat.response.length,
                          itemBuilder: (context, msgIndex) {
                            final message = chat.response[msgIndex];
                            return Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: message.role == 'assistant'
                                    ? Colors.blue[50]
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.role == 'assistant' ? 'AI' : '사용자',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: message.role == 'assistant'
                                          ? Colors.blue
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(message.content),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                ),
              ],
            ),
          );
        }
    );
  }
}
