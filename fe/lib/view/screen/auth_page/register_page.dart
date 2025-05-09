import 'package:fe/view/widget/apple_login_button.dart';
import 'package:fe/view/widget/google_login_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widget/guest_login_button.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Container(
          color: Color(0xFFDA5100),
          padding: EdgeInsets.only(top: 170, bottom: 90, left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: Center(
                  child: Text(
                    "Yums",
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

