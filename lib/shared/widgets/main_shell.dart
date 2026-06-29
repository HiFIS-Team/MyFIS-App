import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// 메인 스캐폴드 — 토스식 변신 하단바.
/// 기본: 홈 · 스토어 · 운동 · 마이
/// 운동 진입 시: ✕나가기 · 웨이트 · 유산소 · 랭킹 으로 변신
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
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedSwitcher(
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
          label: '홈',
          selected: idx == _home,
          onTap: () => _go(_home),
        ),
        _NavItem(
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
          label: '스토어',
          selected: idx == _store,
          onTap: () => _go(_store),
        ),
        _NavItem(
          icon: Icons.fitness_center_outlined,
          selectedIcon: Icons.fitness_center,
          label: '운동',
          selected: false, // 액션(운동 모드 진입)
          onTap: () => _go(_weight),
        ),
        _NavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: '마이',
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
          label: '나가기',
          selected: false,
          onTap: () => _go(_home), // 메인으로 나가기
        ),
        _NavItem(
          icon: Icons.fitness_center_outlined,
          selectedIcon: Icons.fitness_center,
          label: '웨이트',
          selected: idx == _weight,
          onTap: () => _go(_weight),
        ),
        _NavItem(
          icon: Icons.directions_run_outlined,
          selectedIcon: Icons.directions_run,
          label: '유산소',
          selected: idx == _cardio,
          onTap: () => _go(_cardio),
        ),
        _NavItem(
          icon: Icons.leaderboard_outlined,
          selectedIcon: Icons.leaderboard,
          label: '랭킹',
          selected: idx == _ranking,
          onTap: () => _go(_ranking),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({super.key, required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.surface,
      child: Row(
        children: [for (final item in items) Expanded(child: item)],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.lime : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            decoration: selected
                ? BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  )
                : null,
            child: Icon(
              selected ? (selectedIcon ?? icon) : icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
