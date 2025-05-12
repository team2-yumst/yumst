import 'package:fe/managers/scrap_manager.dart';
import 'package:fe/managers/vote_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'managers_provider.g.dart';

// VoteManager 프로바이더
@Riverpod(keepAlive: true)
VoteManager voteManager(VoteManagerRef ref) {
  final manager = VoteManager();
  // 초기화는 메인에서 별도로 처리
  return manager;
}

// ScrapManager 프로바이더
@Riverpod(keepAlive: true)
ScrapManager scrapManager(ScrapManagerRef ref) {
  final manager = ScrapManager();
  // 초기화는 메인에서 별도로 처리
  return manager;
}

// 어플리케이션 초기화 관련 프로바이더 - 매니저 초기화 상태 관리
@Riverpod(keepAlive: true)
class ManagerInitializer extends _$ManagerInitializer {
  @override
  Future<bool> build() async {
    return _initializeManagers();
  }

  Future<bool> _initializeManagers() async {
    try {
      // 모든 매니저 초기화
      final voteManager = ref.read(voteManagerProvider);
      final scrapManager = ref.read(scrapManagerProvider);
      
      await Future.wait([
        voteManager.init(),
        scrapManager.init(),
      ]);
      
      print('모든 매니저 초기화 완료');
      return true;
    } catch (e) {
      print('매니저 초기화 중 오류: $e');
      return false;
    }
  }
  
  Future<void> reinitialize() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _initializeManagers());
  }
} 