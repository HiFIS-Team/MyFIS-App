import 'package:flutter/material.dart';

/// 랭킹 화면 (placeholder).
/// 추후 4종 랭킹(출석왕·유산소·소개왕·루틴) 세그먼트로 구성.
class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('랭킹')),
      body: const Center(child: Text('랭킹이 표시됩니다 🏆')),
    );
  }
}
