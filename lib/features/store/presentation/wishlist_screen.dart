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
          // 언더라인 탭
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.outline, width: 1),
                ),
              ),
              child: Row(
                children: [
                  _TabItem(
                    label: '좋아요',
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  const SizedBox(width: 24),
                  _TabItem(
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

/// 언더라인 탭 항목 — 선택 시 흰 볼드 글씨 + 라임 밑줄.
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.5,
              color: selected ? AppColors.lime : Colors.transparent,
            ),
          ],
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
