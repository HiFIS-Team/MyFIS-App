import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/attendance_calendar.dart';
import 'widgets/home_events.dart';
import 'widgets/home_header.dart';
import 'widgets/home_week_summary.dart';

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
                onCheckInTap: () => context.push('/check-in'),
                onMembershipTap: () => context.push('/membership'),
              ),
            ),

            // 본문 (스크롤 영역) — 이벤트는 가장자리까지 흐르게(가로 스크롤),
            // 달력은 좌우 24 패딩.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 110),
                children: const [
                  // 토스식 이벤트 배너(자동 전환)
                  HomeEvents(),
                  SizedBox(height: 8),

                  // 이번 달 출석 달력 (더미 출석 데이터)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: AttendanceCalendar(
                      attendedDays: {
                        2, 5, 8, 12, 15, 18, 23, 25, 26, 27, 28, 29
                      },
                    ),
                  ),

                  SizedBox(height: 8),
                  // 운동 요약 (웨이트·유산소·칼로리)
                  HomeWeekSummary(),

                  // 이후: 마일리지·랭킹 요약 등
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
