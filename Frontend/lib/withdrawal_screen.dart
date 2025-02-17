import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/provider/auth_provider.dart';
import 'package:to_doc/screens/intro.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  bool _isAgreed = false;
  UserinfoController userController = Get.find<UserinfoController>();
  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color.fromARGB(255, 225, 234, 205);

    return Scaffold(
      appBar: AppBar(
        title: const Text('탈퇴하기'),
        centerTitle: true,
        
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${userController.usernick}님, 탈퇴 전 확인하세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '지금 탈퇴하시면 모든 서비스를 더 이상 이용하실 수 없으며,\n'
              '계정 및 연관된 모든 정보를 삭제합니다.\n'
              '이 작업은 복구가 불가능합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• '),
                Expanded(
                  child: Text(
                    '유의 사항',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• '),
                Expanded(
                  child: Text(
                    '안내 사항',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAgreed = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    '회원탈퇴 안내사항을 모두 확인하였으며, 이에 동의합니다.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isAgreed
                    ? () async {
                        final authProvider = Get.put(AuthProvider(dio: Dio()));
                        bool result = await authProvider.withdrawalAccount();
                        if(result){
                          Get.snackbar('성공', '회원탈퇴 성공');
                          Get.offAll(() => Intro());
                          
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor, 
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text(
                  '탈퇴하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
