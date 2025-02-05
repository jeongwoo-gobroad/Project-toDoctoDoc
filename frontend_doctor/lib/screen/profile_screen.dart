import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:to_doc_for_doc/controllers/auth/doctor_info_controller.dart';
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
    await doctorInfoController.getInfo();
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
      appBar: AppBar(title: Text('내 프로필', style: TextStyle(fontWeight: FontWeight.bold),),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
      
            Card(
              color: Colors.grey.shade100,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    if (doctorInfoController.profileImage.value != '') ... [
                      Image.network(
                          doctorInfoController.profileImage.value,
                        width: 80,
                        height: 80,
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

                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '의사 ${doctorInfoController.name}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                            ),

                            TextButton(
                              onPressed: () {
                                Get.to(()=>ProfileSetScreen())?.whenComplete(() {
                                  reloadScreen();
                                });
                              },
                              child: Icon(Icons.edit, size: 20,),
                            ),

                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('이메일: ${doctorInfoController.email}'),
                        Text('아이디: ${doctorInfoController.id}'),
                        Text('면허번호: ${doctorInfoController.personalID}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey.shade100,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.local_hospital, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Obx(() {
                      if (hospitalInformationController.isLoading.value) {
                        return Center(child: CircularProgressIndicator(),);
                      }
                      return Expanded(
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
                        );
                    }
                    ),
                  ],
                ),
              ),
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
      ),
    );
  }
}