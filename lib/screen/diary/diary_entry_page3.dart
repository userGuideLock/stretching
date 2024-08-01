import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:stretching/screen/bottom_navigation.dart';

class DiaryEntryViewController3 extends GetxController {
  String note = ''; // 사용자가 입력한 메모
  var isLoading = false;

  // 메모 입력
  void updateNote(String newNote) {
    note = newNote;
    update(); // 상태 업데이트
  }

  Future<void> submitDiaryEntry(
      String date, String mood, String effort, String note) async {
    isLoading = true;
    update();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      Get.snackbar(
        'Error',
        '사용자 ID를 찾을 수 없습니다. 다시 로그인해 주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading = false;
      update();
      return;
    }

    final diaryData = {
      "userId": userId,
      "date": date,
      "mood": mood,
      "effort": effort,
      "content": note,
    };

    print(diaryData);

    final url = Uri.parse('https://hermi.danjam.site/api/v1/diary');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(diaryData);

    try {
      final response = await http.post(url, headers: headers, body: body);
      isLoading = false;
      update();

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          '일기가 성공적으로 저장되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => const BottomNavigation());
      } else if (response.statusCode == 400) {
        final responseBody = json.decode(response.body);
        if (responseBody['code'] == 1) {
          Get.snackbar(
            'Error',
            '필수 항목 중에 누락된 데이터가 있습니다: ${responseBody['message']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else if (responseBody['code'] == 2) {
          Get.snackbar(
            'Error',
            '해당 사용자 ID를 가진 유저가 없습니다: ${responseBody['message']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            '일기 저장에 실패했습니다: ${response.reasonPhrase}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print("Exception: $response");
        Get.snackbar(
          'Error',
          '일기 저장에 실패했습니다: ${response.reasonPhrase}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading = false;
      update();
      print("Exception: $e");
      Get.snackbar(
        'Error',
        '일기 저장 중 에러가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class DiaryEntryPage3 extends StatelessWidget {
  const DiaryEntryPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavigationController navController = Get.find();
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;

    return GetBuilder<DiaryEntryViewController3>(
      init: DiaryEntryViewController3(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
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
          body: Stack(
            children: [
              SingleChildScrollView(
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
                        const SizedBox(height: 50),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.note.isNotEmpty
                                ? () {
                                    final combinedData = {
                                      ...previousData,
                                      'note': controller.note
                                    };
                                    print(combinedData);

                                    final now = DateTime.now();
                                    final formattedDate =
                                        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                                    controller.submitDiaryEntry(
                                      formattedDate,
                                      combinedData['stepOne'],
                                      combinedData['stepTwo'],
                                      controller.note,
                                    );
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
              if (controller.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
