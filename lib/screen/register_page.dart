import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stretching/screen/login_page.dart';
import 'package:stretching/screen/splash_page.dart';

class RegisterViewController extends GetxController {
  String name = '';
  String email = '';
  String password = '';
  String uuid = '';
  var isLoading = false.obs;

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
      print("Generated UUID: $uuid");
    }
    update();
  }

  void updateName(String value) {
    name = value;
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

  Future<void> register(Map<String, dynamic> previousData) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        '모든 필드를 채워주세요.',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    update();

    final combinedData = {
      "id": name,
      "email": email,
      "password": password,
      "gender": previousData['stepOne'],
      "job": previousData['stepTwo'],
      "age": previousData['stepThree'],
      "hobby": previousData['stepFour'],
      "deviceId": uuid,
    };

    final url = Uri.parse('https://hermi.danjam.site/api/v1/users/join');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(combinedData);

    try {
      final response = await http.post(url, headers: headers, body: body);
      isLoading.value = false;
      update();

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          '회원가입이 완료되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(const LoginPage());
      } else {
        Get.snackbar(
          'Error',
          '회원가입에 실패했습니다: ${response.reasonPhrase}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      update();
      Get.snackbar(
        'Error',
        '회원가입 중 에러가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          child: GetBuilder<RegisterViewController>(
            init: RegisterViewController(),
            builder: (controller) {
              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      const Text(
                        '회원가입 👋',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Your fullname*',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xffd9d9d9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: controller.updateName,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Enter Fullname',
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintText: 'nkm',
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
                        'Email address*',
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
                          labelText: 'Enter Email address*',
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
                        'Password*',
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
                          labelText: 'Enter Password*',
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
                          onPressed: () {
                            controller.register(previousData);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2FE8D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: const Text(
                            '회원가입',
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
                  if (controller.isLoading.value)
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
