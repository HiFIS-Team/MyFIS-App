import 'package:flutter/material.dart';

/// 운동 루틴 화면 (placeholder).
class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 루틴')),
      body: const Center(
        child: Text('여기에 운동 루틴이 표시됩니다 💪'),
      ),
    );
  }
}
