import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage;
  SecureStorage({required this.storage,});

  //  리프레시 토큰 저장
  Future<void> savePushToken(String pushToken) async {
    try {
      print('[SECURE_STORAGE] savePushToken: $pushToken');
      await storage.write(key: 'push_token', value: pushToken);
    } catch (e) {
      print("[ERR] PushToken 저장 실패: $e");
    }
  }
  Future<String?> readPushToken() async {
    try {
      final refreshToken = await storage.read(key: 'push_token');
      print('[SECURE_STORAGE] readPushToken: $refreshToken');
      return refreshToken;
    } catch (e) {
      print("[ERR] PushToken 불러오기 실패: $e");
      return null;
    }
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      print('[SECURE_STORAGE] saveRefreshToken: $refreshToken');
      await storage.write(key: 'ref_token', value: refreshToken);
    } catch (e) {
      print("[ERR] RefreshToken 저장 실패: $e");
    }
  }

  // 리프레시 토큰 불러오기
  Future<String?> readRefreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'ref_token');
      print('[SECURE_STORAGE] readRefreshToken: $refreshToken');
      return refreshToken;
    } catch (e) {
      print("[ERR] RefreshToken 불러오기 실패: $e");
      return null;
    }
  }

  // 에세스 토큰 저장
  Future<void> saveAccessToken(String accessToken) async {
    try {
      print('[SECURE_STORAGE] saveAccessToken: $accessToken');
      await storage.write(key: 'jwt_token', value: accessToken);
    } catch (e) {
      print("[ERR] AccessToken 저장 실패: $e");
    }
  }

  // 에세스 토큰 불러오기
  Future<String?> readAccessToken() async {
    try {
      final accessToken = await storage.read(key: 'jwt_token');
      print('[SECURE_STORAGE] readAccessToken: $accessToken');
      return accessToken;
    } catch (e) {
      print("[ERR] AccessToken 불러오기 실패: $e");
      return null;
    }
  }

  Future<void> userSave(String userid, String password) async {
    await storage.write(key: 'userid', value: userid);
    await storage.write(key: 'password', value: password);
  }

  Future<String?> readUserId() async{
    final userId = await storage.read(key: 'userid');

    return userId;
  }

  Future<String?> readUserPw() async {
    final password = await storage.read(key: 'password');

    return password;
  }

  Future<void> deleteEveryToken() async {
    await storage.deleteAll();
  }
}