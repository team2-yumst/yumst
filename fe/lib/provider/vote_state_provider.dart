import 'package:fe/data/location_service.dart';
import 'package:fe/model/vote_restaurant.dart';
import 'package:fe/repository/vote_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException, LocationPermissionDeniedException, LocationPermissionPermanentlyDeniedException, LocationRetrievalException;

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
  final StackTrace? stackTrace;   // 에러 스택 트레이스
  final String currentSort;       // 현재 정렬 기준

  const VotePageCombinedState({
    this.restaurants = const [],
    this.isLoadingInitial = true,
    this.isLoadingNextPage = false,
    this.hasMore = true,
    this.error,
    this.stackTrace,
    this.currentSort = 'distance',
  });

  VotePageCombinedState copyWith({
    List<VoteRestaurantState>? restaurants,
    bool? isLoadingInitial,
    bool? isLoadingNextPage,
    bool? hasMore,
    Object? error,
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
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      currentSort: currentSort ?? this.currentSort,
    );
  }
}

// 2. StateNotifier 리팩토링 (VotePageCombinedState 사용)
class VotePageStateNotifier extends StateNotifier<VotePageCombinedState> {
  final VoteRepository _voteRepository;
  final dynamic _read;
  int _currentPage = 0;
  final int _pageSize = 10; // 페이지 당 아이템 수 (API와 일치시켜야 함)
  
  // 위치 정보를 저장할 변수 추가
  Position? _lastPosition;

  VotePageStateNotifier(this._voteRepository, this._read)
      : super(const VotePageCombinedState()) { // 초기 상태
    _fetchInitialRestaurants();
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
      // 초기 로드 또는 새로고침 시에만 새 위치 정보 가져오기
      _lastPosition = await _read(currentPositionProvider.future);

      final restaurants = await _voteRepository.getVotableRestaurants(
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        radius: 5.0,
        sort: newSort,
        page: _currentPage,
        size: _pageSize,
      );

      final initialRestaurantStates =
          restaurants.map((r) => VoteRestaurantState.fromRestaurant(r)).toList();

      state = state.copyWith(
        isLoadingInitial: false,
        restaurants: initialRestaurantStates,
        hasMore: restaurants.length >= _pageSize,
      );
    } catch (e, stackTrace) {
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
    // 로딩 중이 아닐 때만 처리 (isLoadingInitial, isLoadingNextPage 확인)
    if (state.isLoadingInitial || state.isLoadingNextPage) return;

    final index = state.restaurants.indexWhere((rs) => rs.restaurant.restaurantId == restaurantId);
    if (index == -1) return;

    final originalState = state.restaurants[index];
    VoteType? optimisticVote = originalState.userVote;
    if (optimisticVote == voteType) optimisticVote = null;
    else optimisticVote = voteType;

    // 상태 업데이트 (isLoading 포함)
    var optimisticList = List<VoteRestaurantState>.from(state.restaurants);
    optimisticList[index] = originalState.copyWith(isVoting: true, userVote: optimisticVote, forceNullUserVote: optimisticVote == null);
    state = state.copyWith(restaurants: optimisticList, clearError: true);

    try {
      final response = await _voteRepository.voteRestaurant(
        restaurantId: restaurantId,
        voteType: voteType,
      );
      
      // 실제 모델의 copyWith 메소드 사용
      final updatedRestaurant = originalState.restaurant.copyWith(
         likeCount: (response['likes'] as num?)?.toInt() ?? 0,
         dislikeCount: (response['dislikes'] as num?)?.toInt() ?? 0,
         userVoteStatus: optimisticVote?.name, // 투표 상태 업데이트 (LIKE, DISLIKE, null)
      );

      // API 성공 후 최종 상태 업데이트
      final finalList = List<VoteRestaurantState>.from(state.restaurants);
      if (index < finalList.length) { // 리스트가 변경되었을 수 있으므로 인덱스 재확인
          finalList[index] = originalState.copyWith(
            restaurant: updatedRestaurant,
            userVote: optimisticVote,
            isVoting: false,
            forceNullUserVote: optimisticVote == null
          );
         state = state.copyWith(restaurants: finalList);
      }

    } catch (e, stackTrace) {
      // API 실패 시 롤백 (로딩 상태만 해제)
      final rollbackList = List<VoteRestaurantState>.from(state.restaurants);
      if (index < rollbackList.length) {
          rollbackList[index] = originalState.copyWith(isVoting: false);
          state = state.copyWith(restaurants: rollbackList, error: e, stackTrace: stackTrace);
      }
      // TODO: Show error Snackbar
    }
  }

  // 새로고침
  Future<void> refresh({String? sort}) async {
    await _fetchInitialRestaurants(sort: sort);
  }
}

// 3. StateNotifierProvider 수정 (상태 타입 변경)
final votePageStateProvider = StateNotifierProvider<VotePageStateNotifier, VotePageCombinedState>((ref) {
  final voteRepository = ref.watch(voteRepositoryProvider);
  return VotePageStateNotifier(voteRepository, ref.read);
}); 