import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/chat_object.dart';


class makeChatList extends StatelessWidget {
  const makeChatList({super.key, required this.scrollController, required this.messageList, this.updateUnread});

  final ScrollController scrollController;
  final List<ChatObject> messageList;
  final updateUnread;
  Widget _buildUnreadDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '새 메시지',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    List<int> unreadIndices = [];
    int firstUnreadIndex = -1;
    
    if (updateUnread != null && updateUnread! > 0) {
      int remaining = updateUnread!;
      for (int i = messageList.length - 1; i >= 0; i--) {
        if (remaining <= 0) break;
        if (messageList[i].role == 'user') {
          unreadIndices.add(i);
          print('unreadIndies: ${i}');
          remaining--;
        }
      }
      if (unreadIndices.isNotEmpty) {
        unreadIndices.sort();
        firstUnreadIndex = unreadIndices.first;
      }
    }
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: messageList.length,
        itemBuilder: (context, index) {
        
          final isDoctor = messageList[index].role == 'doctor';
          final showTime = shouldShowTime(index);
          final showDate = shouldShowDate(index);

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 10.0,
            ),
            child: Column(
              children: [
                
                if (showDate) ... [
                  
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
                  mainAxisAlignment: isDoctor
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isDoctor) ...[
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
                        if (index + updateUnread == messageList.length - 1 &&
                            isDoctor) ... [
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 12, 5),
                            child: Text(
                              '여기까지 읽음',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],

                        if (isDoctor && showTime)...[
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
                        crossAxisAlignment: isDoctor
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDoctor
                                  ? Color.fromARGB(255, 225, 234, 205)
                                  : Color.fromARGB(100, 244, 242, 248),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              messageList[index].content,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],),
                    ),

                    if (!isDoctor && showTime) ...[
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
