import 'package:flutter/material.dart';

class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설문 페이지'),
      ),
      body: const Center(
        child: Text('설문 페이지 내용'),
      ),
    );
  }
}
