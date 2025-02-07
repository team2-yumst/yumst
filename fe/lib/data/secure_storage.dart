import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage storage(Ref ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) {
  final FlutterSecureStorage storage = ref.read(storageProvider);
  return SecureStorage(storage: storage);
}

class SecureStorage {
  final FlutterSecureStorage storage;
  SecureStorage({
    required this.storage,
  });

  Future<void> saveEmail(String email) async {
    try {
      await storage.write(key: 'email', value: email);
      if (kDebugMode) {
        print('[Secure Storage] email: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print("[ERR] Email 저장 실패: $e");
      }
    }
  }

  Future<String?> readEmail() async {
    try {
      final email = await storage.read(key: 'email');
      return email;
    } catch (e) {
      if (kDebugMode) {
        print("[ERR] Email 불러오기 실패: $e");
      }
      return null;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await storage.write(key: 'userId', value: userId);
      if (kDebugMode) {
        print('[Secure Storage] userId: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print("[ERR] UserId 저장 실패: $e");
      }
    }
  }

  Future<String?> readUserId() async {
    try {
      final userId = await storage.read(key: 'userId');
      return userId;
    } catch (e) {
      if (kDebugMode) {
        print("[ERR] UserId 불러오기 실패: $e");
      }
      return null;
    }
  }

  Future<void> saveAccessToken(String accessToken) async {
    try {
      await storage.write(key: 'accessToken', value: accessToken);
      if (kDebugMode) {
        print('[Secure Storage] accessToken: $accessToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print("[ERR] AccessToken 저장 실패: $e");
      }
    }
  }

  Future<String?> readAccessToken() async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      return accessToken;
    } catch (e) {
      if (kDebugMode) {
        print("[ERR] accessToken 불러오기 실패: $e");
      }
      return null;
    }
  }


  Future<void> saveUserName(String userName) async {
    try {
      await storage.write(key: 'userName', value: userName);
      if (kDebugMode) {
        print('[Secure Storage] userName: $userName');
      }
    } catch (e) {
      if (kDebugMode) {
        print("[ERR] UserName 저장 실패: $e");
      }
    }
  }

  Future<String?> readUserName() async {
    try {
      final userName = await storage.read(key: 'userName');
      return userName;
    } catch (e) {
      if (kDebugMode) {
        print("[ERR] UserName 불러오기 실패: $e");
      }
      return null;
    }
  }


}