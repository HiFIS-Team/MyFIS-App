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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                _RewardTile(
                  icon: Symbols.event_available,
                  title: '출석 체크',
                  reward: '+10P',
                  cta: '받기',
                  onTap: () => _reward(context, '출석 체크', 10),
                ),
                _RewardTile(
                  icon: Symbols.footprint,
                  title: '만보기',
                  reward: '3,240보',
                  cta: '받기',
                  onTap: () => _reward(context, '걸음 리워드', 8),
                ),
                _RewardTile(
                  icon: Symbols.quiz,
                  title: '행운 퀴즈',
                  reward: '+5P',
                  cta: '풀기',
                  onTap: () => _reward(context, '행운 퀴즈', 5),
                ),
                _RewardTile(
                  icon: Symbols.casino,
                  title: '룰렛',
                  reward: '최대 100P',
                  cta: '돌리기',
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
                  isLast: true,
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

/// 오늘의 루틴 히어로 카드 — 루틴 완료 시 받을 마일리지 강조 + 큰 CTA. (토스식)
class _RoutineHeroCard extends StatelessWidget {
  const _RoutineHeroCard({required this.points, required this.onGo});
  final int points;
  final VoidCallback onGo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F2A10), Color(0xFF33450F)],
        ),
      ),
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
                  text: '$points P',
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
              onPressed: onGo,
              child: const Text('마일리지 받으러 가기'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 매일 받기 타일.
class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.icon,
    required this.title,
    required this.reward,
    required this.cta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String reward;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.lime, size: 26),
            const Spacer(),
            Text(
              title,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  reward,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  cta,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String reward;
  final String? progress;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Pressable(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outline,
            indent: 16,
            endIndent: 16,
          ),
      ],
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
