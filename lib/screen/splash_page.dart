import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/login_page.dart';
import 'package:stretching/screen/register_page.dart';

class SplashPageViewController extends GetxController {}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '숨은 스트레스,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '스트레칭',
                          style: TextStyle(
                            color: Color(0xffacdcb4),
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '이 찾아요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      '스트레칭은 숨은 스트레스를 자동 감지하고 해소를 도와줍니다. \n간단하게 사용하여 건강한 일상을 유지하세요.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Image.asset(
                  "images/splash_page_star.png",
                  width: double.infinity,
                ),
                const SizedBox(height: 40),
                LoginButton(),
                const SizedBox(height: 10),
                SignupButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget LoginButton() {
  return SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xffacdcb4), // 텍스트 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onPressed: () {
        // 로그인 버튼 클릭 시 처리할 로직
        Get.to(const LoginPage());
      },
      child: const Text(
        '로그인',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget SignupButton() {
  return SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.yellow[300], // 텍스트 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onPressed: () {
        // 회원가입 버튼 클릭 시 처리할 로직
        Get.to(const RegisterPage());
      },
      child: const Text(
        '회원가입',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
