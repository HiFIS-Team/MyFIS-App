import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../application/cart_provider.dart';
import '../domain/product.dart';

/// 상품 상세 화면.
/// 스토어에서 상품 카드를 누르면 오른쪽→왼쪽 슬라이드로 진입(알림·바코드와 동일).
/// 현재는 더미 데이터.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _liked = false;

  // 수량 선택 시트를 열고, 담기(toCart) 또는 바로 교환을 처리한다.
  Future<void> _openSheet({required bool toCart}) async {
    final qty = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ExchangeSheet(product: widget.product, buyNow: !toCart),
    );
    if (qty == null || !mounted) return;

    if (toCart) {
      ref.read(cartProvider.notifier).add(widget.product, qty);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('장바구니에 $qty개 담았어요'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    } else {
      // 바로 교환 → 완료 화면
      context.push(
        '/exchange-complete',
        extra: (
          summary: '${widget.product.name} x$qty',
          totalPoints: widget.product.points * qty,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // 이미지를 헤더(상태바)까지 끌어올리고, 그 위에 버튼이 떠 있는 형태
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        // 맨 위에서 아래로 당겨도 바운스로 검은 배경이 보이지 않게(오버스크롤 차단)
        physics: const ClampingScrollPhysics(),
        children: [
          // 상품 이미지 — 헤더 뒤까지 꽉 찬 풀블리드 (토스 스타일). 현재는 placeholder.
          AspectRatio(
            aspectRatio: 1.25,
            child: Container(
              color: AppColors.lime.withValues(alpha: 0.10),
              alignment: Alignment.center,
              child: Icon(product.icon, color: AppColors.lime, size: 96),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                // 단가 (눈에 띄게 라임 큰 숫자)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Symbols.paid, size: 24, color: AppColors.lime),
                    const SizedBox(width: 6),
                    Text(
                      '${_comma(product.points)}P',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.lime,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 조회수 + 평점
                Row(
                  children: [
                    Icon(Symbols.visibility,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${_comma(product.views)}명이 봤어요',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Symbols.star,
                        size: 18, color: AppColors.lime, fill: 1),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 상품 정보 칩
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                        icon: Symbols.local_fire_department,
                        label: '인기',
                        accent: true),
                    _InfoChip(label: '재고 12개'),
                    _InfoChip(label: '운동용품'),
                  ],
                ),

                const _SectionDivider(),
                // 상품 설명
                _SectionTitle('상품 설명'),
                const SizedBox(height: 10),
                Text(
                  '마일리지로 교환할 수 있는 상품이에요. 자세한 상품 설명은 추후 추가될 예정입니다.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const _SectionDivider(),
                // 교환 안내·유의사항
                _SectionTitle('교환 안내'),
                const SizedBox(height: 14),
                const _NoticeList(items: [
                  '교환 후 프론트에서 수령할 수 있어요.',
                  '음료·이온음료는 즉시 차감 후 제공돼요.',
                  '교환 취소는 수령 전 24시간 내에만 가능해요.',
                ]),

                const _SectionDivider(),
                // 리뷰
                _SectionTitle('리뷰'),
                const SizedBox(height: 16),
                _ReviewSummary(rating: product.rating),
                const SizedBox(height: 20),
                const _ReviewCard(
                  name: '김О О',
                  rating: 5,
                  date: '3일 전',
                  body: '재질 좋고 그립감이 좋아요. 물도 안 새서 만족합니다.',
                ),
                const SizedBox(height: 12),
                const _ReviewCard(
                  name: '이О О',
                  rating: 4,
                  date: '1주 전',
                  body: '가성비 좋아요. 마일리지로 바꾸기 딱 좋은 상품!',
                ),

                const _SectionDivider(),
              ],
            ),
          ),
          // 함께 교환하면 좋은 상품 — 풀블리드 가로 스크롤
          const _RelatedSection(),
          const SizedBox(height: 28),
        ],
      ),
      // 하단 고정 바: [하트] [채팅] [교환하기]
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Row(
          children: [
            // 좋아요(하트)
            _SideButton(
              icon: Symbols.favorite,
              fill: _liked,
              color: _liked ? const Color(0xFFFF6B6B) : null,
              onTap: () => setState(() => _liked = !_liked),
            ),
            const SizedBox(width: 8),
            // 채팅(문의)
            _SideButton(
              icon: Symbols.chat_bubble,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            // 장바구니 담기 (보조)
            Expanded(
              child: FilledButton(
                onPressed: () => _openSheet(toCart: true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceAlt,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '장바구니',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 바로 교환하기 (주요)
            Expanded(
              child: FilledButton(
                onPressed: () => _openSheet(toCart: false),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '교환하기',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
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

/// 교환 수량 선택 시트 (아래에서 올라옴).
/// buyNow=true면 바로 교환(버튼에 가격 표시), false면 장바구니 담기.
class _ExchangeSheet extends StatefulWidget {
  const _ExchangeSheet({required this.product, required this.buyNow});
  final Product product;
  final bool buyNow;

  @override
  State<_ExchangeSheet> createState() => _ExchangeSheetState();
}

class _ExchangeSheetState extends State<_ExchangeSheet> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textTheme = Theme.of(context).textTheme;
    final total = product.points * _qty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 그래버
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              product.name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Symbols.paid, size: 16, color: AppColors.lime),
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
            const SizedBox(height: 24),
            // 수량 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '수량',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _StepButton(
                        icon: Symbols.remove,
                        onTap: _qty > 1
                            ? () => setState(() => _qty--)
                            : null,
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '$_qty',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StepButton(
                        icon: Symbols.add,
                        onTap: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.outline),
            const SizedBox(height: 18),
            // 합계
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '총 교환 마일리지',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Symbols.paid, size: 22, color: AppColors.lime),
                    const SizedBox(width: 5),
                    Text(
                      '${_comma(total)}P',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              // 선택 수량을 반환하며 시트 닫기 → 상세에서 카트에 담음
              onPressed: () => Navigator.of(context).pop(_qty),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.buyNow ? Symbols.paid : Symbols.add_shopping_cart,
                    size: 20,
                    color: Colors.black,
                    fill: widget.buyNow ? 1 : 0,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.buyNow
                        ? '${_comma(total)}P 교환하기'
                        : '장바구니에 담기',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
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

/// 수량 증감 버튼.
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.textPrimary : AppColors.outline,
        ),
      ),
    );
  }
}

/// 하단 바 좌측의 정사각 보조 버튼(하트·채팅).
class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.onTap,
    this.fill = false,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool fill;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 24,
          fill: fill ? 1 : 0,
          color: color ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// 섹션 제목 (굵게).
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

/// 섹션 사이 구분선 (위아래 여백 포함).
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 24),
      color: AppColors.outline,
    );
  }
}

/// 상품 정보 칩 (인기·재고·카테고리 등).
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.icon, this.accent = false});

  final String label;
  final IconData? icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final fg = accent ? AppColors.limeStrong : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.lime.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg, fill: accent ? 1 : 0),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// 교환 안내 불릿 리스트.
class _NoticeList extends StatelessWidget {
  const _NoticeList({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          height: 1.45,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 8),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(child: Text(item, style: style)),
              ],
            ),
          ),
      ],
    );
  }
}

/// 리뷰 요약 (큰 평점 + 별점 분포 막대).
class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.rating});
  final double rating;

  // 더미 분포 (5★ → 1★)
  static const List<int> _dist = [112, 12, 3, 1, 0];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = _dist.fold<int>(0, (a, b) => a + b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => Icon(
                  Symbols.star,
                  size: 14,
                  fill: i < rating.round() ? 1 : 0,
                  color: AppColors.lime,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$total개',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '${5 - i}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Stack(
                            children: [
                              Container(height: 6, color: AppColors.surfaceAlt),
                              FractionallySizedBox(
                                widthFactor:
                                    total == 0 ? 0 : _dist[i] / total,
                                child: Container(
                                  height: 6,
                                  color: AppColors.lime,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 리뷰 카드.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.date,
    required this.body,
  });

  final String name;
  final int rating;
  final String date;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    Symbols.star,
                    size: 13,
                    fill: i < rating ? 1 : 0,
                    color: AppColors.lime,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// 함께 교환하면 좋은 상품 — 풀블리드 가로 스크롤.
class _RelatedSection extends StatelessWidget {
  const _RelatedSection();

  static const List<({IconData icon, String name, int points})> _items = [
    (icon: Symbols.dry_cleaning, name: '운동 타월', points: 500),
    (icon: Symbols.nutrition, name: '보충제 1회분', points: 800),
    (icon: Symbols.local_drink, name: '이온음료', points: 300),
    (icon: Symbols.lock, name: '락커 1개월', points: 3000),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionTitle('함께 교환하면 좋은 상품'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final item = _items[i];
              return SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item.icon, color: AppColors.lime, size: 36),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Symbols.paid,
                            size: 14, color: AppColors.lime),
                        const SizedBox(width: 3),
                        Text(
                          '${_comma(item.points)}P',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.lime,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
