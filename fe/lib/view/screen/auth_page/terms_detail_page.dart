import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle 사용

class TermsDetailPage extends StatefulWidget {
  final String title;
  final String assetPath; // 불러올 파일 경로

  const TermsDetailPage({Key? key, required this.title, required this.assetPath}) : super(key: key);

  @override
  _TermsDetailPageState createState() => _TermsDetailPageState();
}

class _TermsDetailPageState extends State<TermsDetailPage> {
  late Future<String> _termsContent;

  @override
  void initState() {
    super.initState();
    _termsContent = rootBundle.loadString(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<String>(
        future: _termsContent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('약관을 불러오는데 실패했습니다.'));
          } else {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(snapshot.data ?? ''),
            );
          }
        },
      ),
    );
  }
}
