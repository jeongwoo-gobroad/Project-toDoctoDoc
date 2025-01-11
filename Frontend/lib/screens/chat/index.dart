// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:to_doc/screens/chat/tempcontroller.dart';


// import 'room_list.dart';

// class ChatIndex extends StatefulWidget {
//   const ChatIndex({super.key});

//   @override
//   State<ChatIndex> createState() => _ChatIndexState();
// }

// class _ChatIndexState extends State<ChatIndex> {
//   final ChatController chatController = Get.put(ChatController());
//   int _currentPage = 1;

//   @override
//   void initState() {
//     super.initState();
//     chatController.roomIndex();
//   }

//   Future<void> _onRefresh() async {
//     _currentPage = 1;
//     await chatController.roomIndex();
//   }

//   bool _onNotification(ScrollNotification scrollInfo) {
//     if (scrollInfo is ScrollEndNotification &&
//         scrollInfo.metrics.extentAfter == 0) {
//       chatController.roomIndex(page: ++_currentPage);
//       return true;
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('채팅'),
//         centerTitle: false,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Obx(() {
//               return NotificationListener<ScrollNotification>(
//                 onNotification: _onNotification,
//                 child: RefreshIndicator(
//                   onRefresh: _onRefresh,
//                   child: ListView.builder(
//                     itemCount: chatController.roomList.length,
//                     itemBuilder: (context, index) {
//                       return RoomListItem(chatController.roomList[index]);
//                     },
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
