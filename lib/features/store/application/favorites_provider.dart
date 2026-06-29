import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product.dart';
import 'product_catalog.dart';

/// 찜한 상품 상태(상품 이름 집합). 스토어 카드·상세 하트와 찜 목록이 공유.
class FavoritesNotifier extends Notifier<Set<String>> {
  // 데모용 초기 찜 (없으면 찜 목록이 비어 보임)
  @override
  Set<String> build() => {'프로틴 쉐이커', '이온음료'};

  void toggle(String name) {
    state = state.contains(name)
        ? ({...state}..remove(name))
        : {...state, name};
  }

  bool isFavorite(String name) => state.contains(name);
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// 찜한 상품 목록(카탈로그에서 필터).
final favoriteProductsProvider = Provider<List<Product>>((ref) {
  final favs = ref.watch(favoritesProvider);
  return kStoreProducts.where((p) => favs.contains(p.name)).toList();
});
