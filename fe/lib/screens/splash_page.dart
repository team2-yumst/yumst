import 'package:fe/screens/register_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 앱 초기화 로직
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 필요한 초기화 작업들 (토큰 체크, 데이터 로드 등)
    await Future.delayed(Duration(seconds: 2)); // 최소 2초 대기

    // 메인 화면 or 로그인 화면으로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            // 로딩 인디케이터
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}