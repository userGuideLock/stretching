import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/diary_page.dart';

class DiaryEntryViewController3 extends GetxController {
  String note = ''; // 사용자가 입력한 메모

  // 메모 입력
  void updateNote(String newNote) {
    note = newNote;
    update(); // 상태 업데이트
  }
}

class DiaryEntryPage3 extends StatelessWidget {
  const DiaryEntryPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavigationController navController = Get.find();
    // 이전 페이지에서 전달된 데이터 가져오기
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;

    return GetBuilder<DiaryEntryViewController3>(
      init: DiaryEntryViewController3(), // 컨트롤러 초기화
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
                    navController.changeTabIndex(1); // MainMatePage로 이동하도록 설정
                    Get.to(() => const BottomNavigation());
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
                      '3/3 스트레스 일기장',
                      style: TextStyle(
                        color: Color(0xff929292),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '오늘을 기록해보세요.',
                      style: TextStyle(
                        color: Color(0xfff0f0f0),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xff4a4a4a),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        maxLength: 100,
                        maxLines: 5,
                        onChanged: (text) {
                          controller.updateNote(text);
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '오늘 하루를 간략하게 작성해주세요.',
                          hintStyle: TextStyle(color: Color(0xff929292)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${controller.note.length} / 100자 이내',
                        style: const TextStyle(
                          color: Color(0xff929292),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.note.isNotEmpty
                            ? () {
                                // 완료 버튼 클릭 시 동작 및 데이터 업데이트
                                final combinedData = {
                                  ...previousData,
                                  'note': controller.note
                                };

                                // 다이어리 항목 업데이트
                                var diaryController =
                                    Get.find<DiaryViewController>();
                                diaryController.updateDiaryEntry(
                                  combinedData['entry']['day'],
                                  combinedData['entry']['date'],
                                  {
                                    'note': combinedData['note'],
                                    'entry': combinedData['note'].length > 20
                                        ? '${combinedData['note'].substring(0, 20)}...'
                                        : combinedData['note']
                                  },
                                );

                                // 업데이트 후 다른 페이지로 이동하는 로직 추가 가능
                                navController.changeTabIndex(
                                    1); // MainMatePage로 이동하도록 설정
                                Get.offAll(() => const BottomNavigation());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.note.isNotEmpty
                              ? const Color(0xffbbffba)
                              : const Color(0xff4a4a4a),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text(
                          '완료',
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
