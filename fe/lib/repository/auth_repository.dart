import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fe/data/secure_storage.dart';
import 'package:fe/data/token_interceptor.dart';
import 'package:fe/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();

      if (user == null) {
        return;
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
      } else {

      }
    } catch (e) {
      print(e);
    }
  }

  void signInWithGuest() async {
    try {

      final response = await dio.post(
        'http://localhost:8080/api/user/v1/login/guest',
      );

      if (response.statusCode == 200) {
        addToStorage(response);
      } else {
        print(response.statusCode);
        print(response.statusMessage);
      }
    } catch (e) {
      print(e);
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


}