import 'package:fe/view/screen/auth_page/survey_first_page.dart';
import 'package:fe/view/screen/auth_page/terms_detail_page.dart';
import 'package:flutter/material.dart';

class UserTermsPage extends StatefulWidget {
  const UserTermsPage({super.key});

  @override
  _UserTermsPageState createState() => _UserTermsPageState();
}

class _UserTermsPageState extends State<UserTermsPage> {
  bool _allAgreed = false;
  bool _ageAgreed = false;
  bool _serviceAgreed = false;
  bool _privacyAgreed = false;
  bool _locationAgreed = false;

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
                        assetPath: 'assets/terms/service_term.txt')),
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
                        assetPath: 'assets/terms/privacy_policy.txt')),
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
                        assetPath: 'assets/terms/location_term.txt')),
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
            ? () => Navigator.pop(context,
                MaterialPageRoute(builder: (context) => const SurveyFirst()))
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
