import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// 마이 페이지.
/// 프로필 · 퀵 스탯(마일리지/출석/랭킹) · 신체 정보 · 메뉴. 현재는 더미 데이터.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            // 상단: 타이틀 + 설정
            Row(
              children: [
                Text(
                  'MY',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Symbols.settings,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 프로필
            _ProfileHeader(
              name: '김은후',
              phone: '010-1234-5678',
              onTap: () => context.push('/profile'),
            ),
            const SizedBox(height: 14),

            // 퀵 스탯
            const _QuickStats(mileage: 2400, attendance: 18, rank: 3),
            const SizedBox(height: 14),

            // 멤버십 + 부가상품(락커·운동복)
            const _MembershipCard(
              name: '헬스 6개월권',
              lockerMonths: 3, // 구매함
              wearMonths: null, // 미구매 → 구매하기
            ),
            const SizedBox(height: 14),

            // 신체 정보
            const _BodyInfoCard(height: 175, weight: 70, bmi: 22.9),
            const SizedBox(height: 26),

            // 내 활동
            _SectionLabel('내 활동'),
            const SizedBox(height: 10),
            const _MenuCard(rows: [
              _MenuRow(icon: Symbols.calendar_month, label: '출석 내역'),
              _MenuRow(icon: Symbols.confirmation_number, label: '교환 내역'),
              _MenuRow(icon: Symbols.favorite, label: '찜한 상품', isLast: true),
            ]),
            const SizedBox(height: 22),

            // 계정
            _SectionLabel('계정'),
            const SizedBox(height: 10),
            const _MenuCard(rows: [
              _MenuRow(icon: Symbols.lock, label: '비밀번호 변경'),
              _MenuRow(icon: Symbols.credit_card, label: '결제 카드 관리'),
              _MenuRow(
                  icon: Symbols.notifications,
                  label: '알림 설정',
                  isLast: true),
            ]),
            const SizedBox(height: 22),

            // 기타
            const _MenuCard(rows: [
              _MenuRow(icon: Symbols.help, label: '고객센터 · 문의'),
              _MenuRow(
                icon: Symbols.logout,
                label: '로그아웃',
                danger: true,
                isLast: true,
              ),
            ]),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '버전 1.0.0',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.phone,
    required this.onTap,
  });
  final String name;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
        children: [
          // 아바타 (라임 원형)
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Symbols.person,
                color: AppColors.lime, size: 32, fill: 1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  phone,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({
    required this.mileage,
    required this.attendance,
    required this.rank,
  });

  final int mileage;
  final int attendance;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: _comma(mileage),
              label: '마일리지',
              valueColor: AppColors.lime,
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatItem(value: '$attendance일', label: '이번 달 출석'),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatItem(value: '$rank위', label: '출석 랭킹'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.outline);
  }
}

/// 멤버십 카드 — 멤버십 이름 + 부가상품(락커·운동복).
/// 부가상품은 구매했으면 N개월, 안 했으면 구매하기 버튼.
class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.name,
    required this.lockerMonths,
    required this.wearMonths,
  });

  final String name;
  final int? lockerMonths; // null이면 미구매
  final int? wearMonths;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 멤버십 이름 + 상태
          Row(
            children: [
              const Icon(Symbols.card_membership,
                  color: AppColors.lime, size: 22, fill: 1),
              const SizedBox(width: 8),
              Text(
                name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '이용 중',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // 부가상품 2칸
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _AddonItem(
                    icon: Symbols.lock,
                    label: '락커',
                    months: lockerMonths,
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.outline,
                ),
                Expanded(
                  child: _AddonItem(
                    icon: Symbols.checkroom,
                    label: '운동복',
                    months: wearMonths,
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

class _AddonItem extends StatelessWidget {
  const _AddonItem({
    required this.icon,
    required this.label,
    required this.months,
  });

  final IconData icon;
  final String label;
  final int? months; // null이면 미구매

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final purchased = months != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (purchased)
            Text(
              '$months개월 남음',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            )
          else
            SizedBox(
              height: 36,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '구매하기',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BodyInfoCard extends StatelessWidget {
  const _BodyInfoCard({
    required this.height,
    required this.weight,
    required this.bmi,
  });

  final int height;
  final int weight;
  final double bmi;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '신체 정보',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '수정',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatItem(value: '$height', label: '키 (cm)')),
              const _StatDivider(),
              Expanded(child: _StatItem(value: '$weight', label: '몸무게 (kg)')),
              const _StatDivider(),
              Expanded(
                child: _StatItem(
                  value: bmi.toStringAsFixed(1),
                  label: 'BMI',
                  valueColor: AppColors.lime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.rows});
  final List<_MenuRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: rows),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.isLast = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool isLast;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = danger ? AppColors.error : null;

    return Column(
      children: [
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: color ?? AppColors.lime, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                if (!danger)
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
