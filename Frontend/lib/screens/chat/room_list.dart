// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'room_model.dart';
// import '../../screens/chat/show.dart';
// import '../../shared/timeutil.dart';

// /**
//  * 채팅방 목록을 보여줌
//  */
// class RoomListItem extends StatelessWidget {
//   final RoomModel room;
//   const RoomListItem(this.room, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Get.to(() => ChatShow(room.id));
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Row(
//           children: [
//             SizedBox(
//               width: 60,
//               height: 60,
//               child: Stack(
//                 children: [
//                   CircleAvatar(
//                     backgroundImage: NetworkImage(room.client.profileUrl),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.white, width: 2),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                           room.feed.imageUrl,
//                           width: 40,
//                           height: 40,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 15),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       room.feed.title,
//                       style: const TextStyle().copyWith(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(TimeUtil.parse(room.updatedAt)),
//                   ],
//                 ),
//                 Text(room.lastMessage)
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
