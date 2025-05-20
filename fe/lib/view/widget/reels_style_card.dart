import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe/model/restaurant.dart';
import 'package:fe/repository/restaurant_repository.dart';


class ReelsStyleCard extends ConsumerStatefulWidget {
  final Restaurant restaurant;

  const ReelsStyleCard({super.key, required this.restaurant});

  @override
  ConsumerState<ReelsStyleCard> createState() => _ReelsStyleCardState();
}

class _ReelsStyleCardState extends ConsumerState<ReelsStyleCard>
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
          CachedNetworkImage(
            imageUrl: restaurant.thumbnailUrl ?? '',
            fit: BoxFit.cover,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error)),
            progressIndicatorBuilder: (context, url, progress) =>
            const Center(child: CircularProgressIndicator()),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          restaurant.distance != null
                                              ? (restaurant.distance! >= 1000
                                          // 1000m 이상이면 km로 변환하여 소수점 한 자리까지 표시
                                              ? '${(restaurant.distance! / 1000).toStringAsFixed(1)}km'
                                          // 1000m 미만이면 정수 m로 표시
                                              : '${restaurant.distance!.toStringAsFixed(0)}m')
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
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
                                      _buildTopFeatures(restaurant.top2Features),
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
                          // 이동 수단 토글 버튼
                          // Consumer(
                          //   builder: (context, ref, _) {
                          //     final transportMode = ref.watch(transportationModeProvider);
                          //     return IconButton(
                          //       icon: AnimatedSwitcher(
                          //         duration: const Duration(milliseconds: 200),
                          //         child: transportMode == 'car'
                          //             ? const Icon(
                          //           Icons.directions_car, // 색칠된 차량 아이콘
                          //           key: ValueKey('car_filled'),
                          //           color: Colors.white,
                          //         )
                          //             : const Icon(
                          //           Icons.directions_car_outlined, // 테두리만 있는 차량 아이콘
                          //           key: ValueKey('car_outlined'),
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //       onPressed: () {
                          //         final newMode = transportMode == 'car' ? 'walk' : 'car';
                          //         ref.read(transportationModeProvider.notifier).state = newMode;
                          //       },
                          //     );
                          //   },
                          // ),
                          SizedBox(height: 10),
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
                      )
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

// 2개 미만일 경우를 위해 분리
String _buildTopFeatures(List<String>? features) {
  if (features == null || features.isEmpty) {
    return '정보 없음';
  }
  return features.take(2).map((feature) => '#$feature').join(' ');
}

