import 'package:fe/data/register_state.dart';
import 'package:fe/view/screen/register_third_selection_page.dart';
import 'package:fe/view/widget/register_select_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecondRegisterSelection extends ConsumerWidget {
  const SecondRegisterSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // step2 데이터를 List<String>으로 캐스팅
    final step2Data = ref.watch(registrationDataProvider)['step2'] as List<String>;
    final selectedOptions = step2Data.toSet();

    final String title = "어떤 식당을 좋아하나요?";
    final List<String> options = [
      "혼밥하기 좋은 곳",
      "양이 많은 곳",
      "재료가 신선한 곳",
      "빨리 나오는 곳",
      "맛있는 곳"
    ];
    final int maxSelection = 2;

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
                  final currentSelections = List<String>.from(currentData['step2']);
                  Set<String> newSet = Set<String>.from(currentSelections);
                  final String optionValue = options[i];

                  if (newSet.contains(optionValue)) {
                    newSet.remove(optionValue);
                  } else if (newSet.length < maxSelection) {
                    newSet.add(optionValue);
                  }

                  ref.read(registrationDataProvider.notifier)
                      .updateStepData('step2', newSet.toList());
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
                  builder: (context) => const ThirdRegisterSelection(),
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
