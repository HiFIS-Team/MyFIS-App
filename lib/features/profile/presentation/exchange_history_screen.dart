import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../store/application/exchange_orders_provider.dart';
import '../../store/application/product_catalog.dart';
import '../../store/domain/exchange_order.dart';

/// 교환 내역 — 스토어에서 마일리지로 교환한 내역(교환권 지갑과 동일 데이터).
/// 결제 내역(원화)과 별개로, 마일리지(P) 소비 내역만 모아 보여준다.
class ExchangeHistoryScreen extends ConsumerWidget {
  const ExchangeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final orders = ref.watch(exchangeOrdersProvider);
    const mileage = 2400;

    // 날짜별 그룹.
    final children = <Widget>[];
    String? lastDate;
    for (final o in orders) {
      if (o.date != lastDate) {
        children.add(_DateHeader(o.date));
        lastDate = o.date;
      }
      children.add(_ExchangeRow(order: o));
    }

    return Scaffold(
      appBar: const AppTopBar(title: '교환 내역'),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 마일리지 — 다른 페이지(혜택·스토어·결제 내역)와 동일한 가로 구분선 스타일
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              child: Row(
                children: [
                  const Expanded(
                      child: Divider(color: AppColors.outline, height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Symbols.paid,
                            color: AppColors.lime, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${_comma(mileage)}P',
                          style: textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: AppColors.outline, height: 1)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 리스트
            Expanded(
              child: children.isEmpty
                  ? Center(
                      child: Text(
                        '아직 교환 내역이 없어요',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
                      children: children,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카탈로그에서 상품명으로 아이콘·단가를 찾는다(없으면 기본값).
({IconData icon, int points}) _lookup(String name) {
  for (final p in kStoreProducts) {
    if (p.name == name) return (icon: p.icon, points: p.points);
  }
  return (icon: Symbols.redeem, points: 0);
}

class _ExchangeRow extends StatelessWidget {
  const _ExchangeRow({required this.order});
  final ExchangeOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final info = _lookup(order.name);
    final total = info.points * order.qty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lime.withValues(alpha: 0.14),
            ),
            child: Icon(info.icon, color: AppColors.lime, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.qty > 1 ? '${order.name} x${order.qty}' : order.name,
                  style:
                      textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '교환번호 ${order.number}',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total > 0 ? '-${_comma(total)}P' : '교환',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              _StatusChip(done: order.done),
            ],
          ),
        ],
      ),
    );
  }
}

/// 수령 완료 / 수령 전 상태 칩.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.done});
  final bool done;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: done
            ? AppColors.surfaceAlt
            : AppColors.lime.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        done ? '수령 완료' : '수령 전',
        style: textTheme.labelSmall?.copyWith(
          color: done ? AppColors.textSecondary : AppColors.lime,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader(this.date);
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
      child: Text(
        date,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// 천단위 콤마.
String _comma(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
