// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoteRestaurant _$VoteRestaurantFromJson(Map<String, dynamic> json) =>
    VoteRestaurant(
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      businessHours: json['businessHours'] as String?,
      topFeatures: (json['top2Features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      likeCount: json['likeCount'] as int?,
      dislikeCount: json['dislikeCount'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      isScrapped: json['scrapped'] as bool?,
      userVoteStatus: json['voteStatus'] as String?,
    );

Map<String, dynamic> _$VoteRestaurantToJson(VoteRestaurant instance) =>
    <String, dynamic>{
      'restaurantId': instance.restaurantId,
      'name': instance.name,
      'category': instance.category,
      'thumbnailUrl': instance.thumbnailUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'businessHours': instance.businessHours,
      'top2Features': instance.topFeatures,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'distance': instance.distance,
      'scrapped': instance.isScrapped,
      'voteStatus': instance.userVoteStatus,
    }; 