import 'package:fe/data/register_state.dart';
import 'package:fe/repository/auth_repository.dart';
import 'package:fe/view/screen/main_page.dart';
import 'package:fe/view/widget/register_select_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurveyThird extends ConsumerWidget {
  const SurveyThird({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // step3 데이터를 List<String>으로 캐스팅
    final step3Data =
        ref.watch(registrationDataProvider)['step3'] as List<String>;
    final selectedOptions = step3Data.toSet();
    final authRepository = ref.watch(authRepositoryProvider);

    final String title = "어떤 카페를 좋아하나요?";
    final List<String> options = [
      "커피가 맛있는 곳",
      "디저트가 맛있는 곳",
      "집중하기 좋은 곳",
      "좌석이 편한 곳",
      "오래 머무르기 좋은 곳",
    ];
    const int maxSelection = 2;

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFDA5100)),
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
                  final currentSelections =
                      List<String>.from(currentData['step3']);
                  Set<String> newSet = Set<String>.from(currentSelections);
                  final String optionValue = options[i];

                  if (newSet.contains(optionValue)) {
                    newSet.remove(optionValue);
                  } else if (newSet.length < maxSelection) {
                    newSet.add(optionValue);
                  }

                  ref
                      .read(registrationDataProvider.notifier)
                      .updateStepData('step3', newSet.toList());
                },
              ),
              if (i != options.length - 1) const SizedBox(height: 10),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: selectedOptions.length == maxSelection
                  ? () async {
                      final data = ref.read(registrationDataProvider);
                      final success =
                          await authRepository.submitRegistrationData(data);
                      if (success) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );

                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) {
                            return MainScreen();
                          },
                        ), (route) => false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('데이터 전송에 실패했습니다.')),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedOptions.length == maxSelection
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "완료",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
