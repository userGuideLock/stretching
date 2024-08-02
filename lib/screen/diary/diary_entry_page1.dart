import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/diary/diary_entry_page2.dart';

class DiaryEntryViewController1 extends GetxController {
  String selectedButton = ''; // 선택된 버튼

  // 버튼 선택
  void selectButton(String button) {
    if (selectedButton == button) {
      selectedButton = ''; // 이미 선택된 버튼 클릭 시 선택 해제
    } else {
      selectedButton = button; // 새로운 버튼 선택
    }
    update(); // 상태 업데이트
  }
}

class DiaryEntryPage1 extends StatelessWidget {
  const DiaryEntryPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiaryEntryViewController1>(
      init: DiaryEntryViewController1(), // 컨트롤러 초기화
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
                    Get.off(() => const BottomNavigation());
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
                      '1/3 스트레스 일기장',
                      style: TextStyle(
                        color: Color(0xff929292),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '당신의 오늘 기분은?',
                      style: TextStyle(
                        color: Color(0xfff0f0f0),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                        controller, '거의 스트레스를 받지 않았어요. \n오늘은 비교적 평온한 하루였어요'),
                    const SizedBox(height: 16),
                    _buildButton(controller,
                        '조금 스트레스를 받았어요. \n몇 가지 작은 문제가 있었지만 \n큰 문제는 아니었어요.'),
                    const SizedBox(height: 16),
                    _buildButton(
                        controller, '보통 정도로 스트레스를 받았어요. \n평소와 비슷한 수준이었어요'),
                    const SizedBox(height: 16),
                    _buildButton(
                        controller, '꽤 스트레스를 받았어요. \n여러 가지 일이 겹쳐서 힘든 하루였어요.'),
                    const SizedBox(height: 16),
                    _buildButton(
                        controller, '매우 많이 스트레스를 받았어요. \n정말 힘들고 지친 하루였어요.'),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.selectedButton.isNotEmpty
                            ? () {
                                // 완료 버튼 클릭 시 동작 및 다음 페이지로 이동
                                Get.to(() => const DiaryEntryPage2(),
                                    arguments: {
                                      'stepOne': controller.selectedButton
                                    });
                                print(controller.selectedButton);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.selectedButton.isNotEmpty
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

  Widget _buildButton(
      DiaryEntryViewController1 controller, String buttonLabel) {
    return GetBuilder<DiaryEntryViewController1>(
      builder: (_) {
        return SizedBox(
          width: double.infinity,
          height: 105,
          child: ElevatedButton(
            onPressed: () {
              controller.selectButton(buttonLabel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.selectedButton == buttonLabel
                  ? const Color(0xff5956ff)
                  : const Color(0xff4a4a4a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                color: Color(0xffd9d9d9),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
