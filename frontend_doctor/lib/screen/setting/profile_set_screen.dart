import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/auth/doctor_info_controller.dart';

class ProfileSetScreen extends StatefulWidget {

  const ProfileSetScreen({super.key,});

  @override
  _ProfileSetScreenState createState() => _ProfileSetScreenState();
}

class _ProfileSetScreenState extends State<ProfileSetScreen> {
  DoctorInfoController doctorInfoController = Get.put(DoctorInfoController());

  XFile? _pickedFile;
  CroppedFile? _croppedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필 설정')),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container (
            margin: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ImageWidget(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '의사 ${doctorInfoController.name}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        const SizedBox(height: 8),
                        Text('이메일: ${doctorInfoController.email}'),
                        Text('아이디: ${doctorInfoController.id}'),
                        Text('면허번호: ${doctorInfoController.personalID}'),
                      ],
                    ),
                  ),
                ],
              ),
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

        ],
      ),
    );
  }


  void uploadImage() async {
    if (_croppedFile != null) {
      dynamic sendData = _croppedFile?.path;
      await doctorInfoController.uploadProfileImage(sendData);

      //await doctorInfoController.getInfo();
      //setState(() {});
    }

  }

  Widget ImageWidget() {
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 70,
          maxHeight: 70,
        ),
        child: Image.file(File(path)),
      );
    } else if (_pickedFile != null) {
      final path = _pickedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 70,
          maxHeight: 70,
        ),
        child: Image.file(File(path)),
      );
    } else if (doctorInfoController.profileImage.value != '') {
      return Image.network(
        doctorInfoController.profileImage.value,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
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
