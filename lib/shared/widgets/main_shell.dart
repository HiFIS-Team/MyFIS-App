import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// 메인 스캐폴드 — 토스식 변신 하단바.
/// 기본: 홈 · 스토어 · 운동 · 마이
/// 운동 진입 시: ✕나가기 · 웨이트 · 유산소 · 랭킹 으로 변신
/// 하단바는 떠 있는 둥근 캡슐 + 반투명 블러(인스타 스타일), 아이콘만 표시.
/// 선택 표시(라임 pill)는 바 안에서 슬라이드로 이동한다.
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
      specs: [
        _NavSpec(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          selected: idx == _home,
          onTap: () => _go(_home),
        ),
        _NavSpec(
          icon: Icons.local_drink_outlined,
          selectedIcon: Icons.local_drink,
          selected: idx == _store,
          onTap: () => _go(_store),
        ),
        _NavSpec(
          icon: Icons.fitness_center_outlined,
          selectedIcon: Icons.fitness_center,
          selected: false, // 운동 모드 진입 액션
          onTap: () => _go(_weight),
        ),
        _NavSpec(
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
      specs: [
        _NavSpec(
          icon: Icons.close,
          selected: false,
          onTap: () => _go(_home), // 메인으로 나가기
        ),
        _NavSpec(
          icon: Icons.fitness_center_outlined,
          selectedIcon: Icons.fitness_center,
          selected: idx == _weight,
          onTap: () => _go(_weight),
        ),
        _NavSpec(
          icon: Icons.directions_run_outlined,
          selectedIcon: Icons.directions_run,
          selected: idx == _cardio,
          onTap: () => _go(_cardio),
        ),
        _NavSpec(
          icon: Icons.leaderboard_outlined,
          selectedIcon: Icons.leaderboard,
          selected: idx == _ranking,
          onTap: () => _go(_ranking),
        ),
      ],
    );
  }
}

/// 탭 전환 시 부드러운 크로스페이드(+살짝 스케일) 컨테이너.
/// 모든 브랜치를 살려둬 상태를 보존하면서, 활성 브랜치만 페이드 인.
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var i = 0; i < children.length; i++)
          _branch(active: i == currentIndex, child: children[i]),
      ],
    );
  }

  Widget _branch({required bool active, required Widget child}) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: active ? 1 : 0.97,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        child: IgnorePointer(
          ignoring: !active,
          child: TickerMode(enabled: active, child: child),
        ),
      ),
    );
  }
}

/// 탭 항목 스펙.
class _NavSpec {
  const _NavSpec({
    required this.icon,
    this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final bool selected;
  final VoidCallback onTap;
}

/// 떠 있는 둥근 캡슐 + 반투명 블러 하단바.
/// 선택 pill이 슬라이드 이동하고, 탭하면 톡 커졌다 돌아오는 팝.
class _Bar extends StatefulWidget {
  const _Bar({super.key, required this.specs});
  final List<_NavSpec> specs;

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> with SingleTickerProviderStateMixin {
  static const double _height = 62;
  static const double _pillW = 60;
  static const double _pillH = 44;

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.16)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.16, end: 1.0)
          .chain(CurveTween(curve: Curves.easeIn)),
      weight: 55,
    ),
  ]).animate(_pop);

  int get _selectedIndex => widget.specs.indexWhere((s) => s.selected);

  @override
  void didUpdateWidget(covariant _Bar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIdx = oldWidget.specs.indexWhere((s) => s.selected);
    if (_selectedIndex >= 0 && _selectedIndex != oldIdx) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = widget.specs;
    final selectedIndex = _selectedIndex;

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
                height: _height,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final slot = constraints.maxWidth / specs.length;
                      return Stack(
                        children: [
                          // 슬라이드 이동 + 탭 시 팝(커졌다 복귀)하는 선택 pill
                          if (selectedIndex >= 0)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                              top: (_height - _pillH) / 2,
                              left: selectedIndex * slot + (slot - _pillW) / 2,
                              width: _pillW,
                              height: _pillH,
                              child: ScaleTransition(
                                scale: _scale,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.lime.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              for (final s in specs)
                                Expanded(child: _NavItem(spec: s)),
                            ],
                          ),
                        ],
                      );
                    },
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

/// 아이콘만 있는 탭 항목.
class _NavItem extends StatelessWidget {
  const _NavItem({required this.spec});
  final _NavSpec spec;

  @override
  Widget build(BuildContext context) {
    // 리플 없이 — 선택 pill만 보이게 GestureDetector 사용
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: spec.onTap,
      child: Center(
        child: Icon(
          spec.selected ? (spec.selectedIcon ?? spec.icon) : spec.icon,
          color: spec.selected ? AppColors.lime : AppColors.textSecondary,
          size: 28,
        ),
      ),
    );
  }
}
