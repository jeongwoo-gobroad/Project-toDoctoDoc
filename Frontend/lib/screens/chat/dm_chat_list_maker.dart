import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/screens/careplus/curate_screen.dart';

import '../../chat_object.dart';

class makeChatList extends StatelessWidget {
  const makeChatList(
      {super.key,
      required this.messageList,
      required this.scrollController,
      this.updateUnread});

  final List<ChatObject> messageList;
  final ScrollController scrollController;
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
    return messageList[index].createdAt?.day !=
        messageList[index - 1].createdAt?.day;
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
    List<int> unreadIndices = [];
    int firstUnreadIndex = -1;
    print('from dm chat maker : $messageList, unread: $updateUnread');
    if (updateUnread != null && updateUnread! > 0) {
      int remaining = updateUnread!;
      for (int i = messageList.length - 1; i >= 0; i--) {
        if (remaining <= 0) break;
        if (messageList[i].role == 'doctor') {
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
          final isUser = messageList[index].role == 'user';
          bool showUnreadDivider = index == firstUnreadIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 10.0,
            ),
            child: Column(
              children: [
                if (showUnreadDivider) _buildUnreadDivider(),
                if (shouldShowDate(index)) ...[
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
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                        if (index + updateUnread! == messageList.length - 1 &&
                            isUser) ...[
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 12, 5),
                            child: Text(
                              '여기까지 읽음',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                        if (isUser && shouldShowTime(index)) ...[
                          Container(
                            padding: EdgeInsets.fromLTRB(12, 0, 12, 5),
                            child: Text(
                              formatTime(messageList[index].createdAt),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ]
                      ],
                    ),
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
                            child: () {
                              // ChatObject
                              final chatObj = messageList[index];
                              if (chatObj.content.contains('curateId:')) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      "큐레이팅 요청입니다.",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    SizedBox(height: 4),
                                    InkWell(
                                      onTap: () {
                                        String marker = "curateId:";
                                        String curateId = "";
                                        int idx =
                                            chatObj.content.indexOf(marker);
                                        if (idx != -1) {
                                          String cId = chatObj.content
                                              .substring(idx + marker.length)
                                              .trim();
                                          print(cId);
                                          curateId = cId;
                                        } else {
                                          print("curateId가 없습니다.");
                                        }

                                        Get.to(CurationScreen(
                                            currentId: curateId));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        constraints: BoxConstraints(maxWidth: 200),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.link,
                                                color: Colors.blue),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '큐레이팅 확인하기',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return Text(
                                  chatObj.content,
                                  style: TextStyle(fontSize: 15),
                                );
                              }
                            }(),
                          ),
                        ],
                      ),
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
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
