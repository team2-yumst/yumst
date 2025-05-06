
import 'package:dio/dio.dart';
import 'package:fe/data/secure_storage.dart';
import 'package:fe/data/token_interceptor.dart';
import 'package:fe/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(
    dio: dio,
    storage: storage,
  );
}

class AuthRepository {
  AuthRepository({
    required this.dio,
    required this.storage,
  });
  final Dio dio;
  final SecureStorage storage;


  Future<User> getUser() async {
    final response = await dio.get('http://localhost:8080/api/user/v1');

    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    } else {
      throw Exception('유저 정보를 불러오는데 실패했습니다.');
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();

      if (user == null) {
        throw Exception('Google 로그인에 실패했습니다.');
      }

      final GoogleSignInAuthentication googleAuth = await user.authentication;

      final response = await dio.post(
        'http://localhost:8080/api/user/v1/login/google',
        data: {
          'accessToken' : googleAuth.accessToken,
          'idToken' : googleAuth.idToken,
        },
      );

      if (response.statusCode == 200) {
        addToStorage(response);
        return User.fromJson(response.data);

      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print(response.statusMessage);
        }
        throw Exception('Google 로그인에 실패했습니다.');
      }
    } catch (e) {
      print(e);
      throw Exception('Google 로그인에 실패했습니다.');
    }
  }

  Future<User> signInWithApple() async {

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: 'YSZ4DR5598.yumst.com',
            redirectUri: Uri.parse('https://dirt-cosmic-app.glitch.me/callbacks/sign_in_with_apple'),
          ),
      );

      print(credential);

      final response = await dio.post(
        'http://localhost:8080/api/user/v1/login/apple',
        data: {
          'accessToken' : credential.authorizationCode,
          'idToken' : credential.identityToken,
        },
      );

      if (response.statusCode == 200) {
        addToStorage(response);
        return User.fromJson(response.data);

      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print(response.statusMessage);
        }
        throw Exception('Apple 로그인에 실패했습니다.');
      }
    } catch (e) {
      print(e);
      throw Exception('Apple 로그인에 실패했습니다.');
    }
  }

  Future<bool> signInWithGuest() async {
    try {
      final response = await dio.post(
        'http://localhost:8080/api/user/v1/login/guest',
      );

      if (response.statusCode == 200) {
        addToStorage(response);
        return true;
      } else {
        print(response.statusCode);
        print(response.statusMessage);
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  void addToStorage(Response response) {

    var accessToken = response.headers['access'];
    storage.saveAccessToken(accessToken!.first);

    String userId = response.data['userId'];
    storage.saveUserId(userId);

    String email = response.data['email'];
    storage.saveEmail(email);

    String name = response.data['name'];
    storage.saveUserName(name);
  }

  deleteStorageInfo() {
    storage.deleteAccessToken();
    storage.deleteUserId();
    storage.deleteEmail();
    storage.deleteUserName();
  }


  Future<bool> submitRegistrationData(Map<String, dynamic> data) async {
    try {
      // 데이터 변환
      final requestData = {
        "preferences": [
          ...data['step1'] as List<String>,
          ...data['step2'] as List<String>,
          ...data['step3'] as List<String>,
        ]
      };

      final response = await dio.post(
        "http://localhost:8080/api/user/v1/register/survey",
        data: requestData,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error submitting data: ${e.message}');
      return false;
    }
  }

  sendLogout() async {
    await dio.post('http://localhost:8080/api/user/v1/logout');
    deleteStorageInfo();
  }


  Future<bool> agreeTerms() async {
    try {
      final response = await dio.post(
          'http://localhost:8080/api/user/v1/register/agree'
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


}