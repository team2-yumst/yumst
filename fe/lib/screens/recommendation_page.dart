import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';

class Restaurant {
  final String name;
  final String address;
  final String imageUrl;

  Restaurant({
    required this.name,
    required this.address,
    required this.imageUrl,
  });
}

final restaurantProvider = Provider<List<Restaurant>>((ref) {
  return [
    Restaurant(
      name: "Sunshine Diner",
      address: "123 Main St, Cityville",
      imageUrl: "https://source.unsplash.com/random/800x600/?restaurant",
    ),
    Restaurant(
      name: "Ocean Breeze Cafe",
      address: "456 Beach Rd, Seaside",
      imageUrl: "https://source.unsplash.com/random/800x600/?cafe",
    ),
    Restaurant(
      name: "Mountain View Grill",
      address: "789 Hilltop Ave, Mountainview",
      imageUrl: "https://source.unsplash.com/random/800x600/?grill",
    ),
  ];
});

class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(restaurantProvider);

    return Scaffold(
      body: Swiper(
        itemCount: restaurants.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          final restaurant = restaurants[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                restaurant.imageUrl,
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
                color: Colors.black.withOpacity(0.3),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      restaurant.address,
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
    );
  }
}

