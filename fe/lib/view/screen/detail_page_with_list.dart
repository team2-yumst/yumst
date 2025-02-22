import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:fe/model/restaurant.dart';

import '../widget/reels_style_card.dart';

class RestaurantReelsScreen extends ConsumerWidget {
  final List<Restaurant> restaurants;
  final int initialIndex;

  const RestaurantReelsScreen({
    super.key,
    required this.restaurants,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          ),
        ),
      body: Swiper(
        index: initialIndex,
        loop: false,
        itemCount: restaurants.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return ReelsStyleCard(restaurant: restaurants[index]);
        },
      ),
    );
  }
}