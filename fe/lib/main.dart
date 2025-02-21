import 'package:fe/view/screen/main_page.dart';
import 'package:fe/view/screen/recommendation_page.dart';
import 'package:fe/view/screen/register_first_selection_page.dart';
import 'package:fe/view/screen/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   home: FirstRegisterSelection(),
    // );

    // return MaterialApp(
    //   home: SplashScreen(),
    //   // debugShowCheckedModeBanner: false,
    //   theme: ThemeData(
    //     useMaterial3: true,
    //     // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    //   ),
    // );


    return MaterialApp(
      home: const MainScreen(),
      // debugShowCheckedModeBanner: false,
    );
  }
}
