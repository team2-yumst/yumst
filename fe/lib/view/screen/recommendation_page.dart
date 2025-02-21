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
/// - 접힌 상태에서는 추가 정보 위젯을 완전히 제거하여 높이가 일정함
///
class _ReelsStyleCard extends ConsumerStatefulWidget {
  final Restaurant restaurant;

  const _ReelsStyleCard({super.key, required this.restaurant});

  @override
  ConsumerState<_ReelsStyleCard> createState() => _ReelsStyleCardState();
}

class _ReelsStyleCardState extends ConsumerState<_ReelsStyleCard>
    with SingleTickerProviderStateMixin {
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
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _infoAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  Future<void> _toggleScrap() async {
    try {
      await ref
          .read(restaurantRepositoryProvider)
          .scrapRestaurant(widget.restaurant);
      setState(() {}); // 스크랩 상태 변경 후 UI 갱신
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("스크랩 실패: $e")),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 이미 펼쳐진 상태에서 카드 전체 탭 시 접기
        if (_isExpanded) _togglePanel();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// 1) 배경 이미지
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

          /// 2) 펼쳤을 때 배경 어둡게 처리
          if (_isExpanded)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _isExpanded ? 0.3 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(color: Colors.black),
                ),
              ),
            ),

          /// 3) 하단 정보 패널
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                // 하단 패널 전체
                padding: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                constraints: const BoxConstraints(minHeight: 120),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    /// 왼쪽 영역
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상단 기본 정보 (이름, 카테고리, 더보기)
                          SlideTransition(
                            position: _titleAnimation,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                // 왼쪽 정렬
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 식당 이름, 카테고리
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurant.name ?? '',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
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
                                            // '더 보기' 토글 버튼
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
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 추가 정보 (펼쳐졌을 때만)
                          FadeTransition(
                            opacity: _infoAnimation,
                            child: SizeTransition(
                              sizeFactor: _infoAnimation,
                              axisAlignment: -1,
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.fullAddress ?? '정보 없음',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      restaurant.todayOpening ??
                                          '오늘 오픈 정보 없음',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '#${restaurant.top2Features?[0]}  #${restaurant.top2Features?[1]}' ??
                                          '정보 없음',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 오른쪽 영역
                    /// - 스크랩 버튼 + 추가 버튼들이 들어갈 예정
                    Container(
                      width: 80, // 원하는 너비로 조정
                      padding: const EdgeInsets.only(right: 10, bottom: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // TODO: 여기에 신고 / 투표 좋아요 싫어요 개수 / 공유 버튼 추가
                          IconButton(
                            icon: Icon(
                              (restaurant.isScrapped ?? false)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            onPressed: _toggleScrap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
