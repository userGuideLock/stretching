import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 플러그인 초기화

  // 필요한 locale을 async로 초기화

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Strectching',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
