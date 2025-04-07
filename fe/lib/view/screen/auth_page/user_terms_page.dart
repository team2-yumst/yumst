import 'package:fe/view/screen/auth_page/survey_first_page.dart';
import 'package:fe/view/screen/auth_page/terms_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe/repository/auth_repository.dart';
import 'package:fe/view/screen/main_page.dart';

class UserTermsPage extends ConsumerStatefulWidget {
  const UserTermsPage({super.key});

  @override
  ConsumerState<UserTermsPage> createState() => _UserTermsPageState();
}

class _UserTermsPageState extends ConsumerState<UserTermsPage> {
  bool _allAgreed = false;
  bool _ageAgreed = false;
  bool _serviceAgreed = false;
  bool _privacyAgreed = false;
  bool _locationAgreed = false;
  bool _isSubmitting = false;

  void _updateAllAgreed() {
    setState(() {
      _allAgreed =
          _ageAgreed && _serviceAgreed && _privacyAgreed && _locationAgreed;
    });
  }

  // 제목에 포함된 (필수) 텍스트만 주황색으로 처리하는 헬퍼 함수
  List<TextSpan> _buildTermTitle(String title) {
    if (title.startsWith('(필수)')) {
      String rest = title.substring('(필수)'.length).trimLeft();
      return [
        TextSpan(
            text: '(필수)  ',
            style: TextStyle(color: Color(0xFFDA5100), fontSize: 16)),
        TextSpan(
            text: rest, style: TextStyle(color: Colors.black, fontSize: 16)),
      ];
    } else {
      return [
        TextSpan(
            text: title, style: TextStyle(color: Colors.black, fontSize: 16))
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체 동의 (체크박스를 오른쪽에 배치하며 여백 조정)
            CheckboxListTile(
              contentPadding: EdgeInsets.only(right: 8, left: 8),
              title: Text('전체 동의',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              value: _allAgreed,
              controlAffinity: ListTileControlAffinity.trailing,
              onChanged: (value) {
                setState(() {
                  _allAgreed = value!;
                  _ageAgreed = value;
                  _serviceAgreed = value;
                  _privacyAgreed = value;
                  _locationAgreed = value;
                });
              },
            ),
            Divider(thickness: 2),
            SizedBox(height: 16),
            // 개별 약관 동의
            _buildTermRow(
              title: '(필수)  만 14세 이상입니다',
              agreed: _ageAgreed,
              onAgreed: (value) {
                setState(() {
                  _ageAgreed = value;
                  _updateAllAgreed();
                });
              },
            ),
            _buildTermRow(
              title: '(필수)  서비스 이용 약관 동의',
              agreed: _serviceAgreed,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TermsDetailPage(
                        title: '서비스 이용 약관',
                        content: '서비스 이용 약관 내용입니다. (추후 로드)')),
              ),
              onAgreed: (value) {
                setState(() {
                  _serviceAgreed = value;
                  _updateAllAgreed();
                });
              },
            ),
            _buildTermRow(
              title: '(필수)  개인정보 수집/이용 동의',
              agreed: _privacyAgreed,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TermsDetailPage(
                        title: '개인정보 처리 방침',
                        content: '개인정보 처리 방침 내용입니다. (추후 로드)')),
              ),
              onAgreed: (value) {
                setState(() {
                  _privacyAgreed = value;
                  _updateAllAgreed();
                });
              },
            ),
            _buildTermRow(
              title: '(필수)  위치기반 서비스 이용약관',
              agreed: _locationAgreed,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TermsDetailPage(
                        title: '위치기반 서비스 약관',
                        content: '위치기반 서비스 약관 내용입니다. (추후 로드)')),
              ),
              onAgreed: (value) {
                setState(() {
                  _locationAgreed = value;
                  _updateAllAgreed();
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: (_ageAgreed &&
                _serviceAgreed &&
                _privacyAgreed &&
                _locationAgreed)
            ? _submitAgreement
            : null,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) return Colors.grey;
            return Color(0xFFDA5100);
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('확인', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Future<void> _submitAgreement() async {
    setState(() {
      _isSubmitting = true; // 로딩 시작
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      // 1. 약관 동의 API 호출
      final agreeSuccess = await authRepository.agreeToTerms();

      if (agreeSuccess) {
        // 2. 약관 동의 성공 시, 최신 사용자 정보 조회
        try {
          final user = await authRepository.getUser();

          // 3. 설문조사 완료 여부에 따라 분기
          if (user.finishedSurvey == false) {
            // 설문 미완료 시 -> SurveyFirst 페이지로 이동
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SurveyFirst()),
              (route) => false,
            );
          } else {
            // 설문 완료 시 -> MainScreen으로 이동
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          }
        } catch (e) {
          // 사용자 정보 조회 실패 시 에러 메시지
          print("Error fetching user after agreeing terms: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사용자 정보를 가져오는데 실패했습니다.')),
          );
        }

      } else {
        // 약관 동의 API 실패 시 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('약관 동의 처리 중 오류가 발생했습니다.')),
        );
      }
    } catch (e) {
      // 기타 예외 발생 시 에러 메시지 표시
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('오류가 발생했습니다: $e')),
       );
    } finally {
      // 로딩 상태 해제
      if(mounted) {
         setState(() {
           _isSubmitting = false;
         });
      }
    }
  }

  Widget _buildTermRow({
    required String title,
    required bool agreed,
    VoidCallback? onPressed,
    required ValueChanged<bool> onAgreed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
              child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: _buildTermTitle(title),
                    ),
                  ),
                  if (onPressed != null)
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          // 체크박스로 동의 여부 표시
          Checkbox(
            value: agreed,
            onChanged: (bool? value) {
              onAgreed(value!);
            },
          ),
        ],
      ),
    );
  }
}