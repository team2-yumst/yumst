import 'package:json_annotation/json_annotation.dart';

part 'vote_restaurant.g.dart';

@JsonSerializable(explicitToJson: true)
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
  @JsonKey(name: 'voteStatus')
  final String? userVoteStatus; // 추가: 사용자의 투표 상태 (LIKE, DISLIKE, null)

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
    this.userVoteStatus,
  });

  factory VoteRestaurant.fromJson(Map<String, dynamic> json) =>
      _$VoteRestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$VoteRestaurantToJson(this);

  // copyWith 메소드 추가
  VoteRestaurant copyWith({
    String? restaurantId,
    String? name,
    String? category,
    String? thumbnailUrl,
    double? latitude,
    double? longitude,
    String? businessHours,
    List<String>? topFeatures,
    int? likeCount,
    int? dislikeCount,
    double? distance,
    bool? isScrapped,
    String? userVoteStatus,
  }) {
    return VoteRestaurant(
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      businessHours: businessHours ?? this.businessHours,
      topFeatures: topFeatures ?? this.topFeatures,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      distance: distance ?? this.distance,
      isScrapped: isScrapped ?? this.isScrapped,
      userVoteStatus: userVoteStatus ?? this.userVoteStatus,
    );
  }
} 