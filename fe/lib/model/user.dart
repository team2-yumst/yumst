import 'package:fe/model/restaurant.dart';

class User{

  String? userId;
  String? userName;
  String? imageUrl;

  bool? finishedSurvey;
  bool? agreedPrivacyPolicy;
  bool? agreedTermsOfService;
  bool? agreedLocationTerms;

  bool? enabled;

  List<Restaurant> scrapList = [];

  User({
    this.userId,
    this.userName,
    this.imageUrl,
    this.finishedSurvey,
    this.agreedPrivacyPolicy,
    this.agreedTermsOfService,
    this.agreedLocationTerms,
    this.enabled
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

    finishedSurvey = json['finishedSurvey'];
    agreedPrivacyPolicy = json['agreedPrivacyPolicy'];
    agreedTermsOfService = json['agreedTermsOfService'];
    agreedLocationTerms = json['agreedLocationTerms'];
    enabled = json['enabled'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = userId;
    data['userName'] = userName;
    data['imageUrl'] = imageUrl;
    return data;
  }
}

