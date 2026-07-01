import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pressable.dart';

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

            // 프로필 + 퀵스탯 (한 카드로 통합)
            _ProfileCard(
              name: '김은후',
              phone: '010-1234-5678',
              mileage: 2400,
              attendance: 18,
              rank: 3,
              onTapProfile: () => context.push('/profile'),
            ),
            const SizedBox(height: 14),

            // 멤버십 + 부가상품(락커·운동복)
            const _MembershipCard(
              name: '헬스 6개월권',
              lockerMonths: 3, // 구매함
              wearMonths: null, // 미구매 → 구매하기
            ),
            const SizedBox(height: 26),

            // 내 활동
            _SectionLabel('내 활동'),
            const SizedBox(height: 10),
            _MenuCard(rows: [
              const _MenuRow(label: '출석 내역'),
              const _MenuRow(label: '교환 내역'),
              _MenuRow(label: '찜한 상품', onTap: () => context.push('/wishlist')),
            ]),
            const SizedBox(height: 22),

            // 결제
            _SectionLabel('결제'),
            const SizedBox(height: 10),
            _MenuCard(rows: [
              const _MenuRow(label: '결제 내역'),
              const _MenuRow(label: '결제 카드 관리'),
              _MenuRow(label: '쿠폰', onTap: () => context.push('/coupon')),
              const _MenuRow(label: '포인트'),
            ]),
            const SizedBox(height: 22),

            // 설정
            _SectionLabel('설정'),
            const SizedBox(height: 10),
            const _MenuCard(rows: [
              _MenuRow(label: '알림 설정'),
              _MenuRow(label: '비밀번호 변경'),
              _MenuRow(label: '앱 버전', trailing: '1.0.0'),
            ]),
            const SizedBox(height: 22),

            // 로그아웃
            const _MenuCard(rows: [
              _MenuRow(
                  label: '로그아웃', danger: true, trailingIcon: Symbols.logout),
            ]),
          ],
        ),
      ),
    );
  }
}

/// 프로필 + 퀵스탯 통합 카드.
/// 위: 아바타·이름·연락처(탭 → 프로필 상세) / 구분선 / 아래: 마일리지·출석·랭킹.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.phone,
    required this.mileage,
    required this.attendance,
    required this.rank,
    required this.onTapProfile,
  });

  final String name;
  final String phone;
  final int mileage;
  final int attendance;
  final int rank;
  final VoidCallback onTapProfile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // 프로필 (탭 → 상세)
          Pressable(
            onTap: onTapProfile,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Symbols.person,
                        color: AppColors.textSecondary, size: 32, fill: 1),
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
          ),
          Divider(height: 1, thickness: 1, color: AppColors.outline),
          // 퀵스탯
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    value: _comma(mileage),
                    label: '마일리지',
                    valueColor: AppColors.textPrimary,
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Text(
            '내 멤버십',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          // 멤버십 이름 + 상태 칩
          Row(
            children: [
              const Icon(Symbols.card_membership,
                  color: AppColors.textSecondary, size: 22, fill: 1),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '이용 중',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 부가상품 — 락커(좌) · 운동복(우) 블럭
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _AddonItem(label: '락커', months: lockerMonths),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AddonItem(label: '운동복', months: wearMonths),
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
    required this.label,
    required this.months,
  });

  final String label;
  final int? months; // null이면 미구매

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final purchased = months != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (purchased)
            Text(
              '$months개월',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            )
          else
            SizedBox(
              height: 32,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.lime,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: AppColors.lime, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '구매하기',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.lime,
                  ),
                ),
              ),
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: rows),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    this.danger = false,
    this.trailing,
    this.trailingIcon,
    this.onTap,
  });

  final String label;
  final bool danger;
  final String? trailing; // 우측 값(예: 앱 버전). 있으면 chevron 대신 표시
  final IconData? trailingIcon; // 우측 아이콘(예: 로그아웃). chevron 자리에 표시
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = danger ? AppColors.error : null;

    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        child: Row(
          children: [
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const Spacer(),
            if (trailingIcon != null)
              Icon(trailingIcon, color: color ?? AppColors.textSecondary,
                  size: 22)
            else if (trailing != null)
              Text(
                trailing!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else if (!danger)
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 22),
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
