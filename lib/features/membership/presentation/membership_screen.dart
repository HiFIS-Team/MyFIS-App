import 'package:flutter/material.dart';

/// 헬스장 멤버십 화면 (placeholder).
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('멤버십')),
      body: const Center(
        child: Text('여기에 멤버십 정보가 표시됩니다 🎫'),
      ),
    );
  }
}
