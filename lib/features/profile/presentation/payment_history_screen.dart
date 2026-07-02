import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';

/// 결제 내역 항목.
class PayTx {
  const PayTx({
    required this.date,
    required this.name,
    required this.time,
    required this.amount, // 음수=결제, 양수=적립/환불
    required this.method,
    required this.icon,
    required this.color,
  });
  final String date;
  final String name;
  final String time;
  final int amount;
  final String method;
  final IconData icon;
  final Color color;
}

/// 결제 내역 더미 (최신순).
final List<PayTx> kPayHistory = [
  PayTx(
    date: '7월 1일',
    name: 'MyFIS 멤버십',
    time: '09:00',
    amount: -59000,
    method: '정기결제',
    icon: Symbols.card_membership,
    color: const Color(0xFF5B9DFF),
  ),
  PayTx(
    date: '7월 1일',
    name: '마일리지 적립',
    time: '09:00',
    amount: 590,
    method: '결제 적립',
    icon: Symbols.paid,
    color: AppColors.lime,
  ),
  PayTx(
    date: '6월 28일',
    name: 'MyFIS 스토어',
    time: '13:20',
    amount: -12000,
    method: '일시불',
    icon: Symbols.shopping_bag,
    color: const Color(0xFFFF6BAE),
  ),
  PayTx(
    date: '6월 15일',
    name: 'PT 10회권',
    time: '19:05',
    amount: -350000,
    method: '3개월 할부',
    icon: Symbols.fitness_center,
    color: const Color(0xFF4FD1C5),
  ),
  PayTx(
    date: '6월 1일',
    name: 'MyFIS 멤버십',
    time: '09:00',
    amount: -59000,
    method: '정기결제',
    icon: Symbols.card_membership,
    color: const Color(0xFF5B9DFF),
  ),
];

/// 결제 내역 — 상단 보유 마일리지 + 검색 + 날짜별 그룹 거래 리스트 (토스식).
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  static const int _mileage = 2400;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final q = _query.trim();
    final list =
        q.isEmpty ? kPayHistory : kPayHistory.where((t) => t.name.contains(q)).toList();

    final children = <Widget>[];
    String? lastDate;
    for (final tx in list) {
      if (tx.date != lastDate) {
        children.add(_DateHeader(tx.date));
        lastDate = tx.date;
      }
      children.add(PayTxRow(tx: tx));
    }

    return Scaffold(
      appBar: const AppTopBar(title: '결제 내역'),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 마일리지 — 다른 페이지(혜택·스토어)와 동일한 가로 구분선 스타일
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
                          '${_comma(_mileage)}P',
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

            // 검색
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Symbols.search,
                        color: AppColors.textSecondary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (v) => setState(() => _query = v),
                        cursorColor: AppColors.lime,
                        style: textTheme.bodyLarge,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: '결제 내역 검색',
                          hintStyle:
                              TextStyle(color: AppColors.textSecondary),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          _search.clear();
                          _query = '';
                        }),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary, size: 20),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),

            // 리스트
            Expanded(
              child: children.isEmpty
                  ? Center(
                      child: Text(
                        '검색 결과가 없어요',
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

/// 거래 한 줄 — 아이콘 + 이름/시간 + 금액/결제수단. (결제 내역·카드 상세 공용)
class PayTxRow extends StatelessWidget {
  const PayTxRow({super.key, required this.tx});
  final PayTx tx;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final income = tx.amount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tx.color.withValues(alpha: 0.16),
            ),
            child: Icon(tx.icon, color: tx.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.name,
                  style:
                      textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.time,
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
                _won(tx.amount),
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: income ? AppColors.lime : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tx.method,
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 부호 + 천단위 콤마 + 원.
String _won(int amount) {
  final sign = amount < 0 ? '-' : '+';
  final s = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '$sign${buf.toString()}원';
}
