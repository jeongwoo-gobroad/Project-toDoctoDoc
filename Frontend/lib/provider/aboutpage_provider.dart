import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AboutpageProvider extends GetxController{

  var aboutData = RxString("");
  var isLoading = false.obs;




  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAboutPage();
  }

  Future<void> fetchAboutPage() async {
    isLoading.value = true;
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/about'),
      headers: {
        'Content-Type': 'application/json',
        //token?

      },
    );

    if(response.statusCode==200){
      final data = json.decode(response.body);
      //print(data);
      aboutData.value = data['content']['string'];
      print(aboutData);
    }
    isLoading.value = false;




    



  }


}