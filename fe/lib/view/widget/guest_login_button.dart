import 'package:fe/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuestLoginButton extends ConsumerWidget {
  const GuestLoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authRepository = ref.watch(authRepositoryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions
        final buttonWidth = constraints.maxWidth * 0.9; // 90% of parent width
        final buttonHeight = buttonWidth * 0.148; // Maintain proportional height
        final logoSize = buttonHeight * 0.54; // Proportional logo size
        final textSize = buttonHeight * 0.375; // Proportional text size

        return Center(
          child: InkWell(
            onTap: () {
              authRepository.signInWithGuest();
            },
            child: Container(
              width: buttonWidth,
              height: buttonHeight,
              decoration: ShapeDecoration(
                color: Colors.white30,
                shape: RoundedRectangleBorder(
                  // side: BorderSide(width: 1, color: Colors.white),
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
                  ),
                  SizedBox(width: buttonWidth * 0.03), // Responsive spacing
                  // Text
                  Text(
                    '비회원으로 시작하기',
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