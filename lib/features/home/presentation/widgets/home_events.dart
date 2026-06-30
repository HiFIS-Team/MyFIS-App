import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 상단 이벤트 배너 (토스 홈 느낌).
/// 가로로 긴 배너 한 장이 떠 있고, 몇 초마다 현재 배너가 작아지며
/// 다음 배너가 커지는 스케일 크로스페이드로 자동 전환된다. (이동 없음)
class HomeEvents extends StatefulWidget {
  const HomeEvents({super.key});

  @override
  State<HomeEvents> createState() => _HomeEventsState();
}

class _HomeEventsState extends State<HomeEvents> {
  static const List<_Event> _events = [
    _Event(
      emoji: '🔥',
      title: '출석 챌린지',
      subtitle: '이번 달 개근 시 3,000P 적립',
      accent: AppColors.lime,
    ),
    _Event(
      emoji: '🎁',
      title: '친구 추천 이벤트',
      subtitle: '추천할 때마다 1,000P 받기',
      accent: Color(0xFFFF9F6B),
    ),
    _Event(
      emoji: '💪',
      title: 'PT 무료 체험',
      subtitle: '선착순 1회 무료 체험권 증정',
      accent: Color(0xFF6FB7FF),
    ),
    _Event(
      emoji: '🥤',
      title: '신상품 입고',
      subtitle: '스토어에서 신규 보충제 교환',
      accent: Color(0xFFC09BFF),
    ),
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _events.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 104,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 520),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            // 들어오는 카드는 작게 나타나 커지며 페이드 인,
            // 나가는 카드는 많이 작아지며 페이드 아웃
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.55, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _EventBanner(
            key: ValueKey(_index),
            event: _events[_index],
          ),
        ),
      ),
    );
  }
}

class _Event {
  const _Event({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent; // 메인 글씨 색
}

class _EventBanner extends StatelessWidget {
  const _EventBanner({super.key, required this.event});
  final _Event event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: textTheme.titleMedium?.copyWith(
                      color: event.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(event.emoji, style: const TextStyle(fontSize: 38)),
          ],
        ),
      ),
    );
  }
}
