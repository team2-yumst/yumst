import 'package:fe/repository/auth_repository.dart';
import 'package:fe/view/screen/main_page.dart';
import 'package:fe/view/screen/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final authRepo = ref.read(authRepositoryProvider);
    try {
      await authRepo.getUser();
      // 인증 성공 시 메인 화면으로 이동
      _navigateToMain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // 401 Unauthorized: 로그인 화면으로 이동
        authRepo.deleteStorageInfo();
        _navigateToLogin();
      } else {
        // 기타 Dio 에러 발생 시 로그인 화면으로 이동
        authRepo.deleteStorageInfo();
        _navigateToLogin();
      }
    } catch (e) {
      // 기타 에러 발생 시 메인 화면으로 이동
      authRepo.deleteStorageInfo();
      _navigateToLogin();
    }
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경 그라데이션을 위해 Container 사용
      body: Container(
        color: Color(0xFFDA5100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지
              Image.asset(
                'assets/images/yumst_logo.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 50),
              // CircularProgressIndicator 스타일 변경
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
