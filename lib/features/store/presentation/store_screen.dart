import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stagger_in.dart';
import '../application/cart_provider.dart';
import '../application/product_catalog.dart';
import 'exchange_wallet.dart';
import 'search_screen.dart'
    show kSearchHeroTag, kSearchHintStyle, searchHeroShuttle;
import 'widgets/product_card.dart';

/// 마일리지 스토어.
/// 보유 마일리지로 헬스장 내 상품을 교환한다. 현재는 더미 데이터.
class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  static const int _myMileage = 2400;

  String _category = kStoreCategories.first; // '전체'

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final products = _category == kStoreCategories.first
        ? kStoreProducts
        : kStoreProducts.where((p) => p.category == _category).toList();
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
                // 카테고리 가로 필터 (언더라인 탭)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.outline, width: 1),
                    ),
                  ),
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: kStoreCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 20),
                      itemBuilder: (context, i) {
                        final c = kStoreCategories[i];
                        return _CategoryTab(
                          label: c,
                          selected: c == _category,
                          onTap: () => setState(() => _category = c),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
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
                    // 카테고리 바뀌면 새로 마운트되어 스태거 등장 재생
                    key: ValueKey(_category),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, i) => StaggerIn(
                      index: i,
                      step: const Duration(milliseconds: 70),
                      duration: const Duration(milliseconds: 420),
                      offset: 24,
                      child: ProductCard(product: products[i]),
                    ),
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

          // 담은 상품이 있으면 하단 장바구니 바(배민식) — 네비바 위에 띄움
          if (cartCount > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 12,
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
          borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(14),
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Symbols.search,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 8),
              const Text('상품 검색', style: kSearchHintStyle),
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Symbols.paid,
              color: AppColors.textSecondary, size: 20, fill: 1),
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

/// 카테고리 가로 언더라인 탭. 선택 시 흰 볼드 + 라임 밑줄(찜한 상품과 동일 스타일).
class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
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
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 9),
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
        borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(14),
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
