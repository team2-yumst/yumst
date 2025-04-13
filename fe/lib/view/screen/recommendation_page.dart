import 'package:fe/data/location_service.dart';
import 'package:fe/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../data/restaurant_pagination.dart';
import '../../model/restaurant.dart';
import '../widget/reels_style_card.dart';

final restaurantsFutureProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  final position = await locationService.getPosition();
  return repository.getRestaurantsV0(position);
});

class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantPaginationProvider);

    return Scaffold(
      body: restaurantsAsync.when(
        data: (restaurants) => Swiper(
          itemCount: restaurants.length + 1, // +1 for loading indicator
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            if (index == restaurants.length) {
              ref.read(restaurantPaginationProvider.notifier).loadNextPage();
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
