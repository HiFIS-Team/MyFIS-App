import 'package:flutter/material.dart';

import 'widgets/home_header.dart';

/// 홈(메인) 대시보드 화면.
/// 데일리 루프(출석·루틴·멤버십·마일리지·랭킹)를 요약하는 페이지.
/// 현재는 헤더부터 구현 — 나머지 블록은 순차 추가 예정.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: const [
            // ① 헤더 (인사 + 알림)  ← 데이터 연동 전 더미 이름
            HomeHeader(userName: '은후', hasNotification: true),
            SizedBox(height: 24),

            // ② 멤버십 상태 카드 — 다음 단계
            // ③ 출석 도장 HERO — 다음 단계
            // ④ 오늘의 루틴 카드 — 다음 단계
            // ⑤ 마일리지 / 내 순위 요약 — 다음 단계
          ],
        ),
      ),
    );
  }
}
