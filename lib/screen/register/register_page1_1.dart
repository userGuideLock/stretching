import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/diary/diary_entry_page2.dart';
import 'package:stretching/screen/register/register_page1.dart';
import 'package:stretching/screen/register/register_page2.dart';
import 'package:stretching/screen/splash_page.dart';
import 'package:stretching/screen/survey/survey_page2.dart';

class RegisterViewController1_1 extends GetxController {
  bool isAgreed = false; // 약관 동의 여부

  // 약관 동의 상태 변경
  void toggleAgreement() {
    isAgreed = !isAgreed;
    update(); // 상태 업데이트
  }
}

class RegisterPage1_1 extends StatelessWidget {
  const RegisterPage1_1({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterViewController1_1>(
      init: RegisterViewController1_1(), // 컨트롤러 초기화
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false, // 기본 뒤로 가기 버튼 제거
            title: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '스트레칭',
                    style: TextStyle(
                      color: Color(0xffacdcb4),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.close),
                  color: const Color.fromARGB(255, 255, 255, 255),
                  onPressed: () {
                    Get.to(() => const SplashPage());
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      '스트레칭 서비스 이용을 위하여,\n다음의 항목에 동의해주세요',
                      style: TextStyle(
                        color: Color(0xfff0f0f0),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text(
                        '서비스이용약관 동의(필수)',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: controller.isAgreed,
                      onChanged: (bool? value) {
                        controller.toggleAgreement();
                      },
                      checkColor: Colors.black,
                      activeColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: const Color(0xFF303030),
                      child: const SingleChildScrollView(
                        child: Text(
                          '''개인정보 처리방침
<스트레칭> (이하 ‘스트레칭’이라 함)은 [개인정보 보호법] 제30조에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.

○ 이 개인정보처리방침은 2023년 8월 11일부터 적용됩니다.

제1조(개인정보의 처리 목적)

<스트레칭>은 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 개인정보 보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.

1. **회원가입 및 관리**: 회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지 목적으로 개인정보를 처리합니다.
2. **서비스 제공**: 서비스 제공, 콘텐츠 제공을 목적으로 개인정보를 처리합니다.
                    ''',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isAgreed
                            ? () {
                                // 다음 버튼 클릭 시 동작 및 다음 페이지로 이동
                                Get.to(() => const RegisterPage1());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isAgreed
                              ? const Color(0xffbbffba)
                              : const Color(0xff4a4a4a),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            color: Color(0xff282828),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
