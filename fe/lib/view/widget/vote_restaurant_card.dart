import 'package:cached_network_image/cached_network_image.dart';
import 'package:fe/model/vote_restaurant.dart';
// import 'package:fe/repository/vote_repository.dart'; // Repository 직접 사용 안 함
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// VoteRestaurantCard 위젯 정의 수정 (StatelessWidget으로 변경 가능하나 일단 유지)
class VoteRestaurantCard extends ConsumerWidget { // ConsumerWidget으로 변경
  final VoteRestaurant restaurant;
  final VoteType? userVote; // 외부에서 전달받는 투표 상태
  final bool isVoting;      // 외부에서 전달받는 로딩 상태
  final Function(VoteType) onVote; // 외부에서 전달받는 투표 콜백

  const VoteRestaurantCard({
    super.key,
    required this.restaurant,
    required this.userVote,
    required this.isVoting,
    required this.onVote,
  });

  // State 클래스 및 내부 상태, _handleVote 메소드 제거됨
  // initState, setState 등도 제거

  @override
  Widget build(BuildContext context, WidgetRef ref) { // WidgetRef 추가
    // final restaurant = widget.restaurant; // ConsumerWidget에서는 직접 접근

    // 좋아요/싫어요 카운트는 restaurant 객체에서 직접 읽음
    final likeCount = restaurant.likeCount ?? 0;
    final dislikeCount = restaurant.dislikeCount ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 배경 이미지 (동일)
          if (restaurant.thumbnailUrl != null && restaurant.thumbnailUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: restaurant.thumbnailUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
            )
          else
            Container(
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
            ),

          // 2. 하단 정보 영역 + 투표 버튼 통합
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 왼쪽: 식당 정보 (동일)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (restaurant.category != null)
                          Text(
                            restaurant.category!,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // 오른쪽: 투표 버튼 (세로 배치)
                  isVoting
                      ? SizedBox(
                          width: 50,
                          height: 80, // 세로 높이 확보
                          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
                        )
                      : Column( // Column으로 변경하여 세로 배치
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 좋아요 (위에 배치)
                            IconButton(
                              icon: Icon(
                                userVote == VoteType.LIKE ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                color: Colors.white,
                              ),
                              iconSize: 24,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () => onVote(VoteType.LIKE),
                            ),
                            Text(likeCount.toString(), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4), // 아이콘 사이 간격
                            // 싫어요 (아래에 배치)
                            IconButton(
                              icon: Icon(
                                userVote == VoteType.DISLIKE ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                                color: Colors.white,
                              ),
                              iconSize: 24,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () => onVote(VoteType.DISLIKE),
                            ),
                            Text(dislikeCount.toString(), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 투표 타입을 위한 Enum (동일)
enum VoteType { LIKE, DISLIKE } 