import 'package:fe/view/screen/my_page.dart';
import 'package:fe/view/screen/recommendation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/restaurant_paginator.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  DateTime? _lastTapTime;
  int? _lastTappedIndex;

  static final List<Widget> _pages = [
    RecommendationPage(),
    Center(child: Text('투표 기능은 준비중입니다')),
    MyPageScreen(),
  ];

  void _handleTabInteraction(int index) {
    final currentTime = DateTime.now();

    if (_lastTappedIndex == index &&
        _lastTapTime != null &&
        currentTime.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // 더블 탭 처리
      if (index == 0 && _selectedIndex == 0) {
        ref.read(restaurantPaginationProvider.notifier).loadInitial();
      }
      _lastTapTime = null;
      _lastTappedIndex = null;
    } else {
      // 싱글 탭 처리
      setState(() => _selectedIndex = index);
      _lastTapTime = currentTime;
      _lastTappedIndex = index;
    }
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isRecommendationTab = _selectedIndex == 0;
    final isActive = _selectedIndex == index;

    return InkWell(
      onTap: () => _handleTabInteraction(index),
      borderRadius: BorderRadius.circular(50),
      splashColor: isRecommendationTab ? Colors.white30 : Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: _getIconColor(isRecommendationTab, isActive),
          size: 28,
        ),
      ),
    );
  }

  Color _getIconColor(bool isRecommendationTab, bool isActive) {
    if (isRecommendationTab) {
      return isActive ? Colors.white : Colors.grey;
    }
    return isActive ? Colors.black : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: _selectedIndex == 0 ? Colors.black : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.local_dining, 0),
              _buildNavItem(Icons.how_to_vote, 1),
              _buildNavItem(Icons.person, 2),
            ],
          ),
        ),
      ),
    );
  }
}