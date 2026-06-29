import 'package:flutter/material.dart';

/// 마이 페이지 (placeholder).
/// 추후 멤버십·마일리지·프로필·카드 등록을 담는다.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이')),
      body: const Center(child: Text('내 정보가 표시됩니다 🙋')),
    );
  }
}
