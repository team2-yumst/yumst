class Restaurant {
  Restaurant(this.name, this.category, this.latitude, this.longitude,
      this.thumbnailUrl, this.fullAddress, this.roadNameFullAddress);

  String? name;
  String? category;

  String? latitude;
  String? longitude;

  String? thumbnailUrl;

  String? fullAddress;
  String? roadNameFullAddress;

  Restaurant.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    category = json['category'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    thumbnailUrl = json['thumbnailUrl'];
    fullAddress = json['fullAddress'];
    roadNameFullAddress = json['roadNameFullAddress'];
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
    return data;
  }

}
