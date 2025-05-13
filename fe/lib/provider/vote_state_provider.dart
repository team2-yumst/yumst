import 'package:fe/data/location_service.dart';
import 'package:fe/model/vote_restaurant.dart';
import 'package:fe/repository/vote_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException, LocationPermissionDeniedException, LocationPermissionPermanentlyDeniedException, LocationRetrievalException;
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fe/model/vote_types.dart';
import 'dart:math';

// 1. 상태 모델 정의
class VoteRestaurantState {
  final VoteRestaurant restaurant;
  final VoteType? userVote;
  final bool isVoting;
  final bool isScraped; // 스크랩 상태를 별도 필드로 관리

  VoteRestaurantState({
    required this.restaurant,
    this.userVote,
    this.isVoting = false,
    required this.isScraped, // 초기화 필요
  });

  VoteRestaurantState copyWith({
    VoteRestaurant? restaurant,
    VoteType? userVote,
    bool? isVoting,
    bool? isScraped, // 스크랩 상태 복사 추가
    bool forceNullUserVote = false,
  }) {
    return VoteRestaurantState(
      restaurant: restaurant ?? this.restaurant,
      userVote: forceNullUserVote ? null : (userVote ?? this.userVote),
      isVoting: isVoting ?? this.isVoting,
      isScraped: isScraped ?? this.isScraped, // 스크랩 상태 복사
    );
  }

  // 임시 초기 데이터 변환 (실제 VoteRestaurant 모델 업데이트 필요)
  factory VoteRestaurantState.fromRestaurant(VoteRestaurant restaurant) {
    // API에서 받은 userVoteStatus 파싱
    VoteType? initialVote;
    String? voteStatusFromApi = restaurant.userVoteStatus?.trim().toUpperCase();

    if (voteStatusFromApi == 'LIKE') {
      initialVote = VoteType.LIKE;
    } else if (voteStatusFromApi == 'DISLIKE') {
      initialVote = VoteType.DISLIKE;
    }

    VoteRestaurant updatedRestaurant = restaurant.copyWith(
      userVoteStatus: restaurant.userVoteStatus
    );

    return VoteRestaurantState(
      restaurant: updatedRestaurant,
      userVote: initialVote,       
      isVoting: false,
      isScraped: restaurant.isScrapped ?? false, // 스크랩 상태 초기화
    );
  }
}

// 페이지네이션 포함된 상태 클래스
@immutable
class VotePageCombinedState {
  final List<VoteRestaurantState> restaurants;
  final bool isLoadingInitial;    // 초기 로딩 중?
  final bool isLoadingNextPage;   // 다음 페이지 로딩 중?
  final bool hasMore;             // 더 불러올 페이지가 있는가?
  final Object? error;            // 에러 객체
  final String? errorMessage;     // 에러 메시지
  final StackTrace? stackTrace;   // 에러 스택 트레이스
  final String currentSort;       // 현재 정렬 기준

  const VotePageCombinedState({
    this.restaurants = const [],
    this.isLoadingInitial = true,
    this.isLoadingNextPage = false,
    this.hasMore = true,
    this.error,
    this.errorMessage,
    this.stackTrace,
    this.currentSort = 'distance',
  });

  VotePageCombinedState copyWith({
    List<VoteRestaurantState>? restaurants,
    bool? isLoadingInitial,
    bool? isLoadingNextPage,
    bool? hasMore,
    Object? error,
    String? errorMessage,
    StackTrace? stackTrace,
    String? currentSort,
    bool clearError = false, // 에러를 명시적으로 지울지 여부
  }) {
    return VotePageCombinedState(
      restaurants: restaurants ?? this.restaurants,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      currentSort: currentSort ?? this.currentSort,
    );
  }
}

// StateNotifier 리팩토링
class VotePageStateNotifier extends StateNotifier<VotePageCombinedState> {
  final dynamic _read;
  final VoteRepository _voteRepository;
  final LocationService? _locationService;
  int _currentPage = 0;
  final int _pageSize = 10; // 페이지 당 아이템 수
  
  // 위치 정보를 저장할 변수
  Position? _lastPosition;

  VotePageStateNotifier({
    required VoteRepository voteRepository,
    required dynamic read,
    LocationService? locationService,
  }) : _voteRepository = voteRepository, 
       _read = read, 
       _locationService = locationService,
       super(const VotePageCombinedState()) {
    _fetchInitialRestaurants();
  }

  // 초기 데이터 또는 새로고침 시 호출
  Future<void> _fetchInitialRestaurants() async {
    try {
      if (_locationService == null) {
        throw Exception('위치 서비스를 사용할 수 없습니다.');
      }
      
      state = state.copyWith(
        isLoadingInitial: true,
        clearError: true,
      );
      
      // 위치 정보 요청
      _lastPosition = await _locationService!.getPosition();
      
      if (_lastPosition == null) {
        throw Exception('위치 정보를 가져올 수 없습니다.');
      }
      
      // 정렬 기준 설정하여 API 요청
      final restaurants = await _voteRepository.getVotableRestaurants(
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        sort: state.currentSort,
        page: 0, // 초기화 시에는 항상 첫 페이지
      );
      
      _currentPage = 0; // 페이지 카운터 리셋
      
      // API 응답을 VoteRestaurantState 목록으로 변환
      final initialRestaurantStates = restaurants.map((r) {
        // 서버에서 받은 VoteRestaurant 객체로 초기 상태 생성
        return VoteRestaurantState.fromRestaurant(r);
      }).toList();
      
      // 상태 업데이트
      state = state.copyWith(
        isLoadingInitial: false,
        restaurants: initialRestaurantStates,
        hasMore: restaurants.length >= _pageSize,
      );
    } catch (e, stackTrace) {
      print("API 요청 오류: $e");
      state = state.copyWith( 
        isLoadingInitial: false,
        error: e,
        stackTrace: stackTrace,
        hasMore: false,
      );
    }
  }

  // 투표 상태 변경에 따른 좋아요/싫어요 개수 조정 메소드
  VoteRestaurant adjustVoteCounts(
    VoteRestaurant restaurant, 
    VoteType? oldVote, 
    VoteType? newVote
  ) {
    int likeCount = restaurant.likeCount ?? 0;
    int dislikeCount = restaurant.dislikeCount ?? 0;
    
    // 이전 투표 상태에 따른 카운트 조정
    if (oldVote == VoteType.LIKE) {
      likeCount = max(0, likeCount - 1);  // 이전에 좋아요했으면 좋아요 -1
    } else if (oldVote == VoteType.DISLIKE) {
      dislikeCount = max(0, dislikeCount - 1); // 이전에 싫어요했으면 싫어요 -1
    }
    
    // 새 투표 상태에 따른 카운트 조정
    if (newVote == VoteType.LIKE) {
      likeCount += 1;  // 새 투표가 좋아요면 좋아요 +1
    } else if (newVote == VoteType.DISLIKE) {
      dislikeCount += 1; // 새 투표가 싫어요면 싫어요 +1
    }
    
    return restaurant.copyWith(
      likeCount: likeCount,
      dislikeCount: dislikeCount,
    );
  }

  // 투표 처리 함수
  Future<void> vote(String restaurantId, VoteType? newVoteType) async {
    final index = state.restaurants.indexWhere((r) => r.restaurant.restaurantId == restaurantId);
    if (index == -1) return; // 해당 식당이 목록에 없으면 처리하지 않음
    
    final currentRestaurant = state.restaurants[index].restaurant;
    final currentVote = state.restaurants[index].userVote;
    
    // 이미 같은 투표 상태면 중복 요청 방지
    if (currentVote == newVoteType) return;
    
    // 낙관적 UI 업데이트
    final updatedRestaurants = List<VoteRestaurantState>.from(state.restaurants);
    updatedRestaurants[index] = updatedRestaurants[index].copyWith(
      userVote: newVoteType,
      restaurant: adjustVoteCounts(currentRestaurant, currentVote, newVoteType),
      forceNullUserVote: newVoteType == null,
      isVoting: true,
    );
    
    state = state.copyWith(restaurants: updatedRestaurants);
    
    try {
      // 서버에 직접 투표 요청
      await _voteRepository.voteRestaurant(
        restaurantId: restaurantId,
        voteType: newVoteType
      );
      
      // 투표 상태를 "로딩 아님"으로 업데이트
      final finalRestaurants = List<VoteRestaurantState>.from(state.restaurants);
      final finalIndex = finalRestaurants.indexWhere((r) => r.restaurant.restaurantId == restaurantId);
      
      if (finalIndex != -1) {
        finalRestaurants[finalIndex] = finalRestaurants[finalIndex].copyWith(
          isVoting: false,
        );
        
        state = state.copyWith(restaurants: finalRestaurants);
      }
    } catch (e) {
      print("투표 처리 오류: $e");
      // 오류 발생 시에도 isVoting 상태 해제
      final rollbackRestaurants = List<VoteRestaurantState>.from(state.restaurants);
      final rollbackIndex = rollbackRestaurants.indexWhere((r) => r.restaurant.restaurantId == restaurantId);
      
      if (rollbackIndex != -1) {
        rollbackRestaurants[rollbackIndex] = rollbackRestaurants[rollbackIndex].copyWith(
          isVoting: false,
          // 원래 투표 상태로 롤백
          userVote: currentVote,
          forceNullUserVote: currentVote == null,
          restaurant: adjustVoteCounts(
            rollbackRestaurants[rollbackIndex].restaurant,
            newVoteType,
            currentVote
          ),
        );
        
        state = state.copyWith(restaurants: rollbackRestaurants);
      }
    }
  }

  // 스크랩 토글 함수
  Future<bool> toggleScrap({required String restaurantId}) async {
    final index = state.restaurants.indexWhere((rs) => rs.restaurant.restaurantId == restaurantId);
    if (index == -1) return false;

    final restaurant = state.restaurants[index].restaurant;
    final currentScrapStatus = state.restaurants[index].isScraped;
    final newScrapStatus = !currentScrapStatus;
    
    // 낙관적 UI 업데이트
    final updatedRestaurants = List<VoteRestaurantState>.from(state.restaurants);
    updatedRestaurants[index] = updatedRestaurants[index].copyWith(
      isScraped: newScrapStatus,
      restaurant: restaurant.copyWith(
        isScrapped: newScrapStatus
      ),
    );
    
    state = state.copyWith(restaurants: updatedRestaurants);

    try {
      // API 호출
      final res = await _voteRepository.toggleScrap(restaurantId);
      print("스크랩 토글 응답: $res");
      return res;
    } catch (e) {
      // API 호출 실패 시 UI 롤백
      final rollbackRestaurants = List<VoteRestaurantState>.from(state.restaurants);
      rollbackRestaurants[index] = rollbackRestaurants[index].copyWith(
        isScraped: currentScrapStatus,
        restaurant: rollbackRestaurants[index].restaurant.copyWith(
          isScrapped: currentScrapStatus
        ),
      );
      
      state = state.copyWith(restaurants: rollbackRestaurants);
      print("스크랩 토글 실패: $e");
      throw e;
    }
  }
  
  // 새로고침 기능
  Future<void> refresh() async {
    await _fetchInitialRestaurants();
  }

  // 정렬 기준 변경
  Future<void> changeSort(String sortCriteria) async {
    // 현재 정렬과 동일하면 무시
    if (sortCriteria == state.currentSort) return;
    
    state = state.copyWith(currentSort: sortCriteria);
    await _fetchInitialRestaurants();
  }
  
  // 다음 페이지 로드
  Future<void> loadNextPage() async {
    if (state.isLoadingNextPage || !state.hasMore) return;
    
    try {
      state = state.copyWith(isLoadingNextPage: true);
      
      _currentPage++;
      
      // 위치 정보 없으면 마지막 위치 재사용
      if (_lastPosition == null) {
        throw Exception('위치 정보가 없습니다.');
      }
      
      // 다음 페이지 레스토랑 목록 가져오기
      final nextRestaurants = await _voteRepository.getVotableRestaurants(
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        sort: state.currentSort,
        page: _currentPage,
      );
      
      // 이미 로드된 식당 ID 목록
      final existingRestaurantIds = state.restaurants.map((r) => r.restaurant.restaurantId).toSet();
      
      // 새 응답에서 중복되지 않은 항목만 필터링
      final uniqueNewRestaurants = nextRestaurants.where(
        (r) => !existingRestaurantIds.contains(r.restaurantId)
      ).toList();
      
      // 새 레스토랑 상태 객체 생성
      final newRestaurantStates = uniqueNewRestaurants.map((r) {
        return VoteRestaurantState.fromRestaurant(r);
      }).toList();
      
      // 기존 목록에 새 레스토랑 추가
      final allRestaurantStates = [...state.restaurants, ...newRestaurantStates];
      
      state = state.copyWith(
        isLoadingNextPage: false,
        restaurants: allRestaurantStates,
        hasMore: nextRestaurants.length >= _pageSize,
      );
    } catch (e, stackTrace) {
      print("다음 페이지 로드 오류: $e");
      state = state.copyWith(
        isLoadingNextPage: false,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

// StateNotifierProvider
final votePageStateProvider = StateNotifierProvider<VotePageStateNotifier, VotePageCombinedState>((ref) {
  final voteRepository = ref.watch(voteRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  
  return VotePageStateNotifier(
    voteRepository: voteRepository,
    read: ref.read,
    locationService: locationService,
  );
});

// 네비게이션 키 provider
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
}); 