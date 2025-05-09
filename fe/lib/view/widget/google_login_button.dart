
import 'package:fe/repository/auth_repository.dart';
import 'package:fe/view/screen/auth_page/user_terms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screen/auth_page/survey_first_page.dart';
import '../screen/main_page.dart';

class GoogleLoginButton extends ConsumerWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authRepository = ref.watch(authRepositoryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions
        final buttonWidth = constraints.maxWidth * 0.9; // 90% of parent width
        final buttonHeight = buttonWidth * 0.148; // Maintain proportional height
        final logoSize = buttonHeight * 0.54; // Proportional logo size
        final textSize = buttonHeight * 0.4; // Proportional text size

        return Center(
          child: InkWell(
            onTap: () async {
              final user = await authRepository.signInWithGoogle();

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
            child: Container(
              // width: buttonWidth,
              height: buttonHeight,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Logo
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://img.icons8.com/color/48/google-logo.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: buttonWidth * 0.03), // Responsive spacing
                  // Text
                  Text(
                    'Sign in with Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: textSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}