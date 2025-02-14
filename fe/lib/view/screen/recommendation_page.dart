import 'package:fe/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';

import '../../model/restaurant.dart';

final restaurantsFutureProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getRestaurants();
});

class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsFutureProvider);

    return restaurantsAsync.when(
      data: (restaurants) => Scaffold(
        body: Swiper(
          itemCount: restaurants.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            final restaurant = restaurants[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                // thumbnailUrl가 null일 수 있으므로 빈 문자열로 대체
                Image.network(
                  restaurant.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error),
                  ),
                ),
                Container(
                  // withOpacity 사용
                  color: Colors.black.withOpacity(0.3),
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // name가 null일 수 있으므로 빈 문자열로 대체
                      Text(
                        restaurant.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 주소는 fullAddress나 roadNameFullAddress 중 하나를 선택
                      Text(
                        restaurant.fullAddress ?? restaurant.roadNameFullAddress ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text("Error: $error")),
      ),
    );
  }
}

