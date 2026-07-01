import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../coupon/domain/coupon.dart';
import '../../coupon/presentation/coupon_select_screen.dart';
import '../application/cart_provider.dart';
import '../application/exchange_orders_provider.dart';

/// 장바구니 화면.
/// 담은 상품의 수량 조절·삭제 후, 교환하기 → 교환 확인 시트(쿠폰 선택)로 교환.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  // 교환하기 → 교환 확인 시트(수량 없이 쿠폰만) → 교환 처리.
  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final items = ref.read(cartProvider);
    if (items.isEmpty) return;
    final rawTotal = ref.read(cartTotalProvider);

    final result =
        await showModalBottomSheet<({Coupon? coupon, int total})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _CartCheckoutSheet(itemCount: items.length, rawTotal: rawTotal),
    );
    if (result == null || !context.mounted) return;

    final first = items.first.product.name;
    final base = items.length == 1
        ? '$first x${items.first.qty}'
        : '$first 외 ${items.length - 1}건';
    final summary =
        result.coupon != null ? '$base · ${result.coupon!.name}' : base;
    ref.read(exchangeOrdersProvider.notifier).addFromCart(items);
    ref.read(cartProvider.notifier).clear();
    context.push(
      '/exchange-complete',
      extra: (summary: summary, totalPoints: result.total),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Scaffold(
        appBar: const AppTopBar(title: '장바구니'),
        body: Center(
          child: Text(
            '담은 상품이 없어요',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const AppTopBar(title: '장바구니'),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // 썸네일 (placeholder)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.product.icon,
                      color: AppColors.textSecondary, size: 28),
                ),
                const SizedBox(width: 14),
                // 이름 + 가격
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Symbols.paid,
                              size: 15, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            '${_comma(item.linePoints)}P',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 수량 스테퍼
                _QtyStepper(
                  qty: item.qty,
                  onMinus: item.qty > 1
                      ? () =>
                          ref.read(cartProvider.notifier).setQty(i, item.qty - 1)
                      : () => ref.read(cartProvider.notifier).removeAt(i),
                  onPlus: () =>
                      ref.read(cartProvider.notifier).setQty(i, item.qty + 1),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: FilledButton(
          onPressed: () => _checkout(context, ref),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            '${_comma(total)}P로 교환하기',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.lime,
            ),
          ),
        ),
      ),
    );
  }
}

/// 장바구니 교환 확인 시트 — 수량 없이 쿠폰만 선택해 교환.
class _CartCheckoutSheet extends StatefulWidget {
  const _CartCheckoutSheet({required this.itemCount, required this.rawTotal});
  final int itemCount;
  final int rawTotal;

  @override
  State<_CartCheckoutSheet> createState() => _CartCheckoutSheetState();
}

class _CartCheckoutSheetState extends State<_CartCheckoutSheet> {
  Coupon? _coupon;

  Future<void> _pickCoupon() async {
    final picked = await pickExchangeCoupon(context, current: _coupon);
    if (mounted) setState(() => _coupon = picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final discount = _coupon?.discountFor(widget.rawTotal) ?? 0;
    final total = widget.rawTotal - discount;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 그래버
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              '교환 확인',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '상품 ${widget.itemCount}종',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // 쿠폰 적용
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pickCoupon,
              child: Row(
                children: [
                  Text(
                    '쿠폰',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _coupon == null ? '쿠폰 선택' : '${_coupon!.value} 할인',
                    style: textTheme.bodyMedium?.copyWith(
                      color: _coupon == null
                          ? AppColors.textSecondary
                          : AppColors.lime,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Symbols.chevron_right,
                      size: 20, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.outline),
            const SizedBox(height: 18),
            // 쿠폰 할인 라인
            if (discount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '쿠폰 할인',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '-${_comma(discount)}P',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.lime,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // 합계
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '총 교환 마일리지',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Symbols.paid,
                        size: 22, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      '${_comma(total)}P',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop((coupon: _coupon, total: total)),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '${_comma(total)}P 교환하기',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.lime,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 수량 증감 스테퍼.
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Symbols.remove, onMinus),
          SizedBox(
            width: 34,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          _btn(Symbols.add, onPlus),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
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
