import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../model/restaurant.dart';
import '../repository/restaurant_repository.dart';
import 'location_service.dart';

final transportationModeProvider = StateProvider<String>((ref) => 'walk');


class RestaurantPaginationNotifier extends StateNotifier<AsyncValue<List<Restaurant>>> {
  RestaurantPaginationNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;
  int _currentPage = 1;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;

  bool _hasMore = true;
  bool _isLoadingNextPage = false;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoadingNextPage;

  Future<void> _init() async {
    await loadInitial();
    _setupLocationListener();
  }

  void _setupLocationListener() {
    _locationSubscription = ref
        .read(locationServiceProvider)
        .getPositionStream()
        .listen((newPosition) {
      _handlePositionChange(newPosition);
    });
  }

  void _handlePositionChange(Position newPosition) {
    if (_currentPosition == null) return;

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    // 1km 이상 이동 시 새로고침
    if (distance > 1000) {
      _currentPosition = newPosition;
      loadInitial();
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  // 위치는 initial load 시에만 가져옴 - 페이징 기준을 유지 하기 위해
  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    try {
      _currentPage = 1;
      _hasMore = true;
      _isLoadingNextPage = false;

      final transportMode = ref.read(transportationModeProvider);
      final locationService = ref.read(locationServiceProvider);
      _currentPosition = await locationService.getPosition();

      final repository = ref.read(restaurantRepositoryProvider);
      final restaurants = await repository.getRecommendations(
        _currentPosition!,
        _currentPage,
        transportMode: transportMode, // 이동 수단 파라미터 추가
      );

      _hasMore = restaurants.isNotEmpty;
      state = AsyncValue.data(restaurants);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // 이동 수단 변경 시 초기화 메서드
  Future<void> switchTransportMode(String newMode) async {
    ref.read(transportationModeProvider.notifier).state = newMode;
    await loadInitial();
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || _currentPosition == null || _isLoadingNextPage) return;

    _isLoadingNextPage = true;
    _currentPage++;
    final transportMode = ref.read(transportationModeProvider);

    try {
      final repository = ref.read(restaurantRepositoryProvider);
      final newRestaurants = await repository.getRecommendations(_currentPosition!, _currentPage, transportMode: transportMode);
      _hasMore = newRestaurants.isNotEmpty;
      state = AsyncValue.data([...state.value ?? [], ...newRestaurants]);
    } catch (e, st) {
      _currentPage--;
      state = AsyncValue.error(e, st);
    } finally {
      _isLoadingNextPage = false;
    }
  }
}

final restaurantPaginationProvider = StateNotifierProvider.autoDispose<RestaurantPaginationNotifier, AsyncValue<List<Restaurant>>>((ref) {
  return RestaurantPaginationNotifier(ref);
});