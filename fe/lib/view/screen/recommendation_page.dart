import 'package:fe/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../model/restaurant.dart';

final restaurantsFutureProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getRestaurants();
});

class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsFutureProvider);

    return restaurantsAsync.when(
      data: (restaurants) => Scaffold(
        body: Swiper(
          itemCount: restaurants.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            final restaurant = restaurants[index];
            return _ReelsStyleCard(restaurant: restaurant);
          },
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text("Error: $error")),
      ),
    );
  }
}

///
/// 인스타 Reels 스타일의 카드 UI
/// - 기본 정보(이름, 카테고리)는 항상 하단에 보임
/// - '더 보기' 버튼을 누르면 하단 컨테이너가 위로 확장되어 추가 정보가 나타남
/// - 패널 배경을 투명하게 처리하여 배경 이미지를 잘 보이게 함
///
class _ReelsStyleCard extends StatefulWidget {
  final Restaurant restaurant;
  const _ReelsStyleCard({super.key, required this.restaurant});

  @override
  State<_ReelsStyleCard> createState() => _ReelsStyleCardState();
}


class _ReelsStyleCardState extends State<_ReelsStyleCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<Offset> _titleAnimation;
  late Animation<double> _infoAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _titleAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3), // 위로 30% 이동
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _infoAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 배경 이미지 및 기존 오버레이 (동일)
        Image.network(
          restaurant.thumbnailUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.error)),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
        // 2) 기본 오버레이
        Container(color: Colors.black.withOpacity(0.2)),

        // 하단 고정 높이 컨테이너
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 120, // 높이 고정
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: Stack(
              children: [
                // 추가 정보 (페이드 인 아웃)
                FadeTransition(
                  opacity: _infoAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "주소: ${restaurant.fullAddress ?? '정보 없음'}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          "위도: ${restaurant.latitude ?? '정보 없음'}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // 제목 & 카테고리 (슬라이드 애니메이션)
                SlideTransition(
                  position: _titleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Row(
                              children: [
                                Text(
                                  restaurant.category ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_down
                                        : Icons.more_horiz,
                                    color: Colors.white,
                                  ),
                                  onPressed: _togglePanel,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
