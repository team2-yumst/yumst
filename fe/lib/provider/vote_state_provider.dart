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

// 스크랩 상태 관리를 위한 클래스
class ScrapManager {
  final Map<String, bool> _scrappedRestaurants = {};
  
  // 스크랩 상태 설정
  void setScrapState(String restaurantId, bool isScraped) {
    _scrappedRestaurants[restaurantId] = isScraped;
  }
  
  // 스크랩 상태 조회
  bool? getScrapState(String restaurantId) {
    return _scrappedRestaurants[restaurantId];
  }
}

// 1. 상태 모델 정의
class VoteRestaurantState {
  final VoteRestaurant restaurant;
  final VoteType? userVote;
  final bool isVoting;

  VoteRestaurantState({
    required this.restaurant,
    this.userVote,
    this.isVoting = false,
  });

  VoteRestaurantState copyWith({
    VoteRestaurant? restaurant,
    VoteType? userVote,
    bool? isVoting,
    bool forceNullUserVote = false,
  }) {
    return VoteRestaurantState(
      restaurant: restaurant ?? this.restaurant,
      userVote: forceNullUserVote ? null : (userVote ?? this.userVote),
      isVoting: isVoting ?? this.isVoting,
    );
  }

  // 임시 초기 데이터 변환 (실제 VoteRestaurant 모델 업데이트 필요)
  factory VoteRestaurantState.fromRestaurant(VoteRestaurant restaurant) {
    VoteType? initialVote;
    String? voteStatusFromApi = restaurant.userVoteStatus; // 이제 실제 모델에서 userVoteStatus를 읽음
    if (voteStatusFromApi == 'LIKE') initialVote = VoteType.LIKE;
    else if (voteStatusFromApi == 'DISLIKE') initialVote = VoteType.DISLIKE;

    // isScrapped 값이 null이면 false로 설정하여 명확히 초기화
    bool isScrappedValue = restaurant.isScrapped ?? false;

    return VoteRestaurantState(
        restaurant: restaurant.copyWith(isScrapped: isScrappedValue),
        userVote: initialVote);
  }
}

// 1-1. 페이지네이션 포함된 새로운 상태 클래스
@immutable // 불변 객체 권장
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

// VoteQueue 클래스 수정
class VoteQueue {
  final VoteRepository _voteRepository; // API 통신을 위한 repository
  final List<VoteQueueItem> _queue = []; // 큐 구현
  final Map<String, VoteType?> _currentVotes = {}; // 식당별 현재 투표 상태 추적
  
  VoteQueue(this._voteRepository);

  // 큐에 투표 항목 추가
  void addVote(String restaurantId, VoteType? voteType) {
    _queue.add(VoteQueueItem(restaurantId, voteType));
    // 현재 상태 맵에도 저장
    _currentVotes[restaurantId] = voteType;
  }
  
  // 현재 식당의 투표 상태 반환 (새로고침 시 사용)
  VoteType? getCurrentVote(String restaurantId) {
    return _currentVotes[restaurantId];
  }

  // 서버에 배치 요청 보내는 메소드
  Future<void> processBatch() async {
    if (_queue.isEmpty) return;
    
    // 큐 아이템 복사 후 클리어 (API 호출 중 추가되는 항목은 다음 배치에 처리)
    final batch = [..._queue];
    _queue.clear();
    
    try {
      // 배치 요청 실행
      await _voteRepository.batchVote(batch);
    } catch (e) {
      // 오류시 큐 복원
      print("투표 요청 처리 실패: $e");
      _queue.insertAll(0, batch);
    }
  }
  
  // 리소스 정리
  void dispose() {
    _queue.clear();
    _currentVotes.clear();
  }
}

// 2. StateNotifier 리팩토링 (VotePageCombinedState 사용)
class VotePageStateNotifier extends StateNotifier<VotePageCombinedState> {
  final dynamic _read;
  final VoteRepository _voteRepository;
  final LocationService? _locationService; // optional로 변경
  late final VoteQueue _voteQueue;
  final ScrapManager _scrapManager;
  int _currentPage = 0;
  final int _pageSize = 10; // 페이지 당 아이템 수 (API와 일치시켜야 함)
  
  // 위치 정보를 저장할 변수 추가
  Position? _lastPosition;

  VotePageStateNotifier({
    required VoteRepository voteRepository,
    required dynamic read,
    LocationService? locationService, // optional로 변경
    VoteQueue? voteQueue, // null 허용
    required ScrapManager scrapManager,
  }) : _voteRepository = voteRepository, 
       _read = read, 
       _locationService = locationService,
       _scrapManager = scrapManager,
       super(const VotePageCombinedState()) {
    _voteQueue = voteQueue ?? VoteQueue(voteRepository);
    _fetchInitialRestaurants();
  }

  @override
  void dispose() {
    _voteQueue.dispose();
    super.dispose();
  }

  // 초기 데이터 또는 새로고침 시 호출
  Future<void> _fetchInitialRestaurants({String? sort}) async {
    _currentPage = 0; // 페이지 리셋
    final newSort = sort ?? state.currentSort;
    state = state.copyWith(
      isLoadingInitial: true,
      hasMore: true,
      currentSort: newSort,
      clearError: true,
    );
    
    try {
      // 위치 정보 요청
      if (_locationService != null) {
        try {
          _lastPosition = await _locationService!.getPosition();
        } catch (e) {
          print("위치 정보 가져오기 실패: $e");
          // 위치 정보가 없을 때 기본값 사용 (서울 시청 좌표)
          _lastPosition = Position(
            latitude: 37.5665,
            longitude: 126.9780,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      } else {
        // LocationService가 없는 경우 기본 좌표 사용
        _lastPosition = Position(
          latitude: 37.5665,
          longitude: 126.9780,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      print("API 요청 시작: ${_lastPosition?.latitude}, ${_lastPosition?.longitude}, $newSort");
      
      // 기존 식당 ID 목록 백업 (순서 기억용)
      final existingRestaurantIds = state.restaurants.isNotEmpty 
          ? state.restaurants.map((rs) => rs.restaurant.restaurantId).toList()
          : <String>[];
      
      // 새로운 식당 데이터 가져오기
      final restaurants = await _voteRepository.getVotableRestaurants(
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        radius: 5.0,
        sort: newSort,
        page: _currentPage,
        size: _pageSize,
      );
      print("식당 데이터 받음: ${restaurants.length}개");
      
      // 서버 응답에서 가져온 식당 ID 목록
      final newRestaurantIds = restaurants.map((r) => r.restaurantId).toList();
      
      // 기존 식당 상태 맵 생성 (ID로 빠르게 조회)
      final Map<String, VoteRestaurantState> existingStatesMap = {};
      if (state.restaurants.isNotEmpty) {
        for (final rs in state.restaurants) {
          existingStatesMap[rs.restaurant.restaurantId] = rs;
        }
      }

      // 서버 응답에서 가져온 데이터와 로컬 상태를 병합
      final initialRestaurantStates = restaurants.map((r) {
        // 기존 상태 확인
        final existingState = existingStatesMap[r.restaurantId];
        
        // 기본 상태 생성
        var state = VoteRestaurantState.fromRestaurant(r);
        
        // 로컬 큐에 저장된 vote를 우선 적용 (새로고침 후에도 유지)
        final localVote = _voteQueue.getCurrentVote(r.restaurantId);
        
        // 기존 상태가 있으면 보존
        if (existingState != null) {
          // 서버 응답과 로컬 상태 및 큐 상태를 결합
          final mergedVote = localVote ?? existingState.userVote ?? 
                            (r.userVoteStatus == 'LIKE' ? VoteType.LIKE : 
                            r.userVoteStatus == 'DISLIKE' ? VoteType.DISLIKE : null);
          
          // 중요: 서버의 스크랩 상태를 우선시
          final mergedIsScrapped = r.isScrapped ?? existingState.restaurant.isScrapped ?? false;
          
          // 병합된 상태 생성
          state = VoteRestaurantState(
            restaurant: r.copyWith(
              likeCount: r.likeCount,
              dislikeCount: r.dislikeCount,
              isScrapped: mergedIsScrapped, // 서버 스크랩 상태 우선
              userVoteStatus: mergedVote?.name
            ),
            userVote: mergedVote,
            isVoting: false
          );
        } else {
          // 새로운 식당인 경우 서버 응답 그대로 사용
          // 로컬 큐에 저장된 투표 상태가 있으면 적용
          if (localVote != null) {
            state = state.copyWith(
              userVote: localVote,
              forceNullUserVote: localVote == null,
              restaurant: adjustVoteCounts(r, state.userVote, localVote)
            );
          }
          
          // 로컬 스크랩 상태 확인
          final localScrapState = _scrapManager.getScrapState(r.restaurantId);
          
          // 로컬 스크랩 상태가 있으면 적용, 없으면 서버 응답 사용
          if (localScrapState != null) {
            state = state.copyWith(
              restaurant: state.restaurant.copyWith(
                isScrapped: localScrapState
              )
            );
          } else if (r.isScrapped != null) {
            // 서버 스크랩 상태 적용
            state = state.copyWith(
              restaurant: state.restaurant.copyWith(
                isScrapped: r.isScrapped
              )
            );
          }
        }
        
        return state;
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

  // 투표 상태 변경에 따른 좋아요/싫어요 개수 조정 메소드 추가
  VoteRestaurant adjustVoteCounts(
    VoteRestaurant restaurant, 
    VoteType? oldVote, 
    VoteType? newVote
  ) {
    // 기본 카운트
    int likeCount = restaurant.likeCount ?? 0;
    int dislikeCount = restaurant.dislikeCount ?? 0;
    
    // 기존 투표 제거
    if (oldVote == VoteType.LIKE) {
      likeCount--;
    } else if (oldVote == VoteType.DISLIKE) {
      dislikeCount--;
    }
    
    // 새 투표 추가
    if (newVote == VoteType.LIKE) {
      likeCount++;
    } else if (newVote == VoteType.DISLIKE) {
      dislikeCount++;
    }
    
    // 결과가 음수가 되지 않도록 방지
    likeCount = likeCount < 0 ? 0 : likeCount;
    dislikeCount = dislikeCount < 0 ? 0 : dislikeCount;
    
    // userVoteStatus 필드도 일관되게 업데이트
    return restaurant.copyWith(
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      userVoteStatus: newVote?.name
    );
  }

  // 다음 페이지 로드
  Future<void> fetchNextPage() async {
    if (state.isLoadingInitial || state.isLoadingNextPage || !state.hasMore) return;
    
    // 위치 정보가 없는 경우 처리
    if (_lastPosition == null) {
      state = state.copyWith(
        error: Exception('위치 정보를 가져올 수 없습니다. 새로고침을 시도해주세요.'),
        stackTrace: StackTrace.current,
      );
      return;
    }

    state = state.copyWith(isLoadingNextPage: true, clearError: true);
    _currentPage++;

    try {
      // 저장된 위치 정보 사용
      final restaurants = await _voteRepository.getVotableRestaurants(
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        radius: 5.0,
        sort: state.currentSort,
        page: _currentPage,
        size: _pageSize,
      );
      final newRestaurantStates =
          restaurants.map((r) => VoteRestaurantState.fromRestaurant(r)).toList();
      state = state.copyWith(
        isLoadingNextPage: false,
        restaurants: [...state.restaurants, ...newRestaurantStates],
        hasMore: restaurants.length >= _pageSize,
      );
    } catch (e, stackTrace) {
      _currentPage--;
      state = state.copyWith(
        isLoadingNextPage: false,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // 투표 처리 (내부 로직은 거의 동일, 상태 업데이트 방식만 변경)
  Future<void> handleVote(String restaurantId, VoteType voteType) async {
    if (state.isLoadingInitial || state.isLoadingNextPage) return;

    final index = state.restaurants.indexWhere((rs) => rs.restaurant.restaurantId == restaurantId);
    if (index == -1) return;

    final originalState = state.restaurants[index];
    final currentVote = originalState.userVote;
    final newVote = currentVote == voteType ? null : voteType;

    // 현재 투표 상태에 따라 카운트 조정
    int newLikeCount = originalState.restaurant.likeCount ?? 0;
    int newDislikeCount = originalState.restaurant.dislikeCount ?? 0;

    // 이전 투표 취소
    if (currentVote == VoteType.LIKE) {
      newLikeCount = max(0, newLikeCount - 1); // 음수 방지
    } else if (currentVote == VoteType.DISLIKE) {
      newDislikeCount = max(0, newDislikeCount - 1); // 음수 방지
    }

    // 새로운 투표 적용
    if (newVote == VoteType.LIKE) {
      newLikeCount++;
    } else if (newVote == VoteType.DISLIKE) {
      newDislikeCount++;
    }

    // 즉시 UI 업데이트 
    var updatedList = List<VoteRestaurantState>.from(state.restaurants);
    updatedList[index] = originalState.copyWith(
      userVote: newVote,
      isVoting: true,
      restaurant: originalState.restaurant.copyWith(
        likeCount: newLikeCount,
        dislikeCount: newDislikeCount,
        userVoteStatus: newVote?.name, // userVoteStatus도 업데이트
      ),
    );
    state = state.copyWith(restaurants: updatedList, clearError: true);

    bool apiCallSuccess = false;
    Map<String, dynamic>? apiResponse;

    try {
      // 큐에 추가 전에 직접 API 호출 먼저 시도
      final voteQueueItems = [VoteQueueItem(restaurantId, newVote)];
      final results = await _voteRepository.batchVote(voteQueueItems);
      apiCallSuccess = true;
      
      if (results.isNotEmpty) {
        apiResponse = results.firstWhere(
          (item) => item['restaurantId'] == restaurantId,
          orElse: () => <String, dynamic>{},
        );
      }
      
      // 성공했을 때만 큐에 추가 (중복 방지)
      if (!apiCallSuccess) {
        _voteQueue.addVote(restaurantId, newVote);
      }
      
      // 서버 응답이 있으면 정확한 카운트로 업데이트
      if (apiResponse != null && apiResponse.isNotEmpty) {
        final apiLikes = apiResponse['likes'] as int? ?? newLikeCount;
        final apiDislikes = apiResponse['dislikes'] as int? ?? newDislikeCount;
        
        final finalList = List<VoteRestaurantState>.from(state.restaurants);
        final currentIndex = finalList.indexWhere((rs) => rs.restaurant.restaurantId == restaurantId);
        
        if (currentIndex >= 0 && currentIndex < finalList.length) {
          final currentState = finalList[currentIndex];
          finalList[currentIndex] = currentState.copyWith(
            restaurant: currentState.restaurant.copyWith(
              likeCount: apiLikes,
              dislikeCount: apiDislikes,
              userVoteStatus: newVote?.name,
            ),
            userVote: newVote,
            isVoting: false,
            forceNullUserVote: newVote == null
          );
          state = state.copyWith(restaurants: finalList);
        }
      } else {
        // API 응답이 없으면 로딩 상태만 해제
        final finalList = List<VoteRestaurantState>.from(state.restaurants);
        final currentIndex = finalList.indexWhere((rs) => rs.restaurant.restaurantId == restaurantId);
        
        if (currentIndex >= 0 && currentIndex < finalList.length) {
          finalList[currentIndex] = finalList[currentIndex].copyWith(isVoting: false);
          state = state.copyWith(restaurants: finalList);
        }
      }
    } catch (e) {
      // 에러 처리
      final rollbackList = List<VoteRestaurantState>.from(state.restaurants);
      if (index < rollbackList.length) {
        rollbackList[index] = originalState.copyWith(isVoting: false);
        state = state.copyWith(
          restaurants: rollbackList,
          error: e,
          errorMessage: e.toString().contains('Too many requests')
            ? '잠시 후 다시 시도해주세요'
            : '투표 처리 중 오류가 발생했습니다: ${e.toString()}'
        );
      }
    }
  }

  // 새로고침
  Future<void> refresh({String? sort}) async {
    await _fetchInitialRestaurants(sort: sort);
  }
  
  // 스크랩 기능
  Future<bool> toggleScrap({required String restaurantId}) async {
    final index = state.restaurants.indexWhere((rs) => rs.restaurant.restaurantId == restaurantId);
    if (index == -1) return false;

    final restaurant = state.restaurants[index].restaurant;
    final currentScrapStatus = restaurant.isScrapped ?? false;
    final newScrapStatus = !currentScrapStatus;
    
    // 로컬 스크랩 상태 저장
    _scrapManager.setScrapState(restaurantId, newScrapStatus);

    // 낙관적 UI 업데이트
    _updateRestaurantField(index, 'isScrapped', newScrapStatus);

    try {
      final res = await _voteRepository.toggleScrap(restaurantId, newScrapStatus);
      print("스크랩 토글 응답: $res");
      return res;
    } catch (e) {
      // API 호출 실패 시 UI 롤백
      _updateRestaurantField(index, 'isScrapped', currentScrapStatus);
      _scrapManager.setScrapState(restaurantId, currentScrapStatus); // 로컬 상태도 롤백
      print("스크랩 토글 실패: $e");
      throw e;
    }
  }

  void _updateRestaurantField(int index, String field, dynamic value) {
    if (index >= 0 && index < state.restaurants.length) {
      final updatedRestaurant = state.restaurants[index].restaurant.copyWith(
        isScrapped: value,
      );
      final updatedList = List<VoteRestaurantState>.from(state.restaurants);
      updatedList[index] = state.restaurants[index].copyWith(
        restaurant: updatedRestaurant,
      );
      state = state.copyWith(restaurants: updatedList);
    }
  }
}

// 3. StateNotifierProvider 수정 (상태 타입 변경)
final votePageStateProvider = StateNotifierProvider<VotePageStateNotifier, VotePageCombinedState>((ref) {
  final voteRepository = ref.watch(voteRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  final voteQueue = VoteQueue(voteRepository);
  final scrapManager = ScrapManager();
  
  return VotePageStateNotifier(
    voteRepository: voteRepository,
    read: ref.read,
    locationService: locationService,
    voteQueue: voteQueue,
    scrapManager: scrapManager
  );
});

// 개별 식당 상태를 관리하는 StateNotifier
class VoteRestaurantStateNotifier extends StateNotifier<VoteRestaurantState> {
  final String restaurantId;
  final Ref ref;

  VoteRestaurantStateNotifier(this.restaurantId, this.ref)
      : super(VoteRestaurantState(
          restaurant: VoteRestaurant(
            restaurantId: restaurantId,
            name: '',
          ),
        )) {
    _init();
  }

  void _init() {
    final restaurants = ref.read(votePageStateProvider).restaurants;
    final restaurant = restaurants.firstWhere(
      (r) => r.restaurant.restaurantId == restaurantId,
      orElse: () => throw Exception('Restaurant not found: $restaurantId'),
    );
    
    // 기존 상태의 스크랩 정보를 유지하면서 새로운 상태로 업데이트
    state = state.copyWith(
      restaurant: restaurant.restaurant.copyWith(
        isScrapped: restaurant.restaurant.isScrapped ?? state.restaurant.isScrapped,
      ),
      userVote: restaurant.userVote,
      isVoting: restaurant.isVoting,
    );
  }

  void updateRestaurant(VoteRestaurant restaurant) {
    if (restaurant.restaurantId != restaurantId) return;
    state = state.copyWith(
      restaurant: restaurant.copyWith(
        isScrapped: state.restaurant.isScrapped ?? restaurant.isScrapped,
      ),
    );
  }

  void toggleScrap() {
    final restaurant = state.restaurant;
    state = state.copyWith(
      restaurant: restaurant.copyWith(
        isScrapped: !(restaurant.isScrapped ?? false),
      ),
    );
  }
}

// 개별 식당 상태를 관리하는 provider
final voteRestaurantProvider = StateNotifierProvider.family<VoteRestaurantStateNotifier, VoteRestaurantState, String>((ref, restaurantId) {
  return VoteRestaurantStateNotifier(restaurantId, ref);
});

// 네비게이션 키 provider 추가
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
}); 