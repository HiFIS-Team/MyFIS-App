import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// 혜택 탭 — 토스식 마이크로 리워드(출석·걸음·퀴즈·룰렛) + 미션.
/// 소액 마일리지를 매일 모으는 재미. (현재 더미)
class BenefitScreen extends StatelessWidget {
  const BenefitScreen({super.key});

  static const int _mileage = 2400;

  void _visit(BuildContext context, String title) {
    context.push('/benefit-mission', extra: title);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          children: [
            // 내 마일리지
            _MileageBar(mileage: _mileage),
            const SizedBox(height: 8),

            // 오늘의 루틴 히어로 카드 (토스식)
            _RoutineHeroCard(
              points: 30,
              onGo: () => context.go('/weight'),
            ),
            const SizedBox(height: 8),

            // 매일 미션 (헤더를 카드 안으로)
            _MissionCard(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                  child: Text.rich(
                    TextSpan(
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                      children: const [
                        TextSpan(text: '매일 미션을 하고 '),
                        TextSpan(
                          text: '마일리지',
                          style: TextStyle(color: AppColors.lime),
                        ),
                        TextSpan(text: ' 받아요'),
                      ],
                    ),
                  ),
                ),
                _RewardRow(
                  icon: Symbols.water_drop,
                  color: Color(0xFF4DA3FF), // 물 - 블루
                  title: '물 마시기',
                  cta: '방문하기',
                  onTap: () => context.push('/water-mission'),
                ),
                _RewardRow(
                  icon: Symbols.monitor_weight,
                  color: Color(0xFFB69CFF), // 체중 - 퍼플
                  title: '체중 기록',
                  cta: '방문하기',
                  onTap: () => _visit(context, '체중 기록'),
                ),
                _RewardRow(
                  icon: Symbols.self_improvement,
                  color: Color(0xFF4FD1C5), // 스트레칭 - 민트
                  title: '스트레칭',
                  cta: '방문하기',
                  onTap: () => _visit(context, '스트레칭'),
                ),
                _RewardRow(
                  icon: Symbols.photo_camera,
                  color: Color(0xFFFF6BAE), // 인스타 - 핑크
                  title: '인스타 스토리 공유',
                  cta: '방문하기',
                  onTap: () => _visit(context, '인스타 스토리 공유'),
                ),
                _RewardRow(
                  icon: Symbols.style,
                  color: Color(0xFFFFC24B), // 카드 긁기 - 앰버
                  title: '카드 긁기',
                  cta: '방문하기',
                  onTap: () => context.push('/scratch-card'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 내 마일리지 — 가로 구분선 가운데에 금액 (토스식).
class _MileageBar extends StatelessWidget {
  const _MileageBar({required this.mileage});
  final int mileage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.outline, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Symbols.paid, color: AppColors.lime, size: 20),
                const SizedBox(width: 6),
                Text(
                  '${_comma(mileage)}P',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: Divider(color: AppColors.outline, height: 1)),
        ],
      ),
    );
  }
}

/// 오늘의 루틴 히어로 카드 — 어두운 카드에 라임 아우라가 우→좌로 2초마다 스윕. (토스식)
class _RoutineHeroCard extends StatefulWidget {
  const _RoutineHeroCard({required this.points, required this.onGo});
  final int points;
  final VoidCallback onGo;

  @override
  State<_RoutineHeroCard> createState() => _RoutineHeroCardState();
}

class _RoutineHeroCardState extends State<_RoutineHeroCard>
    with SingleTickerProviderStateMixin {
  // 라임 글로우가 한 지점에서 점점 퍼졌다 사라지는 리플 (느리게 반복).
  static const Alignment _origin = Alignment(-0.5, 0.15);

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 라임 글로우 리플 — 한 지점에서 점점 퍼지며 사라짐 (콘텐츠 뒤)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final t = _c.value; // 0..1
                  // 작게 시작 → 크게 퍼짐, 밝기는 떠올랐다 사라짐(sin)
                  final scale = lerpDouble(0.25, 2.0, Curves.easeOut.transform(t))!;
                  final opacity = math.sin(math.pi * t) * 0.9;
                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      alignment: _origin,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: _origin,
                            radius: 0.55,
                            colors: [Color(0x40D7FC51), Color(0x00D7FC51)],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.local_fire_department,
                        color: AppColors.lime, size: 20, fill: 1),
                    const SizedBox(width: 6),
                    Text(
                      '오늘의 루틴',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.lime,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // 큰 문구
                Text.rich(
                  TextSpan(
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.35,
                    ),
                    children: [
                      const TextSpan(text: '오늘 루틴을 끝내면\n'),
                      TextSpan(
                        text: '${widget.points}P',
                        style: const TextStyle(color: AppColors.lime),
                      ),
                      const TextSpan(text: ' 바로 받아요'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 큰 CTA
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: widget.onGo,
                    child: const Text('마일리지 받으러 가기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 매일 받기 한 줄 (마이페이지식 가로 행) — 아이콘 · 제목 · CTA 버튼.
class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.cta,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // 행 전체가 아니라 우측 버튼으로만 접근(프레스 효과도 버튼에만).
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.16),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          // 앱 공통 버튼(FilledButton)과 동일한 프레스 효과, 크기만 컴팩트하게
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(cta),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// 천 단위 콤마.
String _comma(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
