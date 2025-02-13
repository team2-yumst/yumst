import 'package:fe/view/widget/register_select_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedIndexesProvider = StateProvider<Set<int>>((ref) => {});

class ThirdRegisterSelection extends ConsumerWidget {
  const ThirdRegisterSelection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndexes = ref.watch(selectedIndexesProvider);

    final String title = "어떤 카페를 좋아하나요?";
    final List<String> options = ["커피가 맛있는 곳", "디저트가 맛있는 곳", "집중하기 좋은 곳", "좌석이 편한 곳", "오래 머무르기 좋은 곳"];
    final int maxSelection = 2;

    return Scaffold(
      appBar: AppBar(),
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
                isSelected: selectedIndexes.contains(i),
                onTap: () {
                  ref.read(selectedIndexesProvider.notifier).update((state) {
                    final newSet = Set<int>.from(state);
                    if (newSet.contains(i)) {
                      newSet.remove(i); // 이미 선택된 경우 해제
                    } else if (newSet.length < maxSelection) {
                      newSet.add(i); // 최대 4개까지만 선택 가능
                    }
                    return newSet;
                  });
                },
              ),
              if (i != options.length - 1) const SizedBox(height: 10),
            ],
            const Spacer(), // 하단 버튼을 아래쪽으로 밀어줌

            ElevatedButton(
              onPressed: selectedIndexes.length == maxSelection
                  ? () {
                // 다음 화면으로 이동하는 로직 추가
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NextScreen()),
                );
              }
                  : null, // 4개가 선택되지 않으면 비활성화
              style: ElevatedButton.styleFrom(
                backgroundColor:
                selectedIndexes.length == maxSelection ? Colors.white.withValues(alpha: 0.6) : Colors.grey,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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

// 예시: 다음 화면 위젯
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("다음 화면")),
      body: const Center(child: Text("선택 완료!")),
    );
  }
}
