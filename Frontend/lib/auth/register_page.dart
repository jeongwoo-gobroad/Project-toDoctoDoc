import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:to_doc/controllers/register_controller.dart';
import 'package:to_doc/navigation_menu.dart';




class RegisterPage extends StatelessWidget {

  RegisterPage({super.key});
  Map<String, String> formData = {};
  final TextEditingController idController = TextEditingController(); //추후 수정
  final TextEditingController pwController = TextEditingController(); //추후 수정
  final TextEditingController reEnterPwController = TextEditingController(); 
  final TextEditingController nickNameContoller = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController addressDetailController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController extraController = TextEditingController();
  RegisterController registerController = Get.put(RegisterController());

  _submit() async{
    Map result = await registerController.register(
      idController.text, pwController.text, reEnterPwController.text,
      nickNameContoller.text, postcodeController.text, addressController.text, addressDetailController.text, extraController.text,
      emailController.text,
    );
    if(result['success']){
      SnackBar(content: Text('회원가입 성공'),);
      Get.offAll(()=> NavigationMenu());
    }
    else{
      SnackBar(content: Text('회원가입 실패'),);
    }

  }

  void _searchAddress(BuildContext context) async {
    KopoModel? model = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => RemediKopo(),
      ),
    );

      if (model != null) {
      final postcode = model.zonecode ?? '';
      postcodeController.value = TextEditingValue(
        text: postcode,
      );
      formData['postcode'] = postcode;

      final address = model.address ?? '';
      addressController.value = TextEditingValue(
        text: address,
      );
      formData['address'] = address;

      final buildingName = model.buildingName ?? '';
      addressDetailController.value = TextEditingValue(
        text: buildingName,
      );
      formData['address_detail'] = buildingName;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            SizedBox(height: 20),

            TextField(
              controller: pwController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            SizedBox(height: 20),
            TextField(
              controller: reEnterPwController,
              decoration: InputDecoration(labelText: 'ReEnter Password'),
              obscureText: true,
            ),

            TextField(
              controller: nickNameContoller,
              decoration: InputDecoration(labelText: 'NickName'),
            ),
            SizedBox(height: 20),
            
            /*주소검색*/
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: postcodeController,
                    decoration: InputDecoration(hintText: '우편번호'),
                    readOnly: true,
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    

                  ),
                  onPressed: (){
                    _searchAddress(context);
                  },
                  child: Text('우편번호 찾기') 
                ),
              ],
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(hintText: '주소'),
              readOnly: true,
            ),
            TextField(
              controller: addressDetailController,
              decoration: InputDecoration(hintText: '상세주소'),
              
            ),
            TextField(
              controller: extraController,
              decoration: InputDecoration(hintText: '참고'),

            ),

            TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: '이메일'),
      
            ),

            ElevatedButton(
              onPressed: (){},
              child: Text('로그인'),
            ),

            ElevatedButton(
              onPressed: _submit,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}