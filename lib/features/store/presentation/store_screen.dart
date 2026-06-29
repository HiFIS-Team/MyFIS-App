import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// 마일리지 스토어.
/// 보유 마일리지로 헬스장 내 상품을 교환한다. 현재는 더미 데이터.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  static const int _myMileage = 2400;
  static const List<_Product> _products = [
    _Product(icon: Symbols.exercise, name: '프로틴 쉐이커', points: 1000),
    _Product(icon: Symbols.dry_cleaning, name: '운동 타월', points: 500),
    _Product(icon: Symbols.nutrition, name: '보충제 1회분', points: 800),
    _Product(icon: Symbols.local_drink, name: '이온음료', points: 300),
    _Product(icon: Symbols.sports_gymnastics, name: 'PT 1회 체험', points: 5000),
    _Product(icon: Symbols.lock, name: '락커 1개월', points: 3000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('스토어'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _MileageBalance(points: _myMileage),
          const SizedBox(height: 20),
          Text(
            '상품 교환',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, i) => _ProductCard(product: _products[i]),
          ),
        ],
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

class _MileageBalance extends StatelessWidget {
  const _MileageBalance({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Symbols.paid, color: AppColors.lime, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '내 마일리지',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_comma(points)}P',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Product {
  const _Product({
    required this.icon,
    required this.name,
    required this.points,
  });

  final IconData icon;
  final String name;
  final int points;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final _Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지 자리 (placeholder)
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.lime.withValues(alpha: 0.10),
              child: Icon(product.icon, color: AppColors.lime, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Symbols.paid, color: AppColors.lime, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_comma(product.points)}P',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.lime,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
