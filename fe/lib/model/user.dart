import 'package:fe/model/restaurant.dart';

class User{

  String? userId;
  String? userName;
  String? imageUrl;

  List<Restaurant> scrapList = [];

  User({
    this.userId,
    this.userName,
    this.imageUrl,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['name'];
    imageUrl = json['imageUrl1'];
    scrapList = json['scrap'] != null
        ? (json['scrap'] as List<dynamic>)
        .map((item) => Restaurant.fromJson(item as Map<String, dynamic>))
        .toList()
        : [];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = userId;
    data['userName'] = userName;
    data['imageUrl'] = imageUrl;
    return data;
  }
}

