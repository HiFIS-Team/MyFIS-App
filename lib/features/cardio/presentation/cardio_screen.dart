import 'package:flutter/material.dart';

/// 유산소 화면 (placeholder).
/// 추후 거리(km) 기록 + 유산소 랭킹 연동으로 구성.
class CardioScreen extends StatelessWidget {
  const CardioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('유산소')),
      body: const Center(child: Text('유산소 기록이 표시됩니다 🏃')),
    );
  }
}
