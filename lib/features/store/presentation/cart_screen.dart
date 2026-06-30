import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../application/cart_provider.dart';
import '../application/exchange_orders_provider.dart';

/// 장바구니 화면.
/// 담은 상품의 수량 조절·삭제 후, 마일리지로 한 번에 교환한다.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

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
                          fontWeight: FontWeight.w600,
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
          onPressed: () {
            // 요약 만들고 → 교환권 발급(항목 수만큼 카드 추가) → 카트 비움 → 완료 화면
            final first = items.first.product.name;
            final summary = items.length == 1
                ? '$first x${items.first.qty}'
                : '$first 외 ${items.length - 1}건';
            ref.read(exchangeOrdersProvider.notifier).addFromCart(items);
            ref.read(cartProvider.notifier).clear();
            context.push(
              '/exchange-complete',
              extra: (summary: summary, totalPoints: total),
            );
          },
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
