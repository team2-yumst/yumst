import 'package:cached_network_image/cached_network_image.dart';
import 'package:fe/model/vote_restaurant.dart';
import 'package:fe/model/vote_types.dart'; // VoteType을 여기서 가져옴
import 'package:fe/provider/vote_state_provider.dart'; // votePageStateProvider를 사용하기 위해 필요
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
  // 로컬 상태로 스크랩 상태와 로딩 상태 관리
  bool? _localIsScrapped; // 초기값은 null로 설정하여 위젯 restaurant 값으로 초기화
  bool _isLoadingScrap = false;

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때 restaurant 객체의 스크랩 상태로 로컬 상태 초기화
    _localIsScrapped = widget.restaurant.isScrapped;
    
    // 스크랩 상태가 null이면 기본값으로 false 설정
    if (_localIsScrapped == null) {
      _localIsScrapped = false;
    }
  }

  // props로 전달된 restaurant 객체의 isScrapped 상태가 변경될 때 로컬 상태도 동기화
  @override
  void didUpdateWidget(covariant VoteRestaurantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 위젯의 isScrapped 값이 변경되었고, null이 아닌 경우에만 업데이트
    if (widget.restaurant.isScrapped != oldWidget.restaurant.isScrapped && 
        widget.restaurant.isScrapped != null) {
      if (mounted) {
        setState(() {
          _localIsScrapped = widget.restaurant.isScrapped;
        });
      }
    }
  }

  Future<void> _toggleScrap() async {
    if (_isLoadingScrap) return; // 이미 로딩 중이면 중복 호출 방지

    final originalScrapStatus = _localIsScrapped; // 롤백을 위한 원래 상태 저장
    final restaurantId = widget.restaurant.restaurantId; // 식당 ID 저장

    if (mounted) {
      setState(() {
        _localIsScrapped = !(_localIsScrapped ?? false); // 낙관적 업데이트
        _isLoadingScrap = true;
      });
    }

    try {
      // votePageStateProvider를 통해 스크랩 상태 변경
      final result = await ref
          .read(votePageStateProvider.notifier)
          .toggleScrap(restaurantId: restaurantId);
          
      // 서버 응답과 상태가 일치하지 않으면 서버 응답으로 상태 조정
      if (mounted && result != _localIsScrapped) {
        setState(() {
          _localIsScrapped = result;
        });
      }
    } catch (e) {
      // API 호출 실패 시 롤백 및 오류 표시
      if (mounted) {
        setState(() {
          _localIsScrapped = originalScrapStatus; // 원래 상태로 되돌림
        });
        
        // 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("스크랩 처리 중 오류가 발생했습니다"),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: '확인',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      // 작업 완료 후 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoadingScrap = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final likeCount = restaurant.likeCount ?? 0;
    final dislikeCount = restaurant.dislikeCount ?? 0;
    final distance = restaurant.distance != null ? '${restaurant.distance!.round()}m' : '';
    
    // 스크랩 상태는 무조건 _localIsScrapped를 사용
    final displayScrapStatus = _localIsScrapped ?? false;

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

          // 하단 정보 패널 (식당 이름, 거리, 카테고리만)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  // 카테고리
                  Text(
                    restaurant.category ?? '',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  icon: _isLoadingScrap
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          displayScrapStatus ? Icons.bookmark : Icons.bookmark_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _toggleScrap, // _toggleScrap 함수 호출
                ),
              ],
            ),
          ),

          // 로딩 인디케이터
          if (widget.isVoting) // 스크랩 로딩(_isLoadingScrap)과 별개로 투표 로딩 상태
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
