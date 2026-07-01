import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/pressable.dart';
import '../domain/membership_tier.dart';

/// 멤버십 화면 — 회원 등급 + 등급 혜택 + 관리 메뉴.
/// (무신사식 등급/진행바 + 배민식 혜택 카드)
/// 활성 회원권 현황은 마이페이지에서 보여주므로 여기선 생략.
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  void _todo(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label (준비 중)')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: '멤버십'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          // 등급 카드 (진행바)
          const _TierCard(attendance: kMyAttendance),
          const SizedBox(height: 28),

          // 등급 혜택
          Text(
            '내 등급 혜택',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.4,
            children: [
              for (final b in kTierBenefits) _BenefitCard(benefit: b),
            ],
          ),
          const SizedBox(height: 28),

          // 관리
          Text(
            '관리',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            children: [
              _MenuRow(
                icon: Symbols.event_repeat,
                label: '이용권 연장 · 변경',
                onTap: () => _todo(context, '이용권 연장 · 변경'),
              ),
              _MenuRow(
                icon: Symbols.credit_card,
                label: '결제 카드 관리',
                onTap: () => _todo(context, '결제 카드 관리'),
              ),
              _MenuRow(
                icon: Symbols.receipt_long,
                label: '이용 내역',
                onTap: () => _todo(context, '이용 내역'),
              ),
              _MenuRow(
                icon: Symbols.storefront,
                label: '지점 안내',
                isLast: true,
                onTap: () => context.push('/branches'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 회원 등급 카드 — 현재 등급 + 다음 등급까지 진행바.
class _TierCard extends StatelessWidget {
  const _TierCard({required this.attendance});
  final int attendance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final idx = currentTierIndex(attendance);
    final tier = kTiers[idx];
    final hasNext = idx < kTiers.length - 1;
    final next = hasNext ? kTiers[idx + 1] : null;

    // 현재 등급 시작점 대비 다음 등급까지 진행률
    final base = tier.threshold;
    final target = next?.threshold ?? tier.threshold;
    final progress = hasNext
        ? ((attendance - base) / (target - base)).clamp(0.0, 1.0)
        : 1.0;
    final remain = hasNext ? (target - attendance).clamp(0, target) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tier.color1, tier.color2],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.workspace_premium,
                  color: Colors.white, size: 22, fill: 1),
              const SizedBox(width: 6),
              Text(
                '${tier.name} 회원',
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '이번 시즌 $attendance회',
                style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // 진행바
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasNext
                ? '${next!.name}까지 출석 $remain회 남았어요'
                : '최고 등급을 달성했어요 🎉',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 등급 혜택 카드 (아이콘 + 제목 + 설명).
class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.benefit});
  final TierBenefit benefit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lime.withValues(alpha: 0.14),
            ),
            child: Icon(benefit.icon, color: AppColors.lime, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  benefit.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  benefit.desc,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 22),
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
