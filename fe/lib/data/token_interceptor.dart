import 'package:fe/data/secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

part 'token_interceptor.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageProvider);

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
    if (options.headers['accessToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('accessToken');
      final token = await storage.readAccessToken();
      if (kDebugMode) {
        print('[BEFORE_REQ_HEADER] ${options.headers}');
      }
      // 실제 토큰으로 대체
      options.headers.addAll({
        'access': token,
      });
      if (kDebugMode) {
        print('[REQ_HEADER] ${options.headers}');
      }
      if (kDebugMode) {
        print('[REQ_DATA] ${options.data}');
      }
    }

    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');
    }
    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri} ');

    return super.onError(err, handler);
  }
}