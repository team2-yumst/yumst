import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe/model/vote_types.dart';
import 'dart:convert';

class VoteManager {
  final Map<String, VoteType?> _userVotes = {}; // restaurantId: voteType (LIKE, DISLIKE, null)
  
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('user_votes');
      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        _userVotes.clear();
        
        decoded.forEach((restaurantId, voteTypeValue) {
          if (voteTypeValue == null) {
            _userVotes[restaurantId] = null;
          } else {
            try {
              // 문자열을 VoteType으로 변환
              final voteTypeStr = voteTypeValue as String;
              if (voteTypeStr == 'LIKE') {
                _userVotes[restaurantId] = VoteType.LIKE;
              } else if (voteTypeStr == 'DISLIKE') {
                _userVotes[restaurantId] = VoteType.DISLIKE;
              } else {
                _userVotes[restaurantId] = null;
              }
            } catch (e) {
              print('VoteManager: 투표 타입 변환 오류: $e');
              _userVotes[restaurantId] = null;
            }
          }
        });
      }
      print('VoteManager: 초기화 완료. 저장된 투표 수: ${_userVotes.length}');
    } catch (e) {
      print('VoteManager: 초기화 중 오류 발생: $e');
    }
  }
  
  Future<void> setVoteState(String restaurantId, VoteType? voteType) async {
    try {
      _userVotes[restaurantId] = voteType;
      
      final prefs = await SharedPreferences.getInstance();
      // VoteType을 직렬화 가능한 형태로 변환
      final serializableVotes = <String, String?>{};
      _userVotes.forEach((key, value) {
        serializableVotes[key] = value?.name;
      });
      
      await prefs.setString('user_votes', jsonEncode(serializableVotes));
      print('VoteManager: 투표 상태 저장 완료. restaurantId: $restaurantId, voteType: $voteType');
    } catch (e) {
      print('VoteManager: 투표 상태 저장 오류: $e');
    }
  }
  
  VoteType? getVoteState(String restaurantId) {
    return _userVotes[restaurantId];
  }
  
  // 모든 투표 상태 지우기 (로그아웃 시 사용)
  Future<void> clearAllVotes() async {
    try {
      _userVotes.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_votes');
      print('VoteManager: 모든 투표 상태 삭제됨');
    } catch (e) {
      print('VoteManager: 투표 상태 삭제 오류: $e');
    }
  }
} 