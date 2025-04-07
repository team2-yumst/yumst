import 'package:json_annotation/json_annotation.dart';

part 'vote_restaurant.g.dart';

@JsonSerializable()
class VoteRestaurant {
  final String restaurantId;
  final String name;
  final String? category;
  final String? thumbnailUrl; // Assuming thumbnail might exist based on recommendation page
  final double? latitude;
  final double? longitude;
  final String? businessHours; // Assuming this maps from todayOpening
  @JsonKey(name: 'top2Features')
  final List<String>? topFeatures;
  final int? likeCount;
  final int? dislikeCount;
  final double? distance;
  @JsonKey(name: 'scrapped')
  final bool? isScrapped;

  VoteRestaurant({
    required this.restaurantId,
    required this.name,
    this.category,
    this.thumbnailUrl, // Added based on UI assumption
    this.latitude,
    this.longitude,
    this.businessHours,
    this.topFeatures,
    this.likeCount,
    this.dislikeCount,
    this.distance,
    this.isScrapped,
  });

  factory VoteRestaurant.fromJson(Map<String, dynamic> json) =>
      _$VoteRestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$VoteRestaurantToJson(this);
} 