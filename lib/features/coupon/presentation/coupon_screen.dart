import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../application/coupon_catalog.dart';
import '../domain/coupon.dart';
import 'widgets/coupon_card.dart';

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
    final coupons = kCoupons.where((c) => c.kind == _tab).toList();

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
                    onTap: () => setState(() => _tab = CouponKind.membership),
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
                        CouponCard(coupon: coupons[i]),
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
