import 'dart:ui';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// 메인 스캐폴드 — 토스식 변신 하단바.
/// 기본: 홈 · 혜택 · 음료 · 운동 · 마이 (5슬롯)
/// 운동 진입 시: ←나가기 · 웨이트 · 유산소 · 랭킹 으로 변신하며(5슬롯 안 가운데 배치),
/// 덤벨(운동→웨이트)이 자리 이동하고 유산소·랭킹이 차례로 나타난다.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // 하단바 축소 상태(아래로 스크롤 시 true) — 바가 직접 구독해 애니메이션.
  final ValueNotifier<bool> _navCollapsed = ValueNotifier(false);

  @override
  void dispose() {
    _navCollapsed.dispose();
    super.dispose();
  }

  void _go(int index) {
    _navCollapsed.value = false; // 탭 눌러 이동하면 다시 펼침
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  // 탭 내부 어떤 스크롤이든 버블링되어 여기로 — 방향만 보고 축소/복원.
  bool _onUserScroll(UserScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false; // 가로 캐러셀 무시
    switch (n.direction) {
      case ScrollDirection.reverse: // 아래로 스크롤(콘텐츠 위로) → 축소
        _navCollapsed.value = true;
        break;
      case ScrollDirection.forward: // 위로 스크롤 → 복원
        _navCollapsed.value = false;
        break;
      case ScrollDirection.idle:
        break;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 본문이 반투명 바 뒤로 비치도록
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onUserScroll,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: _AnimatedNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onGo: _go,
        collapsed: _navCollapsed,
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

// 브랜치 인덱스 (라우터 브랜치 순서와 동일)
const int _home = 0;
const int _store = 1;
const int _weight = 2;
const int _cardio = 3;
const int _ranking = 4;
const int _my = 5;
const int _benefit = 6;

// 하단바 슬롯 수 (메인: 홈·혜택·스토어·운동·마이)
const int _slotCount = 5;

bool _isWorkout(int index) =>
    index == _weight || index == _cardio || index == _ranking;

/// 떠 있는 반투명 블러 캡슐 + 메인↔운동 변신 애니메이션 하단바.
class _AnimatedNavBar extends StatefulWidget {
  const _AnimatedNavBar({
    required this.currentIndex,
    required this.onGo,
    required this.collapsed,
  });

  final int currentIndex;
  final void Function(int index) onGo;

  /// 스크롤로 축소할지 여부 — 셸이 소유, 바가 구독해 애니메이션.
  final ValueListenable<bool> collapsed;

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

  // 운동 모드 진입 직전의 메인 탭 — 나가기 시 이 탭으로 복귀
  int _lastMainIndex = _home;

  @override
  void initState() {
    super.initState();
    if (!_isWorkout(widget.currentIndex)) _lastMainIndex = widget.currentIndex;
    widget.collapsed.addListener(_onCollapseChanged);
  }

  void _onCollapseChanged() {
    widget.collapsed.value ? _collapse.forward() : _collapse.reverse();
  }

  // 스크롤 축소(0=펼침, 1=축소)
  late final AnimationController _collapse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

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

  /// 현재 선택 슬롯. 모드에 따라 매핑.
  /// 메인: 홈0·혜택1·스토어2·운동3·마이4
  /// 운동: 나가기0.5·웨이트1.5·유산소2.5·랭킹3.5 (5슬롯 안 가운데)
  double _slotFor(int index) {
    switch (index) {
      case _home:
        return 0;
      case _benefit:
        return 1;
      case _store:
        return 2;
      case _my:
        return 4;
      case _weight:
        return 1.5;
      case _cardio:
        return 2.5;
      case _ranking:
        return 3.5;
    }
    return 0;
  }

  @override
  void didUpdateWidget(covariant _AnimatedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collapsed != widget.collapsed) {
      oldWidget.collapsed.removeListener(_onCollapseChanged);
      widget.collapsed.addListener(_onCollapseChanged);
    }
    final wasWorkout = _isWorkout(oldWidget.currentIndex);
    final nowWorkout = _isWorkout(widget.currentIndex);
    // 메인 탭에 있을 때마다 갱신 → 나가기 복귀 지점으로 사용
    if (!nowWorkout) _lastMainIndex = widget.currentIndex;
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
    widget.collapsed.removeListener(_onCollapseChanged);
    _collapse.dispose();
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
          child: AnimatedBuilder(
            animation: _collapse,
            builder: (context, child) {
              final c = Curves.easeOut.transform(_collapse.value);
              return Transform.scale(
                alignment: Alignment.bottomCenter,
                scale: lerpDouble(1.0, 0.82, c)!,
                child: Opacity(opacity: lerpDouble(1.0, 0.9, c)!, child: child),
              );
            },
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
                            color: AppColors.surfaceAlt.withValues(alpha: 0.45),
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
                          final slot = constraints.maxWidth / _slotCount;
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
      // 나가기: 덤벨을 진입과 같은 속도로 이동(구간 미러링: 0.2~0.55 → 0.45~0.8).
      // 나가기 직후 바로 같은 속도로 제자리 복귀, 메인 아이콘은 팝하며 함께 등장.
      move = Curves.easeOutCubic.transform(_lin(raw, 0.45, 0.8));
      mainAppear = 1 - raw;
      final fade = _lin(raw, 0.3, 1.0); // 운동 아이콘은 함께 빠르게 사라짐
      exitAppear = fade;
      cardioAppear = fade;
      rankingAppear = fade;
    }

    final dumbbellSlot = lerpDouble(3, 1.5, move)!;
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
          icon: idx == _benefit
              ? Icons.card_giftcard
              : Icons.card_giftcard_outlined,
          selected: idx == _benefit,
          appear: mainAppear,
          modeIgnore: mainIgnore,
          onTap: () => widget.onGo(_benefit),
        ),
        _item(
          slot: slot,
          slotPos: 2,
          icon: idx == _store ? Icons.local_drink : Icons.local_drink_outlined,
          selected: idx == _store,
          appear: mainAppear,
          modeIgnore: mainIgnore,
          onTap: () => widget.onGo(_store),
        ),
        _item(
          slot: slot,
          slotPos: 4,
          icon: idx == _my ? Icons.person : Icons.person_outline,
          selected: idx == _my,
          appear: mainAppear,
          modeIgnore: mainIgnore,
          onTap: () => widget.onGo(_my),
        ),

        // --- 운동 전용 (스태거 등장, 5슬롯 안 가운데) ---
        _item(
          slot: slot,
          slotPos: 0.5,
          icon: Icons.arrow_back, // ← 나가기 (직전 메인 탭으로 복귀)
          selected: false,
          appear: exitAppear,
          modeIgnore: workoutIgnore,
          onTap: () => widget.onGo(_lastMainIndex),
        ),
        _item(
          slot: slot,
          slotPos: 2.5,
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
          slotPos: 3.5,
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
