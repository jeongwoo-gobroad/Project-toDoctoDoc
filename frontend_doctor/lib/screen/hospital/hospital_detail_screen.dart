import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/hospital/hospital_information_controller.dart';


class HospitalDetailScreen extends StatefulWidget {

  const HospitalDetailScreen({super.key,});

  @override
  _HospitalDetailScreenState createState() => _HospitalDetailScreenState();
}


class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  HospitalInformationController hospitalInformationController = Get.put(HospitalInformationController());

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('병원 정보')),
      body: Column(
        //mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade100,
            ),
            child: Obx(() {
              if (hospitalInformationController.isLoading.value) {
                return Center(child: CircularProgressIndicator(),);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospitalInformationController.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const SizedBox(height: 8),
                  Text('주소: ${hospitalInformationController.address['address']}'),
                  Text('추가주소: ${hospitalInformationController.address['detailAddress']}'),
                  Text('상세주소: ${hospitalInformationController.address['extraAddress']}'),
                  Text('POSTCODE: ${hospitalInformationController.address['postcode']}'),
                  Text('전화번호: ${hospitalInformationController.phone}'),
                  Text('오픈시간: ${hospitalInformationController.openTime}'),
                  Text('휴식시간: ${hospitalInformationController.breakTime}'),
                ],
              );
            }),
          ),


          Expanded(
            child: GridView.builder(
              itemCount: hospitalInformationController.psyProfileImage.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
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
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                );

              },
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextButton(
              onPressed: () {
                findAndCropImage();
              },
              child: Row(
                children: [
                  Icon(
                      size: 20, Icons.image
                  ),
                  SizedBox(width: 20,),
                  Text('이미지 로드')
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextButton(
              onPressed: () {
                uploadImage();
              },
              child: Row(
                children: [
                  Icon(
                      size: 20, Icons.upload
                  ),
                  SizedBox(width: 20,),
                  Text('이미지 업로드')
                ],
              ),
            ),
          ),




          Container(color: Colors.blue, height: 5),
          ImageWidget(),
        ],
      ),
    );
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

  Widget ImageWidget() {
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: Image.file(File(path)),
      );
    } else if (_pickedFile != null) {
      final path = _pickedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: Image.file(File(path)),
      );
    }
    else {
      return const SizedBox.shrink();
    }
  }


  Widget UploaderCardWidget() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          width: 320.0,
          height: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DottedBorder(
                    radius: const Radius.circular(12.0),
                    borderType: BorderType.RRect,
                    dashPattern: const [8, 4],
                    color: Theme.of(context).highlightColor.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Theme.of(context).highlightColor,
                            size: 80.0,
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Upload an image to start',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                color:
                                Theme.of(context).highlightColor),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

}
