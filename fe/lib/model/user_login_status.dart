import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_login_status.g.dart';

enum LoginType { google, apple, guest }

@Riverpod(keepAlive: true)
UserLoginStatus userLoginStatus(Ref ref) {
  return UserLoginStatus();
}

class UserLoginStatus {
  UserLoginStatus({
    this.loginType = LoginType.google,
    this.firstPageComplete = false,
    this.secondPageComplete = false,
    this.thirdPageComplete = false,
    this.fourthPageComplete = false,
  });

  final LoginType loginType;
  final bool firstPageComplete;
  final bool secondPageComplete;
  final bool thirdPageComplete;
  final bool fourthPageComplete;
}


