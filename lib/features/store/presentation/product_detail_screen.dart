import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
          ),
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
            // 교환하기 (남은 폭 채움)
            Expanded(
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
                    const Icon(Symbols.paid, size: 20, color: Colors.black),
                    const SizedBox(width: 6),
                    Text(
                      '${_comma(product.points)}P로 교환하기',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
