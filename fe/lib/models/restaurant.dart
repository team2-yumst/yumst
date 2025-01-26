class Restaurant{

  String? restaurantId;
  String? restaurantName;
  String? category;
  String? address;
  String? phoneNumber;
  String? todayOpen;

  String? latitude;
  String? longitude;

  String? thumbnailUrl;

  Restaurant({
    this.restaurantId,
    this.restaurantName,
    this.category,
    this.address,
    this.phoneNumber,
    this.todayOpen,
    this.latitude,
    this.longitude,
    this.thumbnailUrl
  });

  Restaurant.fromJson(Map<String, dynamic> json){
    restaurantId = json['restaurantId'];
    restaurantName = json['restaurantName'];
    category = json['category'];
    address = json['address'];
    phoneNumber = json['phoneNumber'];
    todayOpen = json['todayOpen'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    thumbnailUrl = json['thumbnailUrl'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['restaurantId'] = restaurantId;
    data['restaurantName'] = restaurantName;
    data['category'] = category;
    data['address'] = address;
    data['phoneNumber'] = phoneNumber;
    data['todayOpen'] = todayOpen;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['thumbnailUrl'] = thumbnailUrl;
    return data;
  }

}

