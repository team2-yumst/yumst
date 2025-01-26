import 'package:fe/widgets/apple_login_button.dart';
import 'package:fe/widgets/google_login_button.dart';
import 'package:fe/widgets/guest_login_button.dart';
import 'package:flutter/material.dart';

import '../data/login_platform.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  LoginPlatform _loginPlatform = LoginPlatform.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: Color(0xFFE86111),
          padding: EdgeInsets.only(top: 170, bottom: 90),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: Center(
                  child: Text(
                    "Yumst",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GoogleLoginButton(),
                    AppleLoginButton(),
                    GuestLoginButton(),
                  ],
                ),
              ),

            ],
          ),
        ));
  }
}
