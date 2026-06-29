import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// 교환권(주문) 한 건. 현재는 더미 데이터.
class _ExchangeOrder {
  const _ExchangeOrder({
    required this.name,
    required this.number,
    required this.qty,
    required this.date,
    required this.done,
  });

  final String name;
  final String number; // 교환번호 (프론트 제시용)
  final int qty;
  final String date;
  final bool done; // 수령 완료 여부
}

const List<_ExchangeOrder> _dummyOrders = [
  _ExchangeOrder(
      name: '프로틴 쉐이커', number: 'A3F92', qty: 2, date: '6/29', done: false),
  _ExchangeOrder(
      name: '이온음료', number: 'B7K10', qty: 1, date: '6/27', done: true),
  _ExchangeOrder(
      name: '운동 타월', number: 'C1D45', qty: 1, date: '6/20', done: true),
];

/// 삼성페이처럼 아래에서 끌어올리는 "내 교환권" 지갑.
/// 각 카드에 교환번호가 보인다. 현재는 더미 데이터.
Future<void> showExchangeWallet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true, // 하단 네비바까지 덮도록 루트에서 띄움
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => const _ExchangeWalletSheet(),
  );
}

class _ExchangeWalletSheet extends StatelessWidget {
  const _ExchangeWalletSheet();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // 그래버
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '내 교환권',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_dummyOrders.length}장',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.lime,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: _dummyOrders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) =>
                      _WalletCard(order: _dummyOrders[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 교환권 카드 — 바우처 느낌. 교환번호를 크게 표시.
class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.order});
  final _ExchangeOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final done = order.done;

    return Container(
      height: 172,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: done
              ? const [Color(0xFF202020), Color(0xFF2A2A2A)]
              : const [Color(0xFF2B3514), Color(0xFF566B25)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${order.name} x${order.qty}',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              // 상태 칩
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: done
                      ? Colors.white.withValues(alpha: 0.10)
                      : AppColors.lime,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  done ? '수령 완료' : '수령 전',
                  style: textTheme.bodySmall?.copyWith(
                    color: done ? AppColors.textSecondary : Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '교환번호',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order.number,
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const Spacer(),
              Icon(Symbols.qr_code_2,
                  color: Colors.white.withValues(alpha: 0.85), size: 26),
              const SizedBox(width: 8),
              Text(
                order.date,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
