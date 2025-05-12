import 'package:fe/data/location_service.dart';
import 'package:fe/managers/scrap_manager.dart';
import 'package:fe/managers/vote_manager.dart';
import 'package:fe/model/vote_restaurant.dart';
import 'package:fe/provider/managers_provider.dart';
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
    // Debug: Log the incoming userVoteStatus from the API for this restaurant
    print("[DEBUG] Restaurant: ${restaurant.name}, API userVoteStatus: '${restaurant.userVoteStatus}', JSON Key: 'userVoteStatus'");

    VoteType? initialVote;
    String? voteStatusFromApi = restaurant.userVoteStatus?.trim().toUpperCase();

    if (voteStatusFromApi == 'LIKE') {
      initialVote = VoteType.LIKE;
    } else if (voteStatusFromApi == 'DISLIKE') {
      initialVote = VoteType.DISLIKE;
    }
    // 그 외의 경우 (null, 빈 문자열, 인식할 수 없는 값) initialVote는 null로 유지됩니다.

    // Debug: Log the parsed initialVote for this restaurant
    print("[DEBUG] Restaurant: ${restaurant.name}, Parsed initialVote: $initialVote (API 값: '$voteStatusFromApi')");

    VoteRestaurant updatedRestaurant = restaurant.copyWith(
      isScrapped: restaurant.isScrapped ?? false,
      // userVoteStatus도 유지되도록 명시적으로 설정
      userVoteStatus: restaurant.userVoteStatus
    );

    return VoteRestaurantState(
      restaurant: updatedRestaurant,
      userVote: initialVote,       
      isVoting: false              
    );
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

  // 큐 및 현재 상태 맵 초기화 (앱 재시작 시 호출)
  void reset() {
    _queue.clear();
    _currentVotes.clear();
    print("VoteQueue: 큐와 상태 맵 초기화됨");
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
  final VoteManager _voteManager;
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
    required VoteManager voteManager,
    required ScrapManager scrapManager,
  }) : _voteRepository = voteRepository, 
       _read = read, 
       _locationService = locationService,
       _voteManager = voteManager,
       _scrapManager = scrapManager,
       super(const VotePageCombinedState()) {
    _voteQueue = voteQueue ?? VoteQueue(voteRepository);
    // VoteQueue를 초기화하고 앱 시작 시 명시적으로 리셋
    _voteQueue.reset();
    _fetchInitialRestaurants();
  }

  @override
  void dispose() {
    _voteQueue.dispose();
    super.dispose();
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
      
      // 이전 로딩된 상태 정보를 Map으로 변환 (restaurant ID로 빠른 조회)
      final existingStatesMap = {
        for (var item in state.restaurants)
          item.restaurant.restaurantId: item
      };
      
      // API 응답을 VoteRestaurantState 목록으로 변환
      final initialRestaurantStates = restaurants.map((r) {
        // 1. 서버에서 받은 VoteRestaurant 객체로 초기 상태 생성
        VoteRestaurantState currentItemState = VoteRestaurantState.fromRestaurant(r);
        
        // 2. 이미 큐에 있는 항목이라면 큐의 투표 상태를 우선 적용 (아직 처리되지 않은 투표 처리)
        // 서버 응답에서 해석된 투표 상태 - fromRestaurant에서 파싱됨
        final VoteType? serverInterpretedVote = currentItemState.userVote;
        
        // 로컬 저장소에서 투표 상태 확인
        final VoteType? localVoteStatus = _voteManager.getVoteState(r.restaurantId);
        
        // 로컬 저장소의 투표 상태가 있으면 우선 적용
        if (localVoteStatus != null) {
          currentItemState = currentItemState.copyWith(
            userVote: localVoteStatus
          );
          
          // 투표 카운트 조정 (서버 값과 로컬 값이 다를 경우)
          if (serverInterpretedVote != localVoteStatus) {
            currentItemState = currentItemState.copyWith(
              restaurant: adjustVoteCounts(
                currentItemState.restaurant,
                serverInterpretedVote,
                localVoteStatus
              )
            );
          }
        }
        
        // VoteQueue에 보류 중인 투표가 있다면 적용
        if (_voteQueue._currentVotes.containsKey(r.restaurantId)) {
          final VoteType? pendingVote = _voteQueue.getCurrentVote(r.restaurantId);
          
          // 현재 적용된 투표와 큐의 보류 투표가 다를 경우 상태 업데이트
          final VoteType? currentVote = localVoteStatus ?? serverInterpretedVote;
          if (currentVote != pendingVote) {
             currentItemState = currentItemState.copyWith(
               userVote: pendingVote, // 큐의 보류 투표로 UI 상태 변경
               forceNullUserVote: pendingVote == null, // 취소 액션이면 null로 설정
               restaurant: adjustVoteCounts(
                   currentItemState.restaurant,
                   currentVote,
                   pendingVote
               )
             );
          }
        }

        // 3. 스크랩 상태 및 isVoting 같은 다른 UI 관련 상태 병합
        final existingStateFromPreviousLoad = existingStatesMap[r.restaurantId];
        
        // 스크랩 상태 결정 우선순위: API 응답 > 로컬 저장소 > 이전 상태 > 기본값
        bool finalIsScrapped = r.isScrapped ?? // API 응답 우선
                               _scrapManager.getScrapState(r.restaurantId) ?? // 그 다음 로컬 스크랩 매니저
                               existingStateFromPreviousLoad?.restaurant.isScrapped ?? // 이전 리스트에 있던 상태
                               false; // 기본값

        bool finalIsVoting = existingStateFromPreviousLoad?.isVoting ?? false; // 이전 로딩 상태 유지 (예: 정렬 변경 시)

        currentItemState = currentItemState.copyWith(
          isVoting: finalIsVoting,
          restaurant: currentItemState.restaurant.copyWith(
            isScrapped: finalIsScrapped
          ),
        );
        
        // isScrapped가 최종적으로 null이 아니도록 보장
        if (currentItemState.restaurant.isScrapped == null) {
           currentItemState = currentItemState.copyWith(restaurant: currentItemState.restaurant.copyWith(isScrapped: false));
        }

        return currentItemState;
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
    
    // 로컬 투표 상태 저장
    await _voteManager.setVoteState(restaurantId, newVoteType);
    
    try {
      // 큐에 투표 요청 추가
      _voteQueue.addVote(restaurantId, newVoteType);
      
      // 투표 큐 처리 (API 전송)
      await _voteQueue.processBatch();
      
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
    final currentScrapStatus = restaurant.isScrapped ?? false;
    final newScrapStatus = !currentScrapStatus;
    
    // 낙관적 UI 업데이트
    _updateRestaurantField(index, 'isScrapped', newScrapStatus);

    // 로컬 스크랩 상태 저장
    await _scrapManager.setScrapState(restaurantId, newScrapStatus);

    try {
      // API 호출
      final res = await _voteRepository.toggleScrap(restaurantId, newScrapStatus);
      print("스크랩 토글 응답: $res");
      return res;
    } catch (e) {
      // API 호출 실패 시 UI 롤백
      _updateRestaurantField(index, 'isScrapped', currentScrapStatus);
      await _scrapManager.setScrapState(restaurantId, currentScrapStatus); // 로컬 상태도 롤백
      print("스크랩 토글 실패: $e");
      throw e;
    }
  }

  void _updateRestaurantField(int index, String field, dynamic value) {
    if (index >= 0 && index < state.restaurants.length) {
      final updatedRestaurant = state.restaurants[index].restaurant.copyWith(
        isScrapped: field == 'isScrapped' ? value : state.restaurants[index].restaurant.isScrapped,
      );
      final updatedList = List<VoteRestaurantState>.from(state.restaurants);
      updatedList[index] = state.restaurants[index].copyWith(
        restaurant: updatedRestaurant,
      );
      state = state.copyWith(restaurants: updatedList);
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
        VoteRestaurantState initialState = VoteRestaurantState.fromRestaurant(r);
        
        // 로컬 저장소에서 투표 상태 확인
        final VoteType? localVoteStatus = _voteManager.getVoteState(r.restaurantId);
        
        if (localVoteStatus != null) {
          initialState = initialState.copyWith(
            userVote: localVoteStatus,
            restaurant: adjustVoteCounts(
              initialState.restaurant,
              initialState.userVote, // 서버 투표 상태
              localVoteStatus        // 로컬 투표 상태
            )
          );
        }
        
        // 스크랩 상태 확인
        final bool? localScrapStatus = _scrapManager.getScrapState(r.restaurantId);
        if (localScrapStatus != null) {
          initialState = initialState.copyWith(
            restaurant: initialState.restaurant.copyWith(
              isScrapped: localScrapStatus
            )
          );
        }
        
        return initialState;
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

// 3. StateNotifierProvider 수정 (상태 타입 변경)
final votePageStateProvider = StateNotifierProvider<VotePageStateNotifier, VotePageCombinedState>((ref) {
  final voteRepository = ref.watch(voteRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  final voteQueue = VoteQueue(voteRepository);
  final scrapManager = ref.watch(scrapManagerProvider); 
  final voteManager = ref.watch(voteManagerProvider);
  
  return VotePageStateNotifier(
    voteRepository: voteRepository,
    read: ref.read,
    locationService: locationService,
    voteQueue: voteQueue,
    scrapManager: scrapManager,
    voteManager: voteManager
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

  void vote(VoteType? voteType) {
    final notifier = ref.read(votePageStateProvider.notifier);
    notifier.vote(restaurantId, voteType);
  }

  Future<bool> toggleScrap() async {
    final notifier = ref.read(votePageStateProvider.notifier);
    return notifier.toggleScrap(restaurantId: restaurantId);
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