import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/screen/hospital/hospital_review_list.dart';
import 'package:to_doc_for_doc/screen/hospital/star_rating_editor.dart';
import '../../controllers/hospital/hospital_information_controller.dart';


class HospitalDetailScreen extends StatefulWidget {
  const HospitalDetailScreen({super.key,});

  @override
  _HospitalDetailScreenState createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  HospitalInformationController hospitalInformationController = Get.put(HospitalInformationController());
  ScrollController rowScrollController = ScrollController();

  int selectedIndex = -1;
  var _tapPosition;

  XFile? _pickedFile;
  CroppedFile? _croppedFile;


  Future<void> deleteImageAlert(BuildContext context, String imageName) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '이 이미지를 정말 삭제하시겠습니까?',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await hospitalInformationController.deleteImage(imageName)) {
                  await hospitalInformationController.getInfo();
                  setState(() {});
                }
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.red)),
              child: Text('삭제', style: TextStyle(color: Colors.white),),
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
  Future<void> uploadImageAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('선택한 이미지'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('정말 업로드 하시겠습니까?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                imageWidget()
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                print ('이미지 업로드');

                uploadImage();
                Navigator.of(context).pop();
                setState(() {
                  //_croppedFile = null;
                });
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green)),
              child: Text('업로드', style: TextStyle(color: Colors.white),),
            ),
            TextButton(
              child: Text('취소', style: TextStyle(color: Colors.grey),),
              onPressed: () {
                _croppedFile = null;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget imageList() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        itemCount: hospitalInformationController.psyProfileImage.length,
        scrollDirection: Axis.horizontal,
        controller: rowScrollController,
        /*              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),*/
        itemBuilder: (context, index) {
          var nowImage = hospitalInformationController.psyProfileImage[index];
          return GestureDetector(
            onLongPress: () {
              //selectedIndex = index;
              final overlay = Overlay.of(context).context.findRenderObject();

              showMenu(
                context: context,
                position: RelativeRect.fromRect(_tapPosition! & const Size(40, 40), // smaller rect, the touch area
                    Offset.zero & overlay!.semanticBounds.size // Bigger rect, the entire screen
                ),
                items: <PopupMenuEntry>[
                  PopupMenuItem(
                    onTap: () {
                      print(nowImage);
                      Uri uri = Uri.parse(nowImage);
                      String fileName = uri.pathSegments.last.split("/").last;
                      print(fileName);
                      deleteImageAlert(context, fileName);
                    },
                    child: Row(
                      children: <Widget>[Icon(Icons.delete), Text("이미지 삭제"),],
                    ),
                  ),
                ],
              );
              selectedIndex = -1;
            },
            onTapDown: (details) {
              _tapPosition = details.globalPosition;
            },
            child: Image.network(
              nowImage,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
  Widget imageWidget() {
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void uploadImage() async {
    if (_croppedFile != null) {
      dynamic sendData = _croppedFile?.path;
      if (await hospitalInformationController.uploadImage(sendData)) {
        await hospitalInformationController.getInfo();
        _croppedFile = null;
        _pickedFile = null;
        setState(() {});
      }
    }
  }
  Future<void> findAndCropImage() async {
    _pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 1024,
      maxWidth: 1024,
    );

    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Widget reviewSample() {
    return Obx(() {
      if (hospitalInformationController.isReviewLoading.value) {
        return Center(child: CircularProgressIndicator(),);
      }
      if (hospitalInformationController.reviews.length == 0) {
        return Text('리뷰가 없습니다');
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
              child: Text('내 병원 리뷰', style: TextStyle(fontSize: 20),),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(hospitalInformationController.stars.toDouble()
                        .toStringAsFixed(1),
                      //${{hospitalInformationController.averageRating}}',
                      style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 50,
                          height: 1),),
                    StarRating(
                      rating: hospitalInformationController.stars.toDouble(),
                      starSize: 20,
                      isControllable: false,
                      onRatingChanged: (rating) => {},
                    ),
                    //SizedBox(height: 5,),
                    Text('(${hospitalInformationController.reviews.length} 개)'),
                  ],
                ),
                Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (int i = 5; i > 0; i--) ...[
                      chartRow(context, '$i', hospitalInformationController.starsNum[i]/hospitalInformationController.reviews.length)
                      //hospitalInformationController.reviewRatingArr[i]/hospitalInformationController.review.length),
                    ],
                  ],
                ),
              ],
            ),

            /*Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('최근 리뷰'),
            ),
            reviewWidget('성이름', 3.5, 'ㅁㄴㅇㅇㄻㄴㄴㅁㄹㄴ', DateTime.now(), true),*/

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 1)),
              ),
              child: TextButton(
                  style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero))),
                  onPressed: () {
                    Get.to(()=>HospitalReviewList())?.whenComplete(() {
                      //reloadScreen();
                    });
                  },
                  child: Text('전체보기', style: TextStyle(color: Colors.black),)
              ),
            ),
          ],
        ),
      );
    });
  }
  Widget chartRow(BuildContext context, String label, double pct) {
    return Row(
      children: [
        //Text(label),
        //SizedBox(width: ),
        //Icon(Icons.star, size: 8,),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 5, 8, 0),
          child:
          Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(''),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width / 2)* pct,
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(''),
                ),
              ]

          ),
        ),
        //Text('${pct * 100}%',),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hospitalInformationController.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
        backgroundColor: Colors.white),
      //backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                imageList(),

                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    width: 130,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.white.withAlpha(100)
                      ),
                      onPressed: () async {
                        print('UPLOAD -----------------------------------------------------------');
                        await findAndCropImage();
                        if (_croppedFile != null) {
                          print('NOT NULL UPLOAD -----------------------------------------------------------');
                          uploadImageAlert(context);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            size: 20, Icons.image, color: Colors.black,
                          ),
                          SizedBox(width: 20,),
                          Text('이미지 로드', style: TextStyle(color: Colors.black),)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Obx(() {
                if (hospitalInformationController.isLoading.value) {
                  return Center(child: CircularProgressIndicator(),);
                }
                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.info),
                              SizedBox(width: 10,),
                              Text('병원 정보', style: TextStyle(fontSize: 20),),
                            ],
                          ),
                        ),

                        Text('주소: ${hospitalInformationController.address['address']}',
                          style: TextStyle(fontSize: 15),),
                        Text('추가주소: ${hospitalInformationController.address['detailAddress']}',
                          style: TextStyle(fontSize: 15),),
                        Text('상세주소: ${hospitalInformationController.address['extraAddress']}',
                          style: TextStyle(fontSize: 15),),
                        Text('POSTCODE: ${hospitalInformationController.address['postcode']}',
                          style: TextStyle(fontSize: 15),),
                        Text('전화번호: ${hospitalInformationController.phone}',
                          style: TextStyle(fontSize: 15),),
                        Text('오픈시간: ${hospitalInformationController.openTime}',
                          style: TextStyle(fontSize: 15),),
                        Text('휴식시간: ${hospitalInformationController.breakTime}',
                          style: TextStyle(fontSize: 15),),
                      ],
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: TextButton(
                        style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),),
                        onPressed: () {

                        },
                        child: Row(
                          children: [
                            Text('수정', style: TextStyle(color: Colors.black),),
                            SizedBox(width: 5,),

                            Icon(
                              size: 20, Icons.edit, color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                );
              }),
            ),
            reviewSample(),
          ],
        ),
      ),
    );
  }


}
