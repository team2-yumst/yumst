import 'package:fe/data/location_service.dart';
import 'package:fe/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../data/restaurant_paginator.dart';
import '../../model/restaurant.dart';
import '../widget/reels_style_card.dart';

final restaurantsFutureProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  final position = await locationService.getPosition();
  return repository.getRestaurantsV0(position);
});

class RecommendationPage extends ConsumerStatefulWidget {
  const RecommendationPage({super.key});

  @override
  ConsumerState<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends ConsumerState<RecommendationPage> {
  final SwiperController _swiperController = SwiperController();
  final int _preloadThreshold = 4; // 6번째에서 미리 로드

  void _handleIndexChanged(int index) {
    final asyncValue = ref.read(restaurantPaginationProvider);
    final notifier = ref.read(restaurantPaginationProvider.notifier);

    if (asyncValue is! AsyncData) return;

    final remainingItems = asyncValue.value!.length - index;
    if (remainingItems <= _preloadThreshold &&
        notifier.hasMore &&
        !notifier.isLoading) {
      notifier.loadNextPage();
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantPaginationProvider);

    return Scaffold(
      body: restaurantsAsync.when(
        data: (restaurants) => Swiper(
          controller: _swiperController,
          onIndexChanged: _handleIndexChanged,
          itemCount: restaurants.length + 1,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            if (index == restaurants.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return ReelsStyleCard(restaurant: restaurants[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
      ),
    );
  }
}