import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../model/restaurant.dart';
import '../repository/restaurant_repository.dart';
import 'location_service.dart';

class RestaurantPaginationNotifier extends StateNotifier<AsyncValue<List<Restaurant>>> {
  RestaurantPaginationNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  final Ref ref;
  int _currentPage = 1;
  bool _hasMore = true;
  Position? _currentPosition;

  // 위치는 initial load 시에만 가져옴 - 페이징 기준을 유지 하기 위해
  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    try {
      final locationService = ref.read(locationServiceProvider);
      _currentPosition = await locationService.getPosition();
      final repository = ref.read(restaurantRepositoryProvider);
      final restaurants = await repository.getWalkRecommendations(_currentPosition!, _currentPage);
      _hasMore = restaurants.isNotEmpty;
      state = AsyncValue.data(restaurants);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || _currentPosition == null) return;

    _currentPage++;
    try {
      final repository = ref.read(restaurantRepositoryProvider);
      final newRestaurants = await repository.getWalkRecommendations(_currentPosition!, _currentPage);
      _hasMore = newRestaurants.isNotEmpty;
      state = AsyncValue.data([...state.value ?? [], ...newRestaurants]);
    } catch (e, st) {
      _currentPage--;
      state = AsyncValue.error(e, st);
    }
  }
}

final restaurantPaginationProvider = StateNotifierProvider.autoDispose<RestaurantPaginationNotifier, AsyncValue<List<Restaurant>>>((ref) {
  return RestaurantPaginationNotifier(ref);
});