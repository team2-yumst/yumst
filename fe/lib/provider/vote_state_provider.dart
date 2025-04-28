import 'package:fe/data/location_service.dart';
import 'package:fe/model/vote_restaurant.dart';
import 'package:fe/repository/vote_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException, LocationPermissionDeniedException, LocationPermissionPermanentlyDeniedException, LocationRetrievalException;
import 'dart:async';

// VoteType enum 정의
enum VoteType { LIKE, DISLIKE }

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
    return VoteRestaurantState(restaurant: restaurant, userVote: initialVote);
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
  final List<Map<String, dynamic>> _queue = [];
  Timer? _batchTimer;
  final Duration _batchInterval = const Duration(seconds: 5);
  final int _maxBatchSize = 20;
  DateTime _lastRequestTime = DateTime.now();
  int _requestCount = 0;
  final Duration _rateLimitWindow = const Duration(minutes: 1);
  final VoteRepository _repository;

  VoteQueue(this._repository);

  void addVote(String restaurantId, VoteType voteType) {
    final now = DateTime.now();
    if (now.difference(_lastRequestTime) < _rateLimitWindow) {
      if (_requestCount >= 20) {
        throw Exception('Too many requests');
      }
      _requestCount++;
    } else {
      _requestCount = 1;
      _lastRequestTime = now;
    }

    _queue.add({
      'restaurantId': restaurantId,
      'voteType': voteType.name,
    });

    _startBatchTimer();
  }

  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer(_batchInterval, _processBatch);
  }

  Future<void> _processBatch() async {
    if (_queue.isEmpty) return;

    final votesToProcess = _queue.sublist(0, _maxBatchSize);
    _queue.removeRange(0, votesToProcess.length);

    try {
      await _repository.batchVote(votes: votesToProcess);
    } catch (e) {
      _queue.insertAll(0, votesToProcess);
    }
  }

  void dispose() {
    _batchTimer?.cancel();
  }
}

// 2. StateNotifier 리팩토링 (VotePageCombinedState 사용)
class VotePageStateNotifier extends StateNotifier<VotePageCombinedState> {
  final VoteRepository _voteRepository;
  final dynamic _read;
  late final VoteQueue _voteQueue;
  int _currentPage = 0;
  final int _pageSize = 10; // 페이지 당 아이템 수 (API와 일치시켜야 함)
  
  // 위치 정보를 저장할 변수 추가
  Position? _lastPosition;

  VotePageStateNotifier(this._voteRepository, this._read)
      : super(const VotePageCombinedState()) {
    _voteQueue = VoteQueue(_voteRepository);
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
      final locationService = _read(locationServiceProvider);
      try {
        _lastPosition = await locationService.getPosition();
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

      print("API 요청 시작: ${_lastPosition?.latitude}, ${_lastPosition?.longitude}, $newSort");
      final restaurants = await _voteRepository.getVotableRestaurants(
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        radius: 5.0,
        sort: newSort,
        page: _currentPage,
        size: _pageSize,
      );
      print("식당 데이터 받음: ${restaurants.length}개");

      final initialRestaurantStates =
          restaurants.map((r) => VoteRestaurantState.fromRestaurant(r)).toList();

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

    // 즉시 UI 업데이트
    var updatedList = List<VoteRestaurantState>.from(state.restaurants);
    updatedList[index] = originalState.copyWith(
      userVote: newVote,
      isVoting: true,
    );
    state = state.copyWith(restaurants: updatedList, clearError: true);

    try {
      // 배치 큐에 추가
      _voteQueue.addVote(restaurantId, newVote ?? voteType);
      
      // 낙관적 업데이트
      final updatedRestaurant = originalState.restaurant.copyWith(
        likeCount: newVote == VoteType.LIKE 
          ? (originalState.restaurant.likeCount ?? 0) + 1
          : originalState.restaurant.likeCount,
        dislikeCount: newVote == VoteType.DISLIKE
          ? (originalState.restaurant.dislikeCount ?? 0) + 1
          : originalState.restaurant.dislikeCount,
        userVoteStatus: newVote?.name,
      );

      final finalList = List<VoteRestaurantState>.from(state.restaurants);
      if (index < finalList.length) {
        finalList[index] = originalState.copyWith(
          restaurant: updatedRestaurant,
          userVote: newVote,
          isVoting: false,
          forceNullUserVote: newVote == null
        );
        state = state.copyWith(restaurants: finalList);
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
  Future<void> toggleScrap(String restaurantId) async {
    // 로딩 중이 아닐 때만 처리
    if (state.isLoadingInitial || state.isLoadingNextPage) return;

    final index = state.restaurants.indexWhere((rs) => rs.restaurant.restaurantId == restaurantId);
    if (index == -1) return;

    final originalState = state.restaurants[index];
    
    // 낙관적 UI 업데이트 (스크랩 상태 즉시 토글)
    final newIsScrapped = !(originalState.restaurant.isScrapped ?? false);
    
    // 상태 업데이트 (isLoading 포함)
    var updatedList = List<VoteRestaurantState>.from(state.restaurants);
    final updatedRestaurant = originalState.restaurant.copyWith(
      isScrapped: newIsScrapped,
    );
    
    updatedList[index] = originalState.copyWith(
      restaurant: updatedRestaurant,
    );
    
    state = state.copyWith(restaurants: updatedList, clearError: true);

    try {
      // 실제 API 호출
      final isScrapped = await _voteRepository.scrapRestaurant(restaurantId);
      
      // API 응답을 기반으로 스크랩 상태 업데이트
      final finalList = List<VoteRestaurantState>.from(state.restaurants);
      if (index < finalList.length) {
        final updatedRestaurant = originalState.restaurant.copyWith(
          isScrapped: isScrapped,
        );
        
        finalList[index] = originalState.copyWith(
          restaurant: updatedRestaurant,
        );
        
        state = state.copyWith(restaurants: finalList);
        
        // 개별 식당 상태도 업데이트
        _read(voteRestaurantProvider(restaurantId).notifier).updateRestaurant(updatedRestaurant);
      }
      
    } catch (e, stackTrace) {
      // API 실패 시 롤백
      final rollbackList = List<VoteRestaurantState>.from(state.restaurants);
      if (index < rollbackList.length) {
        final originalRestaurant = originalState.restaurant.copyWith(
          isScrapped: !newIsScrapped, // 원래 상태로 되돌림
        );
        
        rollbackList[index] = originalState.copyWith(
          restaurant: originalRestaurant,
        );
        
        state = state.copyWith(restaurants: rollbackList, error: e, stackTrace: stackTrace);
        
        // 개별 식당 상태도 롤백
        _read(voteRestaurantProvider(restaurantId).notifier).updateRestaurant(originalRestaurant);
      }
      // TODO: Show error Snackbar
    }
  }
}

// 3. StateNotifierProvider 수정 (상태 타입 변경)
final votePageStateProvider = StateNotifierProvider<VotePageStateNotifier, VotePageCombinedState>((ref) {
  final voteRepository = ref.watch(voteRepositoryProvider);
  return VotePageStateNotifier(voteRepository, ref.read);
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