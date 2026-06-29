import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// 메인 스캐폴드 — 토스식 변신 하단바.
/// 기본: 홈 · 스토어 · 운동 · 마이
/// 운동 진입 시: ✕나가기 · 웨이트 · 유산소 · 랭킹 으로 변신
/// 하단바는 떠 있는 둥근 캡슐 + 반투명 블러(인스타 스타일), 아이콘만 표시.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // 브랜치 인덱스
  static const int _home = 0;
  static const int _store = 1;
  static const int _weight = 2;
  static const int _cardio = 3;
  static const int _ranking = 4;
  static const int _my = 5;

  bool get _inWorkout => const [_weight, _cardio, _ranking]
      .contains(navigationShell.currentIndex);

  void _go(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 본문이 반투명 바 뒤로 비치도록
      body: navigationShell,
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _inWorkout ? _workoutBar() : _mainBar(),
      ),
    );
  }

  Widget _mainBar() {
    final idx = navigationShell.currentIndex;
    return _Bar(
      key: const ValueKey('main'),
      items: [
        _NavItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          selected: idx == _home,
          onTap: () => _go(_home),
        ),
        _NavItem(
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
          selected: idx == _store,
          onTap: () => _go(_store),
        ),
        _NavItem(
          icon: Icons.fitness_center_outlined,
          selectedIcon: Icons.fitness_center,
          selected: false, // 운동 모드 진입 액션
          onTap: () => _go(_weight),
        ),
        _NavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          selected: idx == _my,
          onTap: () => _go(_my),
        ),
      ],
    );
  }

  Widget _workoutBar() {
    final idx = navigationShell.currentIndex;
    return _Bar(
      key: const ValueKey('workout'),
      items: [
        _NavItem(
          icon: Icons.close,
          selected: false,
          onTap: () => _go(_home), // 메인으로 나가기
        ),
        _NavItem(
          icon: Icons.fitness_center_outlined,
          selectedIcon: Icons.fitness_center,
          selected: idx == _weight,
          onTap: () => _go(_weight),
        ),
        _NavItem(
          icon: Icons.directions_run_outlined,
          selectedIcon: Icons.directions_run,
          selected: idx == _cardio,
          onTap: () => _go(_cardio),
        ),
        _NavItem(
          icon: Icons.leaderboard_outlined,
          selectedIcon: Icons.leaderboard,
          selected: idx == _ranking,
          onTap: () => _go(_ranking),
        ),
      ],
    );
  }
}

/// 떠 있는 둥근 캡슐 + 반투명 블러 하단바.
class _Bar extends StatelessWidget {
  const _Bar({super.key, required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      for (final item in items) Expanded(child: item),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 아이콘만 있는 탭 항목 (선택 시 라임 pill).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: selected
              ? BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                )
              : null,
          child: Icon(
            selected ? (selectedIcon ?? icon) : icon,
            color: selected ? AppColors.lime : AppColors.textSecondary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
