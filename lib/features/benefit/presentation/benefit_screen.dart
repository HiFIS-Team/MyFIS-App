import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pressable.dart';

/// 혜택 탭 — 토스식 마이크로 리워드(출석·걸음·퀴즈·룰렛) + 미션.
/// 소액 마일리지를 매일 모으는 재미. (현재 더미)
class BenefitScreen extends StatelessWidget {
  const BenefitScreen({super.key});

  static const int _mileage = 2400;

  void _reward(BuildContext context, String label, int points) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$label · +${points}P 받았어요 (준비 중)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: [
            // 내 마일리지
            _MileageBar(mileage: _mileage),
            const SizedBox(height: 16),

            // 오늘의 루틴 히어로 카드 (토스식)
            _RoutineHeroCard(
              points: 30,
              onGo: () => context.go('/weight'),
            ),
            const SizedBox(height: 28),

            // 매일 받기
            Text(
              '매일 받기',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _MissionCard(
              children: [
                _RewardRow(
                  icon: Symbols.event_available,
                  title: '출석 체크',
                  cta: '방문하기',
                  onTap: () => _reward(context, '출석 체크', 10),
                ),
                _RewardRow(
                  icon: Symbols.footprint,
                  title: '만보기',
                  cta: '방문하기',
                  onTap: () => _reward(context, '걸음 리워드', 8),
                ),
                _RewardRow(
                  icon: Symbols.quiz,
                  title: '행운 퀴즈',
                  cta: '방문하기',
                  onTap: () => _reward(context, '행운 퀴즈', 5),
                ),
                _RewardRow(
                  icon: Symbols.casino,
                  title: '룰렛',
                  cta: '방문하기',
                  onTap: () => _reward(context, '룰렛', 30),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // 미션
            Text(
              '미션',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _MissionCard(
              children: [
                _MissionRow(
                  icon: Symbols.exercise,
                  title: '이번 주 운동 3회 인증',
                  progress: '2/3',
                  reward: '+100P',
                  onTap: () => _reward(context, '운동 미션', 100),
                ),
                _MissionRow(
                  icon: Symbols.group_add,
                  title: '친구 초대하기',
                  progress: null,
                  reward: '+1,000P',
                  onTap: () => _reward(context, '친구 초대', 1000),
                ),
                _MissionRow(
                  icon: Symbols.redeem,
                  title: '스토어 첫 교환',
                  progress: null,
                  reward: '+50P',
                  onTap: () => _reward(context, '첫 교환', 50),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 내 마일리지 잔액 바.
class _MileageBar extends StatelessWidget {
  const _MileageBar({required this.mileage});
  final int mileage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lime,
            ),
            child: const Icon(Symbols.paid, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            '내 마일리지',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            '${_comma(mileage)}P',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
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
    required this.title,
    required this.cta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lime.withValues(alpha: 0.14),
              ),
              child: Icon(icon, color: AppColors.lime, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style:
                    textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            // 라임 아웃라인 pill 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lime, width: 1),
              ),
              child: Text(
                cta,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
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
      child: Column(children: children),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    required this.icon,
    required this.title,
    required this.reward,
    required this.onTap,
    this.progress,
  });

  final IconData icon;
  final String title;
  final String reward;
  final String? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lime.withValues(alpha: 0.14),
              ),
              child: Icon(icon, color: AppColors.lime, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      progress!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              reward,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.lime,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
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
