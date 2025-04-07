import 'package:fe/data/location_service.dart';
import 'package:fe/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../model/restaurant.dart';
import '../widget/reels_style_card.dart';

final restaurantsFutureProvider = FutureProvider<List<Restaurant>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getRestaurants(position);
});

class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsFutureProvider);

    return restaurantsAsync.when(
      data: (restaurants) => Scaffold(
        body: Swiper(
          itemCount: restaurants.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return ReelsStyleCard(restaurant: restaurants[index]);
          },
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text("Error loading recommendations: $error")),
      ),
    );
  }
}
