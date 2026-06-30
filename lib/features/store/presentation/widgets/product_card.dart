import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../application/favorites_provider.dart';
import '../../domain/product.dart';

/// 스토어/찜 목록 공용 상품 카드.
/// 탭하면 상세로, 하트는 찜(favoritesProvider) 토글.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final liked = ref.watch(favoritesProvider).contains(product.name);
    final metaStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return Pressable(
      onTap: () => context.push('/product', extra: product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 placeholder + 우상단 재고 배지
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: AppColors.surfaceAlt,
                      child: Icon(product.icon,
                          color: AppColors.textSecondary, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _StockBadge(stock: product.stock),
                  ),
                ],
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
                  // 조회수 + 평점
                  Row(
                    children: [
                      Icon(Symbols.visibility,
                          size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(_comma(product.views), style: metaStyle),
                      const SizedBox(width: 10),
                      const Icon(Symbols.star,
                          size: 15, color: AppColors.textSecondary, fill: 1),
                      const SizedBox(width: 3),
                      Text(product.rating.toStringAsFixed(1), style: metaStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 마일리지 + (라인 끝)하트
                  Row(
                    children: [
                      Text(
                        '${_comma(product.points)}P',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(product.name),
                        child: Icon(
                          Symbols.favorite,
                          size: 20,
                          fill: liked ? 1 : 0,
                          color: liked
                              ? const Color(0xFFFF6B6B)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 상품 카드 우상단 재고 배지. 재고가 적으면(<=5) 경고색.
class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final low = stock <= 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: low
            ? AppColors.error.withValues(alpha: 0.92)
            : Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        low ? '$stock개 남음' : '재고 $stock',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
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
