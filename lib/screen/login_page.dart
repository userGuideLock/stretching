import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'dart:convert';

import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/splash_page.dart';

class LoginViewController extends GetxController {
  String email = '';
  String password = '';
  String uuid = '';
  var isLoading = false;

  @override
  void onInit() {
    super.onInit();
    _initUUID();
  }

  Future<void> _initUUID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (GetPlatform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      uuid =
          "${androidInfo.board}-${androidInfo.bootloader}-${androidInfo.brand}-${androidInfo.device}";
    }
    update();
  }

  void updateEmail(String value) {
    email = value;
    update();
  }

  void updatePassword(String value) {
    password = value;
    update();
  }

  Future<void> login() async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        '모든 필드를 채워주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        colorText: Colors.white,
      );
      return;
    }

    isLoading = true;
    update(); // 로딩 시작

    final loginData = {
      "id": email,
      "password": password,
      "deviceId": uuid,
    };

    final url = Uri.parse(
        'https://hermi.danjam.site/api/v1/users/login'); // 실제 URL을 확인하세요
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(loginData);

    try {
      final response = await http.post(url, headers: headers, body: body);
      isLoading = false;
      update(); // 로딩 종료

      if (response.statusCode == 200) {
        // 성공적으로 로그인이 완료되었을 때의 처리
        Get.snackbar(
          'Success',
          '로그인에 성공했습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        final userId = loginData['id'].toString();

        // SharedPreferences에 userId 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);

        Get.offAll(() => const BottomNavigation()); // BottomNavigation으로 이동
        print("Response Body: ${response.body}");
      } else {
        // 서버로부터 에러 응답을 받았을 때의 처리
        Get.snackbar(
          'Error',
          '로그인에 실패했습니다: ${response.reasonPhrase}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("Error Response: ${response.body}");
      }
    } catch (e) {
      // 네트워크 에러 등 예외 발생 시의 처리
      isLoading = false;
      update(); // 로딩 종료
      Get.snackbar(
        'Error',
        '로그인 중 에러가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Exception: $e");
    }
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // 기본 뒤로 가기 버튼 제거
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '스트레칭',
                style: TextStyle(
                  color: Color(0xffacdcb4),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Get.offAll(const SplashPage());
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GetBuilder<LoginViewController>(
            init: LoginViewController(),
            builder: (controller) {
              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      const Text(
                        '로그인 👋',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        '이름을 입력하세요!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xffd9d9d9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: controller.updateEmail,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ex) honggildong',
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintText: 'john@gmail.com',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1F1F1F),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '비밀번호를 입력하세요!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xffd9d9d9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: controller.updatePassword,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '디바이스 당 하나의 아이디만 접속됩니다.',
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintText: 'Enter password',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1F1F1F),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              controller.login, // Login button click event
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              const Color(0xFF98FB98),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (controller.isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
