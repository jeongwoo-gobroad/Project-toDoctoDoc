import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../chat_object.dart';

class makeChatList extends StatelessWidget {
  const makeChatList({super.key, required this.messageList, required this.scrollController, this.updateUnread});

  final List<ChatObject> messageList;
  final ScrollController scrollController;
  final updateUnread;


  bool shouldShowTime(int index) {
    if (index == messageList.length - 1) return true;
    final currentMsg = messageList[index];
    final nextMsg = messageList[index + 1];

    String currentTime = DateFormat('d HH mm').format(currentMsg.createdAt!);
    String nextTime = DateFormat('d HH mm').format(nextMsg.createdAt!);
    return currentMsg.role != nextMsg.role || currentTime != nextTime;
  }

  bool shouldShowDate(int index) {
    if (index == 0) {
      return true;
    }
    return messageList[index].createdAt?.day != messageList[index-1].createdAt?.day;
  }

  String formatTime(DateTime? dateTime) {
    try {
      return DateFormat('aa hh:mm', 'ko_KR').format(dateTime!);
    } catch (e) {
      return '--:--';
    }
  }

  String formatDate(DateTime? dateTime) {
    try {
      return DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(dateTime!);
    } catch (e) {
      print(e);
      return '날짜 정보 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          controller: scrollController,
          itemCount: messageList.length,
          itemBuilder: (context, index) {
            final isUser = messageList[index].role == 'user';

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 10.0,
              ),
              child: Column(
                children: [
                  if (shouldShowDate(index)) ... [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        formatDate(messageList[index].createdAt),
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],

                  Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //상대방 표시시
                      if (!isUser) ...[
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.grey[600]),
                        ),
                        SizedBox(width: 8),
                      ],
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: [
                          if (index + updateUnread == messageList.length - 1 && isUser) ... [
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 12, 5),
                              child: Text(
                                '여기까지 읽음',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],

                          if (isUser && shouldShowTime(index))...[
                            Container(
                              padding: EdgeInsets.fromLTRB(12, 0, 12, 5),
                              child: Text(
                                formatTime(messageList[index].createdAt),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ]
                        ],),


                      Flexible(
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Color.fromARGB(255, 225, 234, 205)
                                    : Color.fromARGB(255, 244, 242, 248),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                messageList[index].content,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],),
                      ),

                      if (!isUser && shouldShowTime(index)) ...[
                        Container(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            formatTime(messageList[index].createdAt),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],),
                ],),
            );
          },

      ),
    );
  }
}
