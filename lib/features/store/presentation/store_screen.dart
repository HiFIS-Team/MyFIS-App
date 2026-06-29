import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../application/cart_provider.dart';
import '../application/product_catalog.dart';
import '../domain/product.dart';
import 'exchange_wallet.dart';
import 'search_screen.dart' show kSearchHeroTag, searchHeroShuttle;

/// 마일리지 스토어.
/// 보유 마일리지로 헬스장 내 상품을 교환한다. 현재는 더미 데이터.
class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  static const int _myMileage = 2400;
  static const List<Product> _products = kStoreProducts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 헤더: 검색창 + 보유 마일리지 (토스식, 타이틀 없음)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SearchBar(onTap: () => context.push('/search')),
                      ),
                      const SizedBox(width: 10),
                      const _MileagePill(points: _myMileage),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                    children: [
                  const _PromoBanner(),
                  const SizedBox(height: 24),
                  Text(
                    '상품 교환',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, i) =>
                        _ProductCard(product: _products[i]),
                  ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 장바구니가 비었을 때만 교환권 핸들 노출(자리 충돌 방지)
          if (cartCount == 0)
            const Positioned.fill(child: ExchangeWalletOverlay()),

          // 담은 상품이 있으면 하단 장바구니 바(배민식)
          if (cartCount > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 92,
              child: _CartBar(
                count: cartCount,
                total: cartTotal,
                onTap: () => context.push('/cart'),
              ),
            ),
        ],
      ),
    );
  }
}

/// 하단 장바구니 바 — 담은 상품이 있을 때만 노출.
class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.count,
    required this.total,
    required this.onTap,
  });

  final int count;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.lime,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // 개수 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '장바구니',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '${_comma(total)}P',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Symbols.chevron_right, color: Colors.black, size: 22),
          ],
        ),
      ),
    );
  }
}

/// 헤더 검색창 — 탭하면 검색 화면으로 이동.
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Hero(
        tag: kSearchHeroTag,
        flightShuttleBuilder: searchHeroShuttle,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Symbols.search,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 8),
              Text(
                '상품 검색',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 헤더 우측 보유 마일리지 (아이콘 + 숫자만).
class _MileagePill extends StatelessWidget {
  const _MileagePill({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Symbols.paid, color: AppColors.lime, size: 20, fill: 1),
          const SizedBox(width: 6),
          Text(
            _comma(points),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
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

/// 헤더 밑 프로모션 배너. 5초마다 자동으로 다음 사진으로 슬라이드되고,
/// 우하단에 현재/전체(예: 1/3) 인디케이터를 표시한다. 현재는 placeholder.
class _PromoBanner extends StatefulWidget {
  const _PromoBanner();

  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner> {
  // 실제 홍보 사진이 들어갈 자리. 지금은 그라데이션 + 문구 placeholder.
  static const List<_Promo> _promos = [
    _Promo(
      title: '신규 회원 이벤트',
      subtitle: '첫 등록 시 5,000P 적립',
      colors: [Color(0xFF2B3514), Color(0xFF566B25)],
    ),
    _Promo(
      title: '단백질 보충제 20% 할인',
      subtitle: '이번 주 한정 특가',
      colors: [Color(0xFF1E2A33), Color(0xFF2C4250)],
    ),
    _Promo(
      title: '친구 추천 이벤트',
      subtitle: '추천할 때마다 1,000P',
      colors: [Color(0xFF33231E), Color(0xFF50362C)],
    ),
  ];

  // 무한 순환을 위해 중앙에서 시작(앞뒤로 충분한 여유). _promos.length의 배수.
  static const int _initialPage = 30000;

  // viewportFraction < 1 → 양옆 카드가 살짝 보이는 토스식 peeking 캐러셀
  final PageController _controller =
      PageController(initialPage: _initialPage, viewportFraction: 0.9);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final cur = _controller.page?.round() ?? _initialPage;
      _controller.animateToPage(
        cur + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.9, // 가로로 긴 직사각형
      child: PageView.builder(
        controller: _controller,
        // itemCount 없음 → 무한 스크롤(양방향 순환)
        itemBuilder: (context, i) {
          final p = i % _promos.length;
          return _PromoSlide(
            promo: _promos[p],
            index: p,
            total: _promos.length,
          );
        },
      ),
    );
  }
}

class _Promo {
  const _Promo({
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
}

class _PromoSlide extends StatelessWidget {
  const _PromoSlide({
    required this.promo,
    required this.index,
    required this.total,
  });

  final _Promo promo;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    // 좌우 여백을 줘서 카드 사이에 틈을 만들고, 자체 라운드로 카드처럼 보이게.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: promo.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promo.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // 우하단 현재/전체 인디케이터 (카드에 얹혀 함께 이동)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${index + 1}/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textTheme = Theme.of(context).textTheme;
    final metaStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 상품 클릭 → 알림·바코드처럼 오른쪽에서 슬라이드되는 상세 화면
      onTap: () => context.push('/product', extra: product),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지 자리 (placeholder) + 우상단 재고 배지
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: AppColors.lime.withValues(alpha: 0.10),
                      child:
                          Icon(product.icon, color: AppColors.lime, size: 40),
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
                          size: 15, color: AppColors.lime, fill: 1),
                      const SizedBox(width: 3),
                      Text(product.rating.toStringAsFixed(1), style: metaStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 마일리지 + (라인 끝)하트
                  Row(
                    children: [
                      const Icon(Symbols.paid,
                          color: AppColors.lime, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_comma(product.points)}P',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.lime,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _liked = !_liked),
                        child: Icon(
                          Symbols.favorite,
                          size: 20,
                          fill: _liked ? 1 : 0,
                          color: _liked
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
