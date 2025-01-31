import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/hospital/hospital_information_controller.dart';
import 'package:to_doc/controllers/hospital/hospital_visited_controller.dart';
import 'package:to_doc/screens/hospital/hospital_detail_view.dart';
import 'package:to_doc/screens/hospital/hospital_rating_screen.dart';

class VisitedHospitalScreen extends StatefulWidget {
  const VisitedHospitalScreen({super.key});

  @override
  State<VisitedHospitalScreen> createState() => _VisitedHospitalScreenState();
}

class _VisitedHospitalScreenState extends State<VisitedHospitalScreen> {
  HospitalVisitedController hospitalVisitedController = HospitalVisitedController();
  ScrollController scrollController = ScrollController();

  beforeAsync() async {
    await hospitalVisitedController.getVisitedHospitals();
    setState(() {

    });
  }

  @override
  void initState() {
    beforeAsync();
    super.initState();


  }


  hospitalDetailSheet(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {//(BuildContext context) => HospitalDetailView(),
        return DraggableScrollableSheet(
          expand: false,
          snap: true,
          snapSizes: [0.4, 1.0],
          initialChildSize: 0.4,
          minChildSize: 0.4,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(height: 5000, child: HospitalDetailView(hospital: hospital))
            );
          }
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('방문한 병원들 (가)',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: (hospitalVisitedController.isLoading.value) ? Center(child: CircularProgressIndicator(),)
        : (!hospitalVisitedController.isVisitedHospitalExisted.value) ? Center(child: Text('방문한 병원이 없습니다'))
            : Column(
          children: [
            Container(
              height: 300,
                child: ListView.builder(
                    itemCount: hospitalVisitedController.hospitals.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          hospitalDetailSheet(hospitalVisitedController.hospitals[index]);
                          //Get.to(()=>HospitalRatingScreen());
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
                          ),
                          child: Column(
                              children: [
                                Text(hospitalVisitedController.hospitals[index]['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                //Text(, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                //Text(hospitalVisitedController.hospitals[index]['isPremiumPsy'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                Text(hospitalVisitedController.hospitals[index]['place_id'], style: TextStyle(fontSize: 15, color: Colors.grey),),
                              ],
                        ),
                        ),
                      );
                    }
                ),
            ),
          ],
        ),




      ),

    );
  }
}
