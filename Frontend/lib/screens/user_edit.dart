import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:to_doc/app.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
class UserEdit extends StatefulWidget {
  const UserEdit({super.key});
  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  
  final UserinfoController userController = Get.find<UserinfoController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  
 
  Map<String, String> formData = {};
  final TextEditingController emailController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController addressDetailController = TextEditingController();
  final TextEditingController extraController = TextEditingController();
  
  @override
  void initState() { //바로 전의 값을 채워주기위함.
    
    super.initState();
    print(userController.postcode.value);
    
    postcodeController.text = userController.postcode.value;
    addressController.text = userController.address.value;
    extraController.text = userController.extraAddress.value;
    addressDetailController.text = userController.detailAddress.value;
    idController.text = userController.id.value;
    nicknameController.text = userController.usernick.value;
    emailController.text = userController.email.value;
  
    
  }
  @override
  void dispose() {
    // 컨트롤러들 해제
    idController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nicknameController.dispose();
    emailController.dispose();
    postcodeController.dispose();
    addressController.dispose();
    addressDetailController.dispose();
    extraController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    
    String updatedUserNick = nicknameController.text;
    // String updatedID = idController.text;
    String updatedPW = passwordController.text;
    String updatedConfirmPW = confirmPasswordController.text;
    String updatedEmail = emailController.text;
    String updatedPostCode = postcodeController.text;
    String updatedAddress = addressController.text;
    String updatedExtraAddress = extraController.text;
    String updatedDetail = addressDetailController.text;
  
    if (updatedUserNick.isEmpty || updatedEmail.isEmpty) {
      Get.snackbar('Error', '필드를 채워주세요.');
      return;
        
    }
    if(updatedPW.isNotEmpty && updatedPW.length < 8){
      Get.snackbar('Error', '비밀번호는 8자 이상으로 해주세요.');
      return;
    }
    if(updatedPW != updatedConfirmPW){
      Get.snackbar('Error', '확인 비밀번호가 다릅니다.');
      return;
    }

    bool result = await userController.editInfo(
        updatedUserNick, 
        updatedEmail, 
        updatedPostCode, 
        updatedAddress, 
        updatedDetail, 
        updatedExtraAddress,
        updatedPW, 
        updatedConfirmPW
    );
    if(result){
      // 정보 새로고침
      Get.snackbar('Success', '프로필이 성공적으로 수정되었습니다.');
      Get.back(closeOverlays: true);  // 현재 화면 닫기
      Navigator.pop(context);  // 이전 화면으로 돌아가
    }
    else{
      Get.snackbar('Error', '실패');
      Get.back(closeOverlays: true);
    }
    
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: 
      
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ 
              const Text(
                '프로필 확인 및 수정',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField('ID:', idController, enabled: false),
              buildTextField('Alter Password:', passwordController, isPassword: true),
              buildTextField('Confirm Altered Password:', confirmPasswordController, isPassword: true),
              buildTextField('Nickname:', nicknameController),
              buildAddressFields(),
              buildTextField('Email:', emailController),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
        
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          title: Text('수정하기'), //삭제하기기
                          content: Text('프로필을 수정 하시겠습니까?'),
                          actions: [
                            ElevatedButton(
                              onPressed: _submit
                              ,
                            
                             child: Text('확인'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                  
                              },
                           
                             child: Text('취소'),
                            )
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 212, 212, 212),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    foregroundColor: const Color.fromARGB(255, 58, 68, 58),
                    
                    
                  ),
                  child: const Text(
                    '수정한 내용 저장하기',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    
  }


  Widget buildTextField(String label, TextEditingController controller, {bool enabled = true, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  Widget buildAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Address:'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: postcodeController,
                enabled: false,
                decoration: InputDecoration(
                  
                  hintText: '우편번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                //카카오 
                _searchAddress(context);
              },
              child: const Text('우편번호 찾기'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: addressController,
          enabled: false,
          decoration: InputDecoration(
            hintText: '주소',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: addressDetailController,
          decoration: InputDecoration(
            hintText: '상세주소',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: extraController,
          decoration: InputDecoration(
            hintText: '참고항목',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
} 
