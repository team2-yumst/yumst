import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions
        final buttonWidth = constraints.maxWidth * 0.9; // 90% of parent width
        final buttonHeight = buttonWidth * 0.148; // Maintain proportional height
        final logoSize = buttonHeight * 0.54; // Proportional logo size
        final textSize = buttonHeight * 0.375; // Proportional text size

        return Center(
          child: InkWell(
            onTap: () async {
              final GoogleSignInAccount? user = await GoogleSignIn().signIn();
              if (user != null) {
                print(user.displayName);
                print(user.email);
                print(user.photoUrl);
              }
            },
            child: Container(
              width: buttonWidth,
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
                    'Google로 시작하기',
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