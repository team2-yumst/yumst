import 'package:flutter/material.dart';

class AppleLoginButton extends StatelessWidget {
  const AppleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth * 0.9;
        final buttonHeight = buttonWidth * 0.148;
        final logoSize = buttonHeight * 0.54;
        final textSize = buttonHeight * 0.375;

        return Column(
          children: [
            Container(
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
                  // Apple Logo
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://img.icons8.com/ios-filled/50/mac-os.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: buttonWidth * 0.03),
                  // Text
                  Text(
                    'Apple로 시작하기',
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
          ],
        );
      },
    );
  }
}