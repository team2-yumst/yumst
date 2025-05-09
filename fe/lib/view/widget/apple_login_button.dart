import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../repository/auth_repository.dart';
import '../screen/auth_page/survey_first_page.dart';
import '../screen/auth_page/user_terms_page.dart';
import '../screen/main_page.dart';

class AppleLoginButton extends ConsumerWidget {
  const AppleLoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authRepository = ref.watch(authRepositoryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth * 0.9;
        final buttonHeight = buttonWidth * 0.148;

        return SignInWithAppleButton
          (
          onPressed: () async {
            final user = await authRepository.signInWithApple();

            // 약관 동의 체크
            if (user.agreedPrivacyPolicy == false) {
              // 약관 동의 페이지로 이동
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => UserTermsPage()),
              );
            } else if (user.finishedSurvey == false) {
              // 설문 페이지로 이동
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SurveyFirst()),
              );
            } else if (user.enabled == true) {
              // 메인 화면으로 이동
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            }
          },
          style: SignInWithAppleButtonStyle.white,
          height: buttonHeight,
          borderRadius: BorderRadius.circular(6),
        );


      },
    );
  }
}