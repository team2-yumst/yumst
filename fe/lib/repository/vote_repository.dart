import 'package:dio/dio.dart';
import 'package:fe/data/secure_storage.dart';
import 'package:fe/data/token_interceptor.dart'; // Assuming Dio setup is similar
import 'package:fe/model/vote_restaurant.dart';
import 'package:fe/provider/vote_state_provider.dart'; // VoteType enum 가져오기
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'vote_repository.g.dart';

@Riverpod(keepAlive: true)
VoteRepository voteRepository(VoteRepositoryRef ref) {
  final dio = ref.watch(dioProvider); // Assuming you have a dioProvider
  final storage = ref.watch(secureStorageProvider);
  return VoteRepository(dio: dio, storage: storage);
}

class VoteRepository {
  final Dio dio;
  final SecureStorage storage;
  late SharedPreferences _prefs;

  VoteRepository({required this.dio, required this.storage}) {
    SharedPreferences.getInstance().then((prefs) => _prefs = prefs);
  }

  Future<void> _savePendingVotes(List<Map<String, dynamic>> votes) async {
    final pendingVotes = _prefs.getStringList('pending_votes') ?? [];
    final newVotes = votes.map((vote) => jsonEncode(vote)).toList();
    await _prefs.setStringList('pending_votes', [...pendingVotes, ...newVotes]);
  }

  Future<void> syncPendingVotes() async {
    final pendingVotes = _prefs.getStringList('pending_votes') ?? [];
    if (pendingVotes.isNotEmpty) {
      try {
        final votes = pendingVotes
            .map((vote) => jsonDecode(vote) as Map<String, dynamic>)
            .toList();
        await batchVote(votes: votes);
        await _prefs.remove('pending_votes');
      } catch (e) {
        print('Failed to sync pending votes: $e');
      }
    }
  }

  Future<List<VoteRestaurant>> getVotableRestaurants({
    required double latitude,
    required double longitude,
    double radius = 1.0, // km 단위 사용
    int page = 0,
    int size = 10,
    required String sort, // required로 변경 또는 기본값 설정 유지
  }) async {
    try {
      final userId = await storage.readUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await dio.get(
        'http://localhost:8080/api/vote/v1/restaurants',
        options: Options(headers: {'userId': userId}),
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius, // km 단위 그대로 전달
          'page': page,
          'size': size,
          'sort': sort, // 전달받은 sort 값 사용
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> responseData = response.data;
        return responseData
            .map((data) => VoteRestaurant.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load votable restaurants: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException fetching votable restaurants: ${e.message}');
      print('Error response: ${e.response?.data}');
      throw Exception('Failed to load votable restaurants: ${e.message}');
    } catch (e) {
      print('Error fetching votable restaurants: $e');
      throw Exception('Failed to load votable restaurants.');
    }
  }

  // 투표 API 호출 메소드 수정
  Future<Map<String, dynamic>> voteRestaurant({
    required String restaurantId,
    required VoteType voteType, // 좋아요(LIKE) 또는 싫어요(DISLIKE)
  }) async {
    try {
      final userId = await storage.readUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // POST에서 PATCH로 변경하고 URL 경로 수정
      final response = await dio.patch(
        'http://localhost:8080/api/vote/v1/restaurants/$restaurantId',
        options: Options(headers: {'userId': userId}),
        data: {
          'voteType': voteType.name, // Enum 이름을 문자열로 변환 (LIKE, DISLIKE)
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // 성공 시 응답 데이터 반환 (message, likes, dislikes 포함)
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to vote: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException voting: ${e.message}');
      print('Error response: ${e.response?.data}');
      // API 에러 메시지를 전달하도록 수정 (백엔드 응답 구조에 따라 조정)
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to vote: $errorMessage');
    } catch (e) {
      print('Error voting: $e');
      throw Exception('Failed to vote.');
    }
  }

  // 배치 투표 API 호출 메소드 추가
  Future<List<Map<String, dynamic>>> batchVote({
    required List<Map<String, dynamic>> votes, // [{restaurantId: String, voteType: String}]
  }) async {
    try {
      final userId = await storage.readUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await dio.post(
        'http://localhost:8080/api/vote/v1/batch',
        options: Options(headers: {'userId': userId}),
        data: {
          'votes': votes, // 배치 투표 요청 형식에 맞게 전달
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        // 성공 시 응답 데이터 반환
        return (response.data as List).cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to batch vote: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException batch voting: ${e.message}');
      print('Error response: ${e.response?.data}');
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to batch vote: $errorMessage');
    } catch (e) {
      print('Error batch voting: $e');
      throw Exception('Failed to batch vote.');
    }
  }

  // 스크랩 토글 메소드 추가
  Future<bool> scrapRestaurant(String restaurantId) async {
    try {
      final userId = await storage.readUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await dio.patch(
        'http://localhost:8080/api/user/v1/scrap/$restaurantId',
        options: Options(headers: {'userId': userId}),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // 스크랩 상태 반환 (true: 스크랩됨, false: 스크랩 해제됨)
        final scrapped = response.data['scrapped'] as bool? ?? false;
        return scrapped;
      } else {
        throw Exception('Failed to toggle scrap: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException scrapping: ${e.message}');
      print('Error response: ${e.response?.data}');
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to toggle scrap: $errorMessage');
    } catch (e) {
      print('Error scrapping: $e');
      throw Exception('Failed to toggle scrap.');
    }
  }
} 