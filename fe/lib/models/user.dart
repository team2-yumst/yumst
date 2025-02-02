class User{

  String? userId;
  String? userName;

  User({
    this.userId,
    this.userName
  });

  User.fromJson(Map<String, dynamic> json){
    userId = json['userId'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = userId;
    data['userName'] = userName;
    return data;
  }
}

