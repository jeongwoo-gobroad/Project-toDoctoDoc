import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:to_doc/controllers/careplus/appointment_controller.dart';

class AppointmentRatingScreen extends StatefulWidget {
  const AppointmentRatingScreen({super.key, required this.doctorName, required this.appointmentId});

  final String doctorName;
  final String appointmentId;

  @override
  State<AppointmentRatingScreen> createState() => _AppointmentRatingScreenState();
}

class _AppointmentRatingScreenState extends State<AppointmentRatingScreen> {
  int rating = 1;

  final AppointmentController appointmentController = AppointmentController();
  final TextEditingController textEditingController = TextEditingController();

  Future<void> setAppointmentAlert(BuildContext context) async {
    return showDialog<void>(
      //다이얼로그 위젯 소환
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                Text(
                  '정말 한줄평을 등록하시겠습니까?',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: ()  {
                Navigator.of(context).pop();
              },
              child: Text('취소', style: TextStyle(color:Colors.grey),),
            ),
            TextButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
              child: Text('등록', style: TextStyle(color: Colors.black),),
              onPressed: () async {
                print(rating);
                print(textEditingController.text);

                if (await appointmentController.sendAppointmentReview(widget.appointmentId, rating, textEditingController.text)) {
                  // TODO SUCCESS ALERT

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  setState(() {});
                }
                else {
                  // TODO FAILURE ALERT
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 1.0,
        builder: (BuildContext context,
            ScrollController scrollController) {
          return
            Wrap(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 40,
                    right: 40,
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),

                  //height: 400,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),

/*          child: Wrap(
                      children: [*/
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('${widget.doctorName}와의 약속은 어떠셨나요?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),

                      SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  rating = 0;
                                });
                              },
                              child:Column(
                                children: [

                                  SvgPicture.asset('asset/images/emoji/frowning-face.svg',
                                    width: 50,
                                    colorFilter: (rating != 0) ? ColorFilter.matrix(<double>[
                                      0.2126,0.7152,0.0722,0,0,
                                      0.2126,0.7152,0.0722,0,0,
                                      0.2126,0.7152,0.0722,0,0,
                                      0,0,0,1,0,
                                    ]) : null,
                                  ),
                                  Text('별로였어요', style: TextStyle(color: (rating != 0) ? Colors.grey : null),),
                                ],
                              )
                          ),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                rating = 1;
                              });
                            },
                            child:Column(
                              children: [
                                SvgPicture.asset('asset/images/emoji/neutral-face.svg',
                                  width: 50,
                                  colorFilter: (rating != 1) ? ColorFilter.matrix(<double>[
                                    0.2126,0.7152,0.0722,0,0,
                                    0.2126,0.7152,0.0722,0,0,
                                    0.2126,0.7152,0.0722,0,0,
                                    0,0,0,1,0,
                                  ]) : null,
                                ),
                                Text('보통이였어요', style: TextStyle(color: (rating != 1) ? Colors.grey : null),),
                              ],
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                rating = 2;
                              });
                            },
                            child:Column(
                              children: [
                                SvgPicture.asset('asset/images/emoji/grinning-squinting-face.svg',
                                  width: 50,
                                  colorFilter: (rating != 2) ? ColorFilter.matrix(<double>[
                                    0.2126,0.7152,0.0722,0,0,
                                    0.2126,0.7152,0.0722,0,0,
                                    0.2126,0.7152,0.0722,0,0,
                                    0,0,0,1,0,
                                  ]) : null,
                                ),
                                Text('좋았어요', style: TextStyle(color: (rating != 2) ? Colors.grey : null),),
                              ],
                            )
                          ),

                        ],
                      ),

                      SizedBox(height: 30),

                      Container(
                        height: 100,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(

                        ),
                        child: TextField(
                          decoration: InputDecoration(border: InputBorder.none, hintText: '한줄평을 적어주세요'),
                          controller: textEditingController,

                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.zero))),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('취소')
                          ),
                          TextButton(
                              style: TextButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.zero))),
                              onPressed: () {
                                setAppointmentAlert(context);
                              },
                              child: Text('결정'),
                          ),

                        ],
                      ),



                    ],
                  ),
                ),
              ],
            );
        }
    );
  }


}
