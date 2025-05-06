// provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registrationDataProvider = StateNotifierProvider<RegistrationDataNotifier, Map<String, dynamic>>(
      (ref) => RegistrationDataNotifier(),
);

class RegistrationDataNotifier extends StateNotifier<Map<String, dynamic>> {
  RegistrationDataNotifier()
      : super({
    'step1': <String>[],
    'step2': <String>[],
    'step3': <String>[],
  });

  // selections 매개변수의 타입을 List<String>으로 변경
  void updateStepData(String stepKey, List<String> selections) {
    state = {...state, stepKey: selections};
  }
}
