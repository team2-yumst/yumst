import 'package:cached_network_image/cached_network_image.dart';
import 'package:fe/model/vote_restaurant.dart';
import 'package:fe/provider/vote_state_provider.dart'; // VoteType을 여기서 가져옴
// import 'package:fe/repository/vote_repository.dart'; // Repository 직접 사용 안 함
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// VoteRestaurantCard 위젯 정의 수정 (StatelessWidget으로 변경 가능하나 일단 유지)
class VoteRestaurantCard extends ConsumerStatefulWidget {
  final VoteRestaurant restaurant;
  final VoteType? userVote;
  final bool isVoting;
  final Function(VoteType) onVote;

  const VoteRestaurantCard({
    super.key,
    required this.restaurant,
    required this.userVote,
    required this.isVoting,
    required this.onVote,
  });

  @override
  ConsumerState<VoteRestaurantCard> createState() => _VoteRestaurantCardState();
}

class _VoteRestaurantCardState extends ConsumerState<VoteRestaurantCard> {
  bool _isDetailExpanded = false;

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final likeCount = restaurant.likeCount ?? 0;
    final dislikeCount = restaurant.dislikeCount ?? 0;
    final distance = restaurant.distance != null ? '${restaurant.distance!.round()}m' : '';
    final isScrapped = restaurant.isScrapped ?? false;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지
          if (restaurant.thumbnailUrl?.isNotEmpty == true)
            CachedNetworkImage(
              imageUrl: restaurant.thumbnailUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
            )
          else
            Container(
              color: Colors.grey[300],
              child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey)),
            ),

          // 확장 정보 패널
          if (_isDetailExpanded)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.95),
                      Colors.black.withOpacity(0.2)
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 식당 이름 + 접기 버튼
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() => _isDetailExpanded = false);
                          },
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    // 거리
                    Text(
                      distance,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    // 카테고리
                    if (restaurant.category != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Text(
                          restaurant.category!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    // 추가 정보
                    Text(
                      "서울특별시 마포구 서교동 358-45",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                    if (restaurant.businessHours != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          restaurant.businessHours!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    if (restaurant.topFeatures?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          restaurant.topFeatures!
                              .map((f) => '#$f')
                              .join(' '),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // 기본 하단 정보 (접혀있을 때)
          if (!_isDetailExpanded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 식당 이름
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 거리
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: Text(
                        distance,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    // 카테고리 + 상세 버튼
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          restaurant.category ?? '',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() => _isDetailExpanded = true);
                          },
                          child: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 투표 및 스크랩 버튼 (우측 정렬)
          Positioned(
            bottom: 45,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 좋아요 버튼
                IconButton(
                  icon: Icon(
                    widget.userVote == VoteType.LIKE
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => widget.onVote(VoteType.LIKE),
                ),
                Text(
                  likeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 2),
                // 싫어요 버튼
                IconButton(
                  icon: Icon(
                    widget.userVote == VoteType.DISLIKE
                        ? Icons.thumb_down
                        : Icons.thumb_down_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => widget.onVote(VoteType.DISLIKE),
                ),
                Text(
                  dislikeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 2),
                // 스크랩 버튼
                IconButton(
                  icon: Icon(
                    isScrapped ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    ref
                        .read(votePageStateProvider.notifier)
                        .toggleScrap(restaurant.restaurantId);
                  },
                ),
              ],
            ),
          ),

          // 로딩 인디케이터
          if (widget.isVoting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 투표 타입을 위한 Enum (제거하고 vote_state_provider.dart에서 가져오기) 