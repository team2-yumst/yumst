class Restaurant {
  Restaurant({
    required this.restaurantId,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.thumbnailUrl,
    required this.fullAddress,
    required this.roadNameFullAddress,
    required this.phoneNumber,
    required this.todayOpening,
    required this.top2Features,
    required this.isScrapped,
    this.likeCount,
    this.dislikeCount,
  });

  String? restaurantId;
  String? name;
  String? category;
  String? latitude;
  String? longitude;
  String? thumbnailUrl;

  String? fullAddress;
  String? roadNameFullAddress;

  String? phoneNumber;

  String? todayOpening;
  List<String>? top2Features;
  bool? isScrapped;
  int? likeCount;
  int? dislikeCount;

  Restaurant.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    name = json['name'];
    category = json['category'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    thumbnailUrl = json['thumbnailUrl'];
    fullAddress = json['fullAddress'];
    roadNameFullAddress = json['roadNameFullAddress'];
    phoneNumber = json['phoneNumber'];
    todayOpening = json['todayOpening'];
    if (json['top2Features'] != null && json['top2Features'] is List) {
        top2Features = List<String>.from(json['top2Features']);
    } else {
        top2Features = null;
    }
    isScrapped = json['scrapped'];
    likeCount = json['likeCount'];
    dislikeCount = json['dislikeCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['category'] = category;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['thumbnailUrl'] = thumbnailUrl;
    data['fullAddress'] = fullAddress;
    data['roadNameFullAddress'] = roadNameFullAddress;
    data['likeCount'] = likeCount;
    data['dislikeCount'] = dislikeCount;
    return data;
  }

}
