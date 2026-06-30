import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../domain/coupon.dart';

/// 보유 쿠폰 더미 목록.
const List<Coupon> _kCoupons = [
  // 멤버십
  Coupon(
    value: '10%',
    name: '멤버십 결제 할인',
    condition: '3개월권 이상',
    expiry: '2026.07.31',
    kind: CouponKind.membership,
  ),
  Coupon(
    value: '20,000원',
    name: '6개월권 재등록 할인',
    expiry: '2026.08.15',
    kind: CouponKind.membership,
  ),
  Coupon(
    value: '1개월',
    name: '락커 무료 이용권',
    condition: '멤버십 등록 회원',
    expiry: '2026.07.15',
    kind: CouponKind.membership,
  ),
  // 스토어
  Coupon(
    value: '2,000P',
    name: '스토어 교환 할인',
    condition: '3,000P 이상 사용 시',
    expiry: '2026.07.10',
    kind: CouponKind.store,
  ),
  Coupon(
    value: '50%',
    name: '음료 교환 할인',
    expiry: '2026.06.30',
    kind: CouponKind.store,
  ),
  Coupon(
    value: '1,000P',
    name: '신규 교환 적립',
    expiry: '2026.07.20',
    kind: CouponKind.store,
  ),
];

/// 쿠폰함 — 멤버십 / 스토어 탭(언더라인)으로 보유 쿠폰 카드 목록.
class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  CouponKind _tab = CouponKind.membership;

  @override
  Widget build(BuildContext context) {
    final coupons = _kCoupons.where((c) => c.kind == _tab).toList();

    return Scaffold(
      appBar: const AppTopBar(title: '쿠폰'),
      body: Column(
        children: [
          // 언더라인 탭 (찜한 상품과 동일 스타일)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.outline, width: 1),
                ),
              ),
              child: Row(
                children: [
                  _TabItem(
                    label: '멤버십',
                    selected: _tab == CouponKind.membership,
                    onTap: () =>
                        setState(() => _tab = CouponKind.membership),
                  ),
                  const SizedBox(width: 24),
                  _TabItem(
                    label: '스토어',
                    selected: _tab == CouponKind.store,
                    onTap: () => setState(() => _tab = CouponKind.store),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: coupons.isEmpty
                ? Center(
                    child: Text(
                      '보유한 쿠폰이 없어요',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: coupons.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, i) =>
                        _CouponCard(coupon: coupons[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 언더라인 탭 항목 — 선택 시 흰 볼드 + 라임 밑줄.
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.5,
              color: selected ? AppColors.lime : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

/// 쿠폰 카드 — 상단 큰 할인값 / 점선 구분선 / 하단 이름·만료.
class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 큰 할인값
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  coupon.value,
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '할인',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const _DashedDivider(),
          // 하단: 이름 + 조건 + 만료
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (coupon.condition != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    coupon.condition!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '~${coupon.expiry} 까지',
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

/// 쿠폰 절취선 느낌의 점선 구분선.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashW = 5.0;
        const gap = 4.0;
        final count = (constraints.maxWidth / (dashW + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: dashW,
              height: 1,
              color: AppColors.outline,
            ),
          ),
        );
      },
    );
  }
}
