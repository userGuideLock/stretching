import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stretching/screen/diary/diary_entry_page1.dart';

class DiaryViewController extends GetxController {
  var diaryEntries = <Map<String, dynamic>>[];
  var currentPage = 1;
  var totalPages = 1;
  late String currentMonth;
  late String currentYear;

  @override
  void onInit() {
    super.onInit();
    _generateDiaryEntries();
  }

  void _generateDiaryEntries() {
    DateTime now = DateTime.now();
    DateFormat dayFormat = DateFormat('EEE', 'en_US');
    DateTime entryDate = now;
    String day = dayFormat.format(entryDate).toUpperCase();
    int date = entryDate.day;
    String entry = "오늘의 스트레스 기록하기";
    diaryEntries.add({
      "day": day,
      "date": date,
      "entry": entry,
      "stepOne": null,
      "stepTwo": null,
      "note": null,
      "createdAt": now, // Store the creation date and time
    });

    currentMonth = DateFormat.MMMM('en_US').format(now);
    currentYear = now.year.toString();
    update();
  }

  void updateDiaryEntry(String day, int date, Map<String, dynamic> updates) {
    for (var entry in diaryEntries) {
      if (entry['day'] == day && entry['date'] == date) {
        entry.addAll(updates);
        break;
      }
    }
    update();
  }

  void goToNextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      update();
    }
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      currentPage--;
      update();
    }
  }
}

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiaryViewController>(
      init: DiaryViewController(),
      builder: (controller) {
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
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // 일기 작성 페이지로 이동하는 로직 추가
                      Get.to(() => const DiaryEntryPage1(entry: {}));
                    },
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.diaryEntries.length,
                  itemBuilder: (context, index) {
                    var entry = controller.diaryEntries[index];
                    DateTime createdAt = entry["createdAt"];
                    String formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

                    return GestureDetector(
                      onTap: () {
                        // 다이어리 항목을 눌렀을 때 다른 페이지로 이동
                        Get.to(() => DiaryEntryPage1(entry: entry));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        color: Colors.white24,
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    entry["day"].toString(),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.white,
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  Text(
                                    entry["date"].toString(),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              const VerticalDivider(
                                color: Colors.white,
                                width: 1,
                                thickness: 1,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry["entry"].toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: controller.goToPreviousPage,
                    ),
                    Text(
                      "${controller.currentMonth} ${controller.currentYear}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: controller.goToNextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
