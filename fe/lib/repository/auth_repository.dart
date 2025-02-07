import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fe/data/secure_storage.dart';
import 'package:fe/data/token_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

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

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();

      if (user == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await user.authentication;

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/user/v1/login/google'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accessToken' : googleAuth.accessToken,
          'idToken' : googleAuth.idToken,
        }),
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
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/user/v1/login/guest'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
        }),
      );

      if (response.statusCode == 200) {
        addToStorage(response);
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  void addToStorage(http.Response response) {
    var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    print(responseBody);
    String? accessToken = response.headers['access'];
    print(accessToken);
    storage.saveAccessToken(accessToken!);

    String userId = responseBody['userId'];
    storage.saveUserId(userId);

    String email = responseBody['email'];
    storage.saveEmail(email);

    String name = responseBody['name'];
    storage.saveUserName(name);
  }


}