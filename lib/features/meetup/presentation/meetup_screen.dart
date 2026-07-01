import 'package:flutter/material.dart';

/// 운동 모임 화면 (placeholder).
/// 추후 모임 생성·참여(같이 운동), 모집 글, 참여자 목록 등으로 구성.
class MeetupScreen extends StatelessWidget {
  const MeetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 모임')),
      body: const Center(child: Text('함께할 운동 모임이 표시됩니다 👥')),
    );
  }
}
