import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:to_doc_for_doc/controllers/auth/doctor_info_controller.dart';
import 'package:to_doc_for_doc/screen/hospital/hospital_detail_screen.dart';
import 'package:to_doc_for_doc/screen/setting/profile_set_screen.dart';

import '../controllers/hospital/hospital_information_controller.dart';


class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  DoctorInfoController doctorInfoController = Get.put(DoctorInfoController());
  HospitalInformationController hospitalInformationController = Get.put(HospitalInformationController());


  void reloadScreen() async {
    doctorInfoController.getInfo();
    hospitalInformationController.getInfo();
    setState(() {});
  }


  @override
  void initState() {
    hospitalInformationController.getInfo();
    doctorInfoController.getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey.shade100,
        title: Text(
          '내 프로필',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Row(
                    children: [
                      if (doctorInfoController.profileImage.value != '') ... [
                        Image.network(
                            doctorInfoController.profileImage.value,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ]
                      else ... [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                      ],
                      const SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '의사 ${doctorInfoController.name}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, height: 1),
                          ),
                          const SizedBox(height: 5),
                          Text('이메일: ${doctorInfoController.email}'),
                          Text('아이디: ${doctorInfoController.id}'),
                          Text('면허번호: ${doctorInfoController.personalID}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
                  ),
                  child: TextButton(
                      style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero))),
                      onPressed: () {
                        Get.to(()=>ProfileSetScreen())?.whenComplete(() {
                          reloadScreen();
                        });
                      },
                      child: Text('자세히 보기', style: TextStyle(color: Colors.black),)
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            //width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
                color: Colors.white
            ),
            child: Obx(() {
              if (hospitalInformationController.isLoading.value) {
                return Center(child: CircularProgressIndicator(),);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospitalInformationController.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        const SizedBox(height: 8),
                        Text('주소: (${hospitalInformationController.address['address']}) ${hospitalInformationController.address['detailAddress']}'),
                        Text('상세주소: ${hospitalInformationController.address['extraAddress']}, ${hospitalInformationController.address['postcode']}'),
                        Text('전화번호: ${hospitalInformationController.phone}'),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
                    ),
                    child: TextButton(
                        style: TextButton.styleFrom(
                           shape: const RoundedRectangleBorder(
                           borderRadius: BorderRadius.all(Radius.zero))),
                        onPressed: () {
                          hospitalInformationController.getReviewList();
                          Get.to(()=>HospitalDetailScreen())?.whenComplete(() {
                            reloadScreen();
                          });
                        },
                        child: Text('자세히 보기', style: TextStyle(color: Colors.black),)
                    ),
                  ),
                ],
              );
            }),

          ),
          const SizedBox(height: 24),
          //프리미엄 버튼

          if (!hospitalInformationController.isPremiumPsy) ... [
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  '프리미엄 병원 신청하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}