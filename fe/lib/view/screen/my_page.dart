import 'package:cached_network_image/cached_network_image.dart';
import 'package:fe/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe/model/restaurant.dart';
import 'package:fe/model/user.dart';

import 'detail_page_with_list.dart';

final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return repository.getUser();
});

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  double _scrollOffset = 0;
  bool _isRefreshing = false;

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await ref.refresh(userProvider.future);
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) => NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            if (!_isRefreshing) {
              setState(() {
                _scrollOffset = notification.metrics.pixels;
              });

              if (_scrollOffset < -150 && !_isRefreshing) {
                _refreshData();
              }
            }
            return true;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _isRefreshing ? 60 : 0,
                  curve: Curves.easeOut,
                  child: Center(
                    child: _isRefreshing
                        ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0XC8530EFF)),
                    )
                        : const SizedBox(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _UserProfileSection(user: user),
              ),
              _ScrapGrid(scrapList: user.scrapList),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfileSection extends StatelessWidget {
  final User user;

  const _UserProfileSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user.imageUrl != null
                ? CachedNetworkImageProvider(user.imageUrl!)
                : null,
            child: user.imageUrl == null
                ? const Icon(Icons.person_rounded, size: 40)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            user.userName ?? 'guest',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('스크랩', user.scrapList.length),
              // 추가 통계 정보 필요시 여기에 추가
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}

class _ScrapGrid extends StatelessWidget {
  final List<Restaurant> scrapList;

  const _ScrapGrid({required this.scrapList});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _ScrapGridItem(
              restaurant: scrapList[index], index: index, scrapList: scrapList),
          childCount: scrapList.length,
        ),
      ),
    );
  }
}

class _ScrapGridItem extends StatelessWidget {
  final Restaurant restaurant;
  final int index;
  final List<Restaurant> scrapList;

  const _ScrapGridItem(
      {required this.restaurant, required this.index, required this.scrapList});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      // 화면 전환 애니메이션 추가 예시
      onTapDown: (details) {
        final tapPosition = details.globalPosition;
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => RestaurantReelsScreen(
              restaurants: scrapList,
              initialIndex: index,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // 화면 크기를 가져와서 tapPosition을 Alignment로 변환
              final size = MediaQuery.of(context).size;
              final alignment = Alignment(
                (tapPosition.dx / size.width) * 2 - 1,
                (tapPosition.dy / size.height) * 2 - 1,
              );

              return ScaleTransition(
                alignment: alignment,
                scale: animation.drive(
                  Tween<double>(begin: 0.0, end: 1.0).chain(
                    CurveTween(curve: Curves.fastOutSlowIn),
                  ),
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: restaurant.thumbnailUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[300]),
            errorWidget: (context, url, error) => const Icon(Icons.restaurant),
          ),
        ),
      ),
    );
  }
}
