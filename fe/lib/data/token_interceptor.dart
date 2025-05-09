import 'package:fe/data/secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

part 'token_interceptor.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageProvider);

  final apiUrl = dotenv.get("API_URL");
  dio.options = BaseOptions(
    baseUrl: apiUrl,
  );
  dio.interceptors.add(TokenInterceptor(
    ref: ref,
    storage: storage,
  ));
  return dio;
}

class TokenInterceptor extends Interceptor {
  final SecureStorage storage;
  final Ref ref;

  TokenInterceptor({
    required this.storage,
    required this.ref,
  });

  // 1) 요청을 보낼때
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      print('[REQ] [${options.method}] ${options.uri}');
    }
    final token = await storage.readAccessToken();
    final userId = await storage.readUserId();
    if (kDebugMode) {
      print('[BEFORE_REQ_HEADER] ${options.headers}');
    }
    options.headers.addAll({
      'access': token,
      'userId': userId,
    });
    if (kDebugMode) {
      print('[REQ_HEADER] ${options.headers}');
    }
    if (kDebugMode) {
      print('[REQ_DATA] ${options.data}');
    }

    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('[RES_STATUS] ${response.statusCode}');
      print('[RES_HEADER] ${response.headers}');
      print('[RES_DATA] ${response.data}');
      print(
          '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');
    }

    if (response.headers['access'] != null) {
      storage.saveAccessToken(response.headers['access']!.first);
    }

    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('[ERR_URI] [${err.requestOptions.method}] ${err.requestOptions.uri} ');
    print('[ERR] ${err.response?.data}');

    return super.onError(err, handler);
  }
}