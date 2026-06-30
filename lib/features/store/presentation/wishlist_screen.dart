import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../application/favorites_provider.dart';
import '../application/recent_provider.dart';
import '../domain/product.dart';
import 'widgets/product_card.dart';

/// 찜한 상품 화면 — 좋아요 / 최근 본 탭.
/// 마이페이지 "찜한 상품"에서 진입. 스토어와 동일한 상품 카드 그리드.
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  int _tab = 0; // 0: 좋아요, 1: 최근 본

  @override
  Widget build(BuildContext context) {
    final products =
        _tab == 0 ? ref.watch(favoriteProductsProvider) : ref.watch(recentProvider);

    return Scaffold(
      appBar: const AppTopBar(title: '찜한 상품'),
      body: Column(
        children: [
          // 세그먼트 탭
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _SegBtn(
                    label: '좋아요',
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  _SegBtn(
                    label: '최근 본',
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text(
                      _tab == 0 ? '좋아요한 상품이 없어요' : '최근 본 상품이 없어요',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  )
                : _ProductGrid(products: products),
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.lime : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.black : AppColors.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, i) => ProductCard(product: products[i]),
    );
  }
}
