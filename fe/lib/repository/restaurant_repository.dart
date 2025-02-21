import 'package:dio/dio.dart';
import 'package:fe/model/restaurant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/token_interceptor.dart';

part 'restaurant_repository.g.dart';

@Riverpod(keepAlive: true)
RestaurantRepository restaurantRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return RestaurantRepository(dio: dio);
}

class RestaurantRepository {
  RestaurantRepository({
    required this.dio,
  });
  final Dio dio;

  Future<List<Restaurant>> getRestaurants() async {

    final response = await dio.get("http://localhost:8080/api/restaurant/v0");

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception("식당 정보를 불러오는데 실패했습니다.");
    }
  }

  Future scrapRestaurant(Restaurant restaurant) async {
    final response = await dio.post(
        "http://localhost:8080/api/user/v1/scrap/${restaurant.restaurantId}"
    );
    if (response.statusCode == 200) {
      restaurant.isScrapped = response.data['scrapped'];
      return;
    } else {
      throw Exception("스크랩 실패");
    }
  }




}