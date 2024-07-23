import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

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
