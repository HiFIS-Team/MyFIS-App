import 'package:flutter/material.dart';

/// 웨이트 화면 (placeholder).
/// 추후 운동 가이드(자세/방법 영상 + WorkoutX) + 주간 루틴 추천으로 구성.
class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('웨이트')),
      body: const Center(child: Text('운동 가이드가 표시됩니다 🏋️')),
    );
  }
}
