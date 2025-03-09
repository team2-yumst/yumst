// first_register_selection.dart
import 'package:fe/data/register_state.dart';
import 'package:fe/view/screen/auth_page/survey_second_page.dart';
import 'package:fe/view/widget/register_select_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurveyFirst extends ConsumerWidget {
  const SurveyFirst({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // step1 데이터는 이제 List<String> 타입입니다.
    final step1Data = ref.watch(registrationDataProvider)['step1'] as List<String>;
    final selectedOptions = step1Data.toSet();

    final String title = "선호하는 분위기를 알려주세요";
    final List<String> options = [
      "친절한 곳",
      "인테리어가 멋진 곳",
      "가성비 좋은 곳",
      "청결한 곳",
      "대화하기 좋은 곳",
      "단체 모임하기 좋은 곳",
      "주차하기 편한 곳",
      "넓은 곳",
      "뷰가 좋은 곳",
      "특별한 날 가기 좋은 곳"
    ];
    final int maxSelection = 4;

    return Scaffold(
      body: Container(
        color: const Color(0xFFDA5100),
        padding: const EdgeInsets.only(top: 100, bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            for (int i = 0; i < options.length; i++) ...[
              SelectionButton(
                text: options[i],
                isSelected: selectedOptions.contains(options[i]),
                onTap: () {
                  final currentData = ref.read(registrationDataProvider);
                  // 현재 step1의 데이터는 List<String>입니다.
                  final currentSelections = List<String>.from(currentData['step1']);
                  final Set<String> newSet = Set<String>.from(currentSelections);
                  final String optionValue = options[i];

                  if (newSet.contains(optionValue)) {
                    newSet.remove(optionValue);
                  } else if (newSet.length < maxSelection) {
                    newSet.add(optionValue);
                  }

                  ref
                      .read(registrationDataProvider.notifier)
                      .updateStepData('step1', newSet.toList());
                },
              ),
              if (i != options.length - 1) const SizedBox(height: 10),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: selectedOptions.length == maxSelection
                  ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SurveySecond(),
                ),
              )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedOptions.length == maxSelection
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "다음",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
