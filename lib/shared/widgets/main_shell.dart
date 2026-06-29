import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// 메인 스캐폴드 — 토스식 변신 하단바.
/// 기본: 홈 · 음료 · 운동 · 마이
/// 운동 진입 시: ←나가기 · 웨이트 · 유산소 · 랭킹 으로 변신하며,
/// 덤벨(운동→웨이트)이 자리 이동하고 유산소·랭킹이 차례로 나타난다.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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
      bottomNavigationBar: _AnimatedNavBar(
        currentIndex: navigationShell.currentIndex,
        onGo: _go,
      ),
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
          // 각 탭을 repaint 경계로 격리 — 한 탭 변화가 다른 탭 repaint 유발 X
          child: RepaintBoundary(
            child: TickerMode(enabled: active, child: child),
          ),
        ),
      ),
    );
  }
}

// 브랜치 인덱스
const int _home = 0;
const int _store = 1;
const int _weight = 2;
const int _cardio = 3;
const int _ranking = 4;
const int _my = 5;

bool _isWorkout(int index) =>
    index == _weight || index == _cardio || index == _ranking;

/// 떠 있는 반투명 블러 캡슐 + 메인↔운동 변신 애니메이션 하단바.
class _AnimatedNavBar extends StatefulWidget {
  const _AnimatedNavBar({required this.currentIndex, required this.onGo});

  final int currentIndex;
  final void Function(int index) onGo;

  @override
  State<_AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<_AnimatedNavBar>
    with TickerProviderStateMixin {
  static const double _height = 62;
  static const double _pillW = 60;
  static const double _pillH = 44;

  // 메인(0) ↔ 운동(1) 변신
  // 진입(true: 덤벨→운동) / 나가기(false: ←복귀) 방향
  bool _entering = false;

  late final AnimationController _mode = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 580),
    value: _isWorkout(widget.currentIndex) ? 1 : 0,
  );

  // 선택 pill 팝(커졌다 복귀)
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _popScale = TweenSequence<double>([
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

  /// 현재 선택 슬롯(0~3). 모드에 따라 매핑.
  int _slotFor(int index) {
    switch (index) {
      case _home:
        return 0;
      case _store:
        return 1;
      case _my:
        return 3;
      case _weight:
        return 1;
      case _cardio:
        return 2;
      case _ranking:
        return 3;
    }
    return 0;
  }

  @override
  void didUpdateWidget(covariant _AnimatedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasWorkout = _isWorkout(oldWidget.currentIndex);
    final nowWorkout = _isWorkout(widget.currentIndex);
    if (nowWorkout != wasWorkout) {
      _entering = nowWorkout;
      nowWorkout ? _mode.forward() : _mode.reverse();
    }
    if (_slotFor(oldWidget.currentIndex) != _slotFor(widget.currentIndex)) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _mode.dispose();
    _pop.dispose();
    super.dispose();
  }

  /// 선형 구간 진행도 (0~1).
  double _lin(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }

  /// 등장 팝 스케일: 작게(0.5) → 크게(1.2, 확실히 보이게) → 원상태(1.0).
  double _appearScale(double a) {
    if (a <= 0) return 0.5;
    if (a >= 1) return 1.0;
    if (a < 0.6) {
      return lerpDouble(0.5, 1.2, Curves.easeOut.transform(a / 0.6))!;
    }
    return lerpDouble(1.2, 1.0, Curves.easeInOut.transform((a - 0.6) / 0.4))!;
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.currentIndex;
    final selectedSlot = _slotFor(idx);

    final radius = BorderRadius.circular(34);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        // 바 전체를 repaint 경계로 격리 (본문과 서로 영향 X)
        child: RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SizedBox(
              height: _height,
              child: Stack(
                children: [
                  // 1) 블러 배경 (정적) — 애니메이션 시 재계산 안 되게 분리
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: radius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt.withValues(alpha: 0.72),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            borderRadius: radius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 2) 콘텐츠(pill + 아이콘) — 블러 위, 애니메이션은 여기서만
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: radius,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final slot = constraints.maxWidth / 4;
                          return Stack(
                            children: [
                              // 슬라이드 + 팝 하는 선택 pill
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                top: (_height - _pillH) / 2,
                                left:
                                    selectedSlot * slot + (slot - _pillW) / 2,
                                width: _pillW,
                                height: _pillH,
                                child: ScaleTransition(
                                  scale: _popScale,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.lime
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                              ),
                              // 항목들 (모드 변신 애니메이션)
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _mode,
                                  builder: (context, _) =>
                                      _buildItems(idx, slot),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItems(int idx, double slot) {
    final raw = _mode.value;

    final double move; // 덤벨 이동 진행도(0=슬롯2, 1=슬롯1)
    final double mainAppear;
    final double exitAppear;
    final double cardioAppear;
    final double rankingAppear;

    if (_entering) {
      // 진입: 덤벨이 먼저 도착(0.2~0.55) → 유산소·랭킹 차례로 천천히 등장
      move = Curves.easeOutCubic.transform(_lin(raw, 0.2, 0.55));
      mainAppear = 1 - _lin(raw, 0.0, 0.28);
      exitAppear = _lin(raw, 0.5, 0.78);
      cardioAppear = _lin(raw, 0.62, 0.9);
      rankingAppear = _lin(raw, 0.72, 1.0);
    } else {
      // 나가기: 덤벨과 메인 아이콘이 함께(동시) 등장 — 전처럼(토스식)
      move = Curves.easeOutCubic.transform(raw);
      mainAppear = 1 - raw; // 메인 아이콘은 팝하며 함께 등장
      final fade = _lin(raw, 0.3, 1.0); // 운동 아이콘은 함께 빠르게 사라짐
      exitAppear = fade;
      cardioAppear = fade;
      rankingAppear = fade;
    }

    final dumbbellSlot = lerpDouble(2, 1, move)!;
    final mainIgnore = raw > 0.5;
    final workoutIgnore = raw < 0.5;

    return Stack(
      children: [
        // --- 메인 전용 (다 같이) ---
        _item(
          slot: slot,
          slotPos: 0,
          icon: idx == _home ? Icons.home : Icons.home_outlined,
          selected: idx == _home,
          appear: mainAppear,
          modeIgnore: mainIgnore,
          onTap: () => widget.onGo(_home),
        ),
        _item(
          slot: slot,
          slotPos: 1,
          icon: idx == _store ? Icons.local_drink : Icons.local_drink_outlined,
          selected: idx == _store,
          appear: mainAppear,
          modeIgnore: mainIgnore,
          onTap: () => widget.onGo(_store),
        ),
        _item(
          slot: slot,
          slotPos: 3,
          icon: idx == _my ? Icons.person : Icons.person_outline,
          selected: idx == _my,
          appear: mainAppear,
          modeIgnore: mainIgnore,
          onTap: () => widget.onGo(_my),
        ),

        // --- 운동 전용 (스태거 등장) ---
        _item(
          slot: slot,
          slotPos: 0,
          icon: Icons.arrow_back, // ← 나가기
          selected: false,
          appear: exitAppear,
          modeIgnore: workoutIgnore,
          onTap: () => widget.onGo(_home),
        ),
        _item(
          slot: slot,
          slotPos: 2,
          icon: idx == _cardio
              ? Icons.directions_run
              : Icons.directions_run_outlined,
          selected: idx == _cardio,
          appear: cardioAppear,
          modeIgnore: workoutIgnore,
          onTap: () => widget.onGo(_cardio),
        ),
        _item(
          slot: slot,
          slotPos: 3,
          icon: idx == _ranking
              ? Icons.leaderboard
              : Icons.leaderboard_outlined,
          selected: idx == _ranking,
          appear: rankingAppear,
          modeIgnore: workoutIgnore,
          onTap: () => widget.onGo(_ranking),
        ),

        // --- 공유 요소: 덤벨 (운동 ↔ 웨이트) ---
        _item(
          slot: slot,
          slotPos: dumbbellSlot,
          icon: idx == _weight
              ? Icons.fitness_center
              : Icons.fitness_center_outlined,
          selected: idx == _weight,
          appear: 1, // 슬라이드만, 팝 없음
          modeIgnore: false,
          onTap: () => widget.onGo(_weight),
        ),
      ],
    );
  }

  /// appear(0~1): 등장 진행도. 페이드 + 오버슛 팝(커졌다 복귀) 스케일.
  Widget _item({
    required double slot,
    required double slotPos,
    required IconData icon,
    required bool selected,
    required double appear,
    required bool modeIgnore,
    required VoidCallback onTap,
  }) {
    final a = appear.clamp(0.0, 1.0);
    final opacity = Curves.easeOut.transform(a);
    final scale = _appearScale(a);

    return Positioned(
      left: slotPos * slot,
      top: 0,
      width: slot,
      height: _height,
      child: Opacity(
        opacity: opacity,
        child: IgnorePointer(
          ignoring: modeIgnore || opacity < 0.05,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  icon,
                  color: selected ? AppColors.lime : AppColors.textSecondary,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
