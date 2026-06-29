import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../domain/product.dart';

/// 상품 상세 화면.
/// 스토어에서 상품 카드를 누르면 오른쪽→왼쪽 슬라이드로 진입(알림·바코드와 동일).
/// 현재는 더미 데이터.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppTopBar(
        title: product.name,
        actions: [
          IconButton(
            onPressed: () => setState(() => _liked = !_liked),
            icon: Icon(
              Symbols.favorite,
              fill: _liked ? 1 : 0,
              color: _liked ? const Color(0xFFFF6B6B) : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // 상품 이미지 자리 (placeholder)
          AspectRatio(
            aspectRatio: 1.1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(product.icon, color: AppColors.lime, size: 96),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            product.name,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          // 조회수 + 평점
          Row(
            children: [
              Icon(Symbols.visibility, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${_comma(product.views)}명이 봤어요',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Symbols.star, size: 18, color: AppColors.lime, fill: 1),
              const SizedBox(width: 4),
              Text(
                product.rating.toStringAsFixed(1),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('상품 설명', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '마일리지로 교환할 수 있는 상품이에요. 자세한 상품 설명은 추후 추가될 예정입니다.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
      // 하단 고정 교환 버튼
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Symbols.paid, size: 20),
              const SizedBox(width: 6),
              Text(
                '${_comma(product.points)}P로 교환하기',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
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
