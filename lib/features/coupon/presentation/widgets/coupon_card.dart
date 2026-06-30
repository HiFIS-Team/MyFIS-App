import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/coupon.dart';

/// 쿠폰 카드 — 상단 큰 할인값 / 점선 절취선 / 하단 이름·조건·만료.
/// [selectable]이면 좌측에 라디오를 두고, 탭하면 [onTap]을 호출한다.
class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    required this.coupon,
    this.selectable = false,
    this.selected = false,
    this.dimmed = false,
    this.onTap,
  });

  final Coupon coupon;
  final bool selectable;
  final bool selected;
  final bool dimmed; // 사용 불가(흐리게)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valueColor = dimmed ? AppColors.textSecondary : AppColors.lime;

    final card = Opacity(
      opacity: dimmed ? 0.5 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: AppColors.lime, width: 1.4)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: (라디오) + 큰 할인값
            Padding(
              padding: EdgeInsets.fromLTRB(selectable ? 16 : 20, 20, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (selectable) ...[
                    _Radio(selected: selected),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    coupon.value,
                    style: textTheme.headlineMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '할인',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
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
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}

/// 라디오 동그라미 — 선택 시 라임 채움 + 체크.
class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.lime : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.lime : AppColors.outline,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: Colors.black)
          : null,
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
            (_) => Container(width: dashW, height: 1, color: AppColors.outline),
          ),
        );
      },
    );
  }
}
