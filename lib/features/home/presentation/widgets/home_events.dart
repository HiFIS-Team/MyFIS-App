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
      colors: [Color(0xFF2B3514), Color(0xFF3E4D1C)],
    ),
    _Event(
      emoji: '🎁',
      title: '친구 추천 이벤트',
      subtitle: '추천할 때마다 1,000P 받기',
      colors: [Color(0xFF33231E), Color(0xFF50362C)],
    ),
    _Event(
      emoji: '💪',
      title: 'PT 무료 체험',
      subtitle: '선착순 1회 무료 체험권 증정',
      colors: [Color(0xFF1E2A33), Color(0xFF2C4250)],
    ),
    _Event(
      emoji: '🥤',
      title: '신상품 입고',
      subtitle: '스토어에서 신규 보충제 교환',
      colors: [Color(0xFF2A2330), Color(0xFF3D3148)],
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
      child: Column(
        children: [
          SizedBox(
            height: 104,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 460),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                // 들어오는 카드는 커지며 페이드 인, 나가는 카드는 작아지며 페이드 아웃
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1.0)
                        .animate(animation),
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
          const SizedBox(height: 12),
          // 현재 위치 점 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _events.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppColors.textPrimary
                        : AppColors.outline,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Event {
  const _Event({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.colors,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> colors;
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
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: event.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
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
