import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('다이어리 페이지'),
      ),
      body: const Center(
        child: Text('다이어리 페이지 내용'),
      ),
    );
  }
}
