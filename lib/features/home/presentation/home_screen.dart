import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/home_header.dart';
import 'widgets/membership_card.dart';

/// 홈(메인) 대시보드 화면.
/// 데일리 루프(출석·루틴·멤버십·마일리지·랭킹)를 요약하는 페이지.
/// 헤더는 상단 고정, 본문만 스크롤. 본문 블록은 순차 추가 예정.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ① 고정 헤더 (브랜드 로고 + 알림)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
              child: HomeHeader(
                hasNotification: true,
                onNotificationTap: () => context.push('/notifications'),
              ),
            ),

            // 본문 (스크롤 영역)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: const [
                  // ② 멤버십 상태 카드
                  MembershipCard(),

                  // ③ 출석 도장 HERO — 다음 단계
                  // ④ 오늘의 루틴 카드 — 다음 단계
                  // ⑤ 마일리지 / 내 순위 요약 — 다음 단계
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
