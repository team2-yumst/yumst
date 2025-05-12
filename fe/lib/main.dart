import 'package:fe/provider/managers_provider.dart';
import 'package:fe/view/screen/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // ProviderScope 내부에서 초기화 작업을 수행하기 위한 ProviderContainer 생성
  final container = ProviderContainer();
  
  // 앱 실행
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
  
  // 앱이 시작된 후 백그라운드에서 매니저 초기화 실행
  container.read(managerInitializerProvider.future).then((_) {
    print('매니저 초기화 완료');
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 매니저 초기화 상태 관찰
    final initStatus = ref.watch(managerInitializerProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const SplashScreen()
    );
  }
}

