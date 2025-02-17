import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:kpostal/kpostal.dart';
import 'package:to_doc/controllers/register_controller.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/navigation_menu.dart';




class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Map<String, String> formData = {};
  final UserinfoController user = Get.find<UserinfoController>();
  final TextEditingController idController = TextEditingController(); 
 //추후 수정
  final TextEditingController pwController = TextEditingController(); 
 //추후 수정
  final TextEditingController reEnterPwController = TextEditingController(); 

  final TextEditingController nickNameContoller = TextEditingController();

  final TextEditingController postcodeController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController addressDetailController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController extraController = TextEditingController();

  RegisterController registerController = Get.put(RegisterController());
  _kakaoLogin() {
    print('카카오 로그인 시도');
    Get.snackbar('카카오', '추후구현');
  }

  _submit() async{

    if (idController.text.isEmpty || pwController.text.isEmpty || nickNameContoller.text.isEmpty /*|| postcodeController.text.isEmpty
    || addressController.text.isEmpty || addressDetailController.text.isEmpty */||  emailController.text.isEmpty ) {
      Get.snackbar('Error', '필드를 채워주세요.');
      return;
    }
    print('register debug: ${idController.text} ${emailController.text}');

    if(!emailController.text.contains('@')){
      Get.snackbar('Error', '적절한 이메일 형식이 아닙니다.');
    }

    if(pwController.text.isNotEmpty && pwController.text.length < 8){
      Get.snackbar('Error', '비밀번호는 8자 이상으로 해주세요.');
      return;
    }

    if(pwController.text != reEnterPwController.text){
      Get.snackbar('Error', '확인 비밀번호가 다릅니다.');
      return;
    }
    
    bool isIdAvailable = await registerController.dupidIDCheck(idController.text);
    if (!isIdAvailable) {
      return;
    }
    bool isEmailAvailable = await registerController.dupidEmailCheck(emailController.text);
    if (!isEmailAvailable) {
      return;
    }
    Map result = await registerController.register(
      idController.text, pwController.text, reEnterPwController.text,
      nickNameContoller.text, postcodeController.text, addressController.text, addressDetailController.text, extraController.text,
      emailController.text,
    );
    //test용
    // Map result = await registerController.register(
    //   idController.text, pwController.text, reEnterPwController.text,
    //   nickNameContoller.text, '41196', '대구 동구 경대로 2', '내가 사는곳', extraController.text,
    //   emailController.text,
    // );

    if(result['success']){
      Get.snackbar('Success', '회원가입 성공');
      user.getInfo();
      Get.offAll(()=> NavigationMenu(startScreen : 0));
    }
    else{
      Get.snackbar('Error', '회원가입에 실패했습니다. 다시 시도해주세요.');
      return;
    }
    

  }

  // void _searchAddress(BuildContext context) async {
  //   KopoModel? model = await Navigator.push(
  //     context,
  //     CupertinoPageRoute(
  //       builder: (context) => RemediKopo(),
  //     ),
  //   );

  //     if (model != null) {
  //     final postcode = model.zonecode ?? '';
  //     postcodeController.value = TextEditingValue(
  //       text: postcode,
  //     );
  //     formData['postcode'] = postcode;

  //     final address = model.address ?? '';
  //     addressController.value = TextEditingValue(
  //       text: address,
  //     );
  //     formData['address'] = address;

  //     final buildingName = model.buildingName ?? '';
  //     addressDetailController.value = TextEditingValue(
  //       text: buildingName,
  //     );
  //     formData['address_detail'] = buildingName;
  //   }
  // }

  @override
  void dispose() {
    // 컨트롤러들 해제
    idController.dispose();
    pwController.dispose();
    reEnterPwController.dispose();
    nickNameContoller.dispose();
    emailController.dispose();
    postcodeController.dispose();
    addressController.dispose();
    addressDetailController.dispose();
    extraController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
                const SizedBox(height: 40),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4044),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      TextField(
                        controller: idController,
                        decoration: InputDecoration(
                          hintText: '아이디를 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: pwController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: reEnterPwController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 다시 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Nickname Field
                      TextField(
                        controller: nickNameContoller,
                        decoration: InputDecoration(
                          hintText: '닉네임을 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                     
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              enabled: false,
                              controller: postcodeController,
                              decoration: InputDecoration(
                                hintText: '우편번호',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context){
                                  return KpostalView(
                                    callback: (Kpostal result){
                                      postcodeController.text = result.postCode;
                                      addressController.text = result.address;
                                    }
                                  );
                                },
                              ));
                            }, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 212, 212, 212),
                              foregroundColor: const Color.fromARGB(255, 35, 40, 35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '우편번호 찾기',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        enabled: false,
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: '주소',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: addressDetailController,
                        decoration: InputDecoration(
                          hintText: '상세 주소',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: '이메일을 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: extraController,
                        decoration: InputDecoration(
                          hintText: '참고항목',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 212, 212, 212),
                            foregroundColor: const Color.fromARGB(255, 35, 40, 35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: _kakaoLogin,
                          child: Image.asset(
                            'asset/images/kakao_login_large_wide.png',
                            //fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}