import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../application/coupon_catalog.dart';
import '../domain/coupon.dart';
import 'widgets/coupon_card.dart';

/// 교환 시 쿠폰 선택 화면.
/// 스토어 할인 쿠폰을 라디오로 하나 고르고, 적용하기로 선택을 반환한다.
/// 사용 불가(적립형 등) 쿠폰은 흐리게 표시.
class CouponSelectScreen extends StatefulWidget {
  const CouponSelectScreen({super.key, this.selected});

  /// 이미 선택돼 있던 쿠폰(있으면 라디오 체크 상태로 진입).
  final Coupon? selected;

  @override
  State<CouponSelectScreen> createState() => _CouponSelectScreenState();
}

class _CouponSelectScreenState extends State<CouponSelectScreen> {
  Coupon? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final storeCoupons =
        kCoupons.where((c) => c.kind == CouponKind.store).toList();

    return Scaffold(
      appBar: const AppTopBar(title: '쿠폰 선택'),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: storeCoupons.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final c = storeCoupons[i];
          final usable = c.usableForExchange;
          final isSel = identical(_selected, c);
          return CouponCard(
            coupon: c,
            selectable: true,
            selected: isSel,
            dimmed: !usable,
            // 사용 불가 쿠폰은 탭 막음. 같은 걸 다시 누르면 선택 해제.
            onTap: usable
                ? () => setState(() => _selected = isSel ? null : c)
                : null,
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(_CouponResult(_selected)),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _selected == null ? '쿠폰 없이 교환' : '쿠폰 적용하기',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.lime,
                ),
          ),
        ),
      ),
    );
  }
}

/// 결과 래퍼 — null(선택 안 함)과 "취소(뒤로가기)"를 구분하기 위해 사용.
/// 뒤로가기로 닫으면 null이 반환되어 기존 선택을 유지한다.
class _CouponResult {
  const _CouponResult(this.coupon);
  final Coupon? coupon;
}

/// 교환 시트 등에서 쿠폰 선택 화면을 띄우고 결과를 받는다.
/// 적용하기를 누르면 선택(또는 해제)을, 뒤로가기면 [current]를 그대로 반환.
Future<Coupon?> pickExchangeCoupon(
  BuildContext context, {
  Coupon? current,
}) async {
  final result = await Navigator.of(context).push<_CouponResult>(
    MaterialPageRoute(
      builder: (_) => CouponSelectScreen(selected: current),
    ),
  );
  return result == null ? current : result.coupon;
}
