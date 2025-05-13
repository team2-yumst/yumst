import 'package:dio/dio.dart';
import 'package:fe/data/secure_storage.dart';
import 'package:fe/data/token_interceptor.dart'; // Assuming Dio setup is similar
import 'package:fe/model/vote_restaurant.dart';
import 'package:fe/model/vote_types.dart'; // VoteType만 가져오기
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  VoteRepository({required this.dio, required this.storage});

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

  // 투표 API 호출 메소드
  Future<Map<String, dynamic>> voteRestaurant({
    required String restaurantId,
    required VoteType? voteType, // 좋아요(LIKE), 싫어요(DISLIKE) 또는 null(투표 취소)
  }) async {
    try {
      final userId = await storage.readUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // PATCH 메서드로 투표 요청
      final response = await dio.patch(
        'http://localhost:8080/api/vote/v1/restaurants/$restaurantId',
        options: Options(headers: {'userId': userId}),
        data: {
          'voteType': voteType?.name, // Enum 이름을 문자열로 변환 (LIKE, DISLIKE) 또는 null
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

  // 스크랩 토글 메소드
  Future<bool> toggleScrap(String restaurantId) async {
    try {
      final userId = await storage.readUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // PATCH 메소드 사용
      final response = await dio.patch(
        'http://localhost:8080/api/user/v1/scrap/$restaurantId',
        options: Options(headers: {'userId': userId}),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // 스크랩 상태 반환 (true: 스크랩됨, false: 스크랩 해제됨)
        final scrapped = response.data['scrapped'] as bool? ?? false;
        return scrapped;
      } else {
        throw Exception('Failed to set scrap: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException setting scrap: ${e.message}');
      print('Error response: ${e.response?.data}');
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to set scrap: $errorMessage');
    } catch (e) {
      print('Error setting scrap: $e');
      throw Exception('Failed to set scrap.');
    }
  }
} 