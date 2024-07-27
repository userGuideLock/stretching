import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterViewController extends GetxController {
  String name = '';
  String email = '';
  String password = '';

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

  void register() {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        duration: const Duration(milliseconds: 1000),
        'Error',
        '모든 필드를 채워주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        colorText: Colors.white,
      );
      return;
    }
    // 회원가입 로직을 여기에 추가하세요
    print('Name: $name, Email: $email, Password: $password');
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 페이지에서 전달된 데이터 가져오기
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;

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
                  Navigator.of(context).pop();
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 60,
                  ),
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
                        color: Color(
                          0xffd9d9d9,
                        )),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
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
                        color: Color(
                          0xffd9d9d9,
                        )),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
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
                        color: Color(
                          0xffd9d9d9,
                        )),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
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
                        // 완료 버튼 클릭 시 동작 및 다음 페이지로 이동
                        final combinedData = {
                          ...previousData,
                          'name': controller.name,
                          'email': controller.email,
                          'password': controller.password,
                        };

                        print(combinedData);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(const Color(0xFFF2FE8D)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
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
