import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/product_catalog.dart';
import '../domain/product.dart';

/// 스토어 검색창 ↔ 검색 화면 검색 입력창을 잇는 Hero 태그.
const String kSearchHeroTag = 'store-search-bar';

/// 검색 힌트 공용 스타일 — 스토어 힌트·셔틀·검색 힌트를 통일해 모핑 시 글씨가 안 튀게.
const TextStyle kSearchHintStyle =
    TextStyle(color: AppColors.textSecondary, fontSize: 16);

/// Hero 비행 중 보여줄 깔끔한 검색바(아이콘 + "상품 검색"). 양쪽 공용.
Widget searchHeroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  return Material(
    type: MaterialType.transparency,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(Symbols.search, color: AppColors.textSecondary, size: 22),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                '상품 검색',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: kSearchHintStyle,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 상품 검색 화면.
/// 스토어 헤더 검색창·상품 상세 검색 아이콘에서 진입. 현재는 더미 카탈로그 필터.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // 진입 전환(Hero 비행 + 페이드)이 끝난 뒤에 포커스 → 키보드가 비행과 안 겹쳐
    // 첫 진입도 부드럽게. (autofocus는 비행 중 키보드를 띄워 첫 프레임이 끊김)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final anim = ModalRoute.of(context)?.animation;
      if (anim == null || anim.isCompleted) {
        _focus.requestFocus();
        return;
      }
      void onStatus(AnimationStatus s) {
        if (s == AnimationStatus.completed) {
          anim.removeStatusListener(onStatus);
          if (mounted) _focus.requestFocus();
        }
      }

      anim.addStatusListener(onStatus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final results = q.isEmpty
        ? kStoreProducts
        : kStoreProducts
            .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
            .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 헤더: 뒤로가기 + 검색창(Hero) — 스토어와 같은 Expanded-in-Row 레이아웃
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Hero(
                      tag: kSearchHeroTag,
                      flightShuttleBuilder: searchHeroShuttle,
                      child: Container(
                        height: 52,
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
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focus,
                                textInputAction: TextInputAction.search,
                                onChanged: (v) => setState(() => _query = v),
                                style: kSearchHintStyle.copyWith(
                                    color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: '상품 검색',
                                  hintStyle: kSearchHintStyle,
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                                child: const Icon(Symbols.cancel,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                    fill: 1),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        "'$q' 검색 결과가 없어요",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, i) =>
                          _ResultTile(product: results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Pressable(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.push('/product', extra: product),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(product.icon, color: AppColors.textSecondary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Symbols.paid, size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${_comma(product.points)}P',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Symbols.chevron_right,
                color: AppColors.textSecondary, size: 22),
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
