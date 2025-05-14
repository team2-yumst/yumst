import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScrapManager {
  final Map<String, bool> _scrappedRestaurants = {};
  
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('scrapped_restaurants');
      if (jsonString != null) {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        _scrappedRestaurants.clear();
        _scrappedRestaurants.addAll(
          decoded.map((key, value) => MapEntry(key, value == true))
        );
      }
      print('ScrapManager: 초기화 완료. 스크랩된 레스토랑 수: ${_scrappedRestaurants.length}');
    } catch (e) {
      print('ScrapManager: 초기화 중 오류 발생: $e');
    }
  }
  
  Future<void> setScrapState(String restaurantId, bool isScraped) async {
    try {
      _scrappedRestaurants[restaurantId] = isScraped;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('scrapped_restaurants', jsonEncode(_scrappedRestaurants));
      print('ScrapManager: 스크랩 상태 저장 완료. restaurantId: $restaurantId, isScraped: $isScraped');
    } catch (e) {
      print('ScrapManager: 스크랩 상태 저장 오류: $e');
    }
  }
  
  bool? getScrapState(String restaurantId) {
    return _scrappedRestaurants[restaurantId];
  }
  
  // 모든 스크랩 상태 지우기 (로그아웃 시 사용)
  Future<void> clearAllScraps() async {
    try {
      _scrappedRestaurants.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('scrapped_restaurants');
      print('ScrapManager: 모든 스크랩 상태 삭제됨');
    } catch (e) {
      print('ScrapManager: 스크랩 상태 삭제 오류: $e');
    }
  }
} 