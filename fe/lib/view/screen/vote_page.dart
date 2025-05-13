import 'package:fe/provider/vote_state_provider.dart';
import 'package:fe/repository/vote_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widget/vote_restaurant_card.dart';

// 4. VotePage 위젯
class VotePage extends ConsumerStatefulWidget {
  const VotePage({super.key});

  @override
  ConsumerState<VotePage> createState() => _VotePageState();
}

class _VotePageState extends ConsumerState<VotePage> {
  final ScrollController _scrollController = ScrollController();
  String _selectedSort = 'distance';

  final Map<String, String> _sortOptions = {
    'distance': '거리순',
    'likes': '좋아요 순',
    'dislikes': '싫어요 순',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // 페이지 진입 시 명시적으로 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(votePageStateProvider.notifier).changeSort(_selectedSort);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;
    final double triggerThreshold = maxScroll * 0.8;

    if (currentScroll >= triggerThreshold) {
      ref.read(votePageStateProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final votePageState = ref.watch(votePageStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 정렬 버튼 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    value: _selectedSort,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple, fontSize: 14),
                    underline: Container( height: 0, color: Colors.transparent,),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != _selectedSort) {
                        setState(() {
                          _selectedSort = newValue;
                        });
                        ref.read(votePageStateProvider.notifier).changeSort(newValue);
                      }
                    },
                    items: _sortOptions.entries
                        .map<DropdownMenuItem<String>>((MapEntry<String, String> entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // 식당 목록 영역
            Expanded(
              child: _buildRestaurantList(votePageState),
            ),
          ],
        ),
      ),
    );
  }

  // 식당 목록 UI 빌드 로직 분리
  Widget _buildRestaurantList(VotePageCombinedState stateData) {
    // 1. 초기 로딩 중일 때
    if (stateData.isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    // 2. 에러가 있고, 데이터가 없을 때 (초기 로딩 실패)
    if (stateData.error != null && stateData.restaurants.isEmpty) {
      String errorMessage = stateData.error.toString();
      // Exception 메시지에서 'Exception:' 부분 제거
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(votePageStateProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              )
            ],
          ),
        )
      );
    }
    // 3. 데이터가 있을 때 (로딩 성공 또는 페이지네이션 중)
    return Theme(
      // 스크롤바 스타일 테마 설정
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.white.withOpacity(0.5)),
          thickness: MaterialStateProperty.all(6.0),
          radius: const Radius.circular(8.0),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      ),
      child: Scrollbar(
        controller: _scrollController,
        child: RefreshIndicator(
          onRefresh: () => ref.read(votePageStateProvider.notifier).refresh(),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 0.7,
            ),
            itemCount: stateData.restaurants.length + (stateData.isLoadingNextPage || (stateData.error != null && !stateData.isLoadingInitial) ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == stateData.restaurants.length) {
                if (stateData.isLoadingNextPage) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ));
                } else if (stateData.error != null && !stateData.isLoadingInitial) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text("다음 페이지 로딩 실패", style: TextStyle(color: Colors.red)),
                         SizedBox(height: 4),
                         // 여기서 '다시 시도' 버튼을 추가할 수도 있습니다.
                         // ElevatedButton(onPressed: () => ref.read(votePageStateProvider.notifier).loadNextPage(), child: Text('다음 페이지 재시도'))
                      ],
                    )
                  ));
                }
                return const SizedBox.shrink();
              }
              final restaurantState = stateData.restaurants[index];
              return VoteRestaurantCard(
                key: ValueKey(restaurantState.restaurant.restaurantId),
                restaurant: restaurantState.restaurant,
                userVote: restaurantState.userVote,
                isVoting: restaurantState.isVoting,
                isScraped: restaurantState.isScraped,
                onVotePressed: (restaurant, voteType) {
                  ref.read(votePageStateProvider.notifier).vote(
                    restaurant.restaurantId,
                    voteType,
                  );
                },
                onScrapPressed: (restaurant) async {
                  return await ref.read(votePageStateProvider.notifier).toggleScrap(
                    restaurantId: restaurant.restaurantId,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
} 