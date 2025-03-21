import 'package:flutter/material.dart';

class TermsDetailPage extends StatelessWidget {
  final String title;
  final String content;

  TermsDetailPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Text('여기에 $title 내용이 표시됩니다.', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}