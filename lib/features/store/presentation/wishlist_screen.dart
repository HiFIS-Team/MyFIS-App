import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../application/favorites_provider.dart';
import 'widgets/product_card.dart';

/// 찜한 상품 화면.
/// 마이페이지 "찜한 상품"에서 진입. 스토어와 동일한 상품 카드 그리드.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(favoriteProductsProvider);

    return Scaffold(
      appBar: const AppTopBar(title: '찜한 상품'),
      body: products.isEmpty
          ? Center(
              child: Text(
                '찜한 상품이 없어요',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, i) => ProductCard(product: products[i]),
            ),
    );
  }
}
