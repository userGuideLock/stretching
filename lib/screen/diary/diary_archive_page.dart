import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';

class DiaryArchivePage extends StatelessWidget {
  const DiaryArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final diaries = Get.arguments as List;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Expanded(
              // ListView.builder가 확장되도록 설정
              child: ListView.builder(
                itemCount: diaries.length,
                itemBuilder: (context, index) {
                  final diary = diaries[index];
                  return Card(
                    color: const Color(0xFF424242),
                    child: ListTile(
                      title: Text(
                        diary['date'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '기분: ${diary['mood']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '노력: ${diary['effort']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '내용: ${diary['content']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
