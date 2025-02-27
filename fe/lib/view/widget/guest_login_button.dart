import 'package:fe/repository/auth_repository.dart';
import 'package:fe/view/screen/register_first_selection_page.dart';
import 'package:fe/view/widget/dialog.dart';
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
              // UDialog를 사용하여 확인 다이얼로그 띄우기
              UDialog.confirm(
                context,
                title: '비회원 로그인',
                content: '비회원으로 로그인하시겠습니까? \n 비회원으로 시작하면 로그아웃 시\n모든 데이터가 삭제됩니다.',
                negative: DialogAction('취소', () {
                  // 취소 버튼 클릭 시 단순 dismiss
                  return true;
                }),
                positive: DialogAction('계속', () {
                  // 확인 버튼 클릭 시 비동기로 게스트 로그인 진행
                  authRepository.signInWithGuest().then((success) {
                    if (success) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FirstRegisterSelection(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('게스트 로그인에 실패했습니다.')),
                      );
                    }
                  });
                  return true;
                }),

              );
            },
            child: Container(
              width: buttonWidth,
              height: buttonHeight,
              decoration: ShapeDecoration(
                color: Colors.white30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: logoSize,
                    height: logoSize,
                  ),
                  SizedBox(width: buttonWidth * 0.03), // Responsive spacing
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
