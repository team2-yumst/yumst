import 'package:fe/view/screen/recommendation_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    RecommendationPage(),
    Center(child: Text('투표페이지는 준비중입니다')),
    Center(child: Text('프로필 페이지')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(IconData icon, int index) {
    Color iconColor;
    if (_selectedIndex == 0) {
      // 추천 페이지일 때: 활성은 흰색, 비활성은 회색 (검은색 배경)
      iconColor = (_selectedIndex == index) ? Colors.white : Colors.grey;
    } else {
      // 그 외 페이지: 활성은 검은색, 비활성은 회색 (흰색 배경)
      iconColor = (_selectedIndex == index) ? Colors.black : Colors.grey;
    }
    return IconButton(
      icon: Icon(icon, color: iconColor, size: 28),
      onPressed: () => _onItemTapped(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // 인스타그램 스타일 커스텀 내비게이션바
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _selectedIndex == 0 ? Colors.black : Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.local_dining, 0),
            _buildNavItem(Icons.how_to_vote, 1),
            _buildNavItem(Icons.person, 2),
          ],
        ),
      ),
    );
  }
}
