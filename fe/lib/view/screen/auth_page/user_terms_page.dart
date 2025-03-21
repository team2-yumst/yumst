import 'package:fe/view/screen/auth_page/terms_detail_page.dart';
import 'package:flutter/material.dart';

class UserTermsPage extends StatefulWidget {
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
      _allAgreed = _ageAgreed &&
          _serviceAgreed &&
          _privacyAgreed &&
          _locationAgreed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('약관 동의')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체 동의
            CheckboxListTile(
              title: Text('전체 동의', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              value: _allAgreed,
              controlAffinity: ListTileControlAffinity.leading,
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
              title: '만 14세 이상입니다 (필수)',
              agreed: _ageAgreed,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsDetailPage(title: '만 14세 이상 동의', content: '',)),
              ),
              onAgreed: (value) => setState(() {
                _ageAgreed = value;
                _updateAllAgreed();
              }),
            ),
            _buildTermRow(
              title: '서비스 이용 약관 동의 (필수)',
              agreed: _serviceAgreed,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsDetailPage(title: '서비스 이용 약관', content: '',)),
              ),
              onAgreed: (value) => setState(() {
                _serviceAgreed = value;
                _updateAllAgreed();
              }),
            ),
            _buildTermRow(
              title: '개인정보 수집/이용 동의 (필수)',
              agreed: _privacyAgreed,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsDetailPage(title: '개인정보 처리 방침', content: '',)),
              ),
              onAgreed: (value) => setState(() {
                _privacyAgreed = value;
                _updateAllAgreed();
              }),
            ),
            _buildTermRow(
              title: '위치기반 서비스 이용약관 (필수)',
              agreed: _locationAgreed,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsDetailPage(title: '위치기반 서비스 약관', content: '',)),
              ),
              onAgreed: (value) => setState(() {
                _locationAgreed = value;
                _updateAllAgreed();
              }),
            ),
            SizedBox(height: 32),
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_ageAgreed && _serviceAgreed && _privacyAgreed && _locationAgreed)
                    ? () => Navigator.pop(context)
                    : null,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('확인', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermRow({
    required String title,
    required bool agreed,
    required VoidCallback onPressed,
    required ValueChanged<bool> onAgreed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              child: Row(
                children: [
                  Text(title, style: TextStyle(color: Colors.black)),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onAgreed(!agreed),
            style: ElevatedButton.styleFrom(
              backgroundColor: agreed ? Colors.blue : Colors.grey,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(agreed ? '동의 완료' : '동의'),
          ),
        ],
      ),
    );
  }
}

