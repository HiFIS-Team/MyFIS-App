import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart_item.dart';
import '../domain/product.dart';

/// 장바구니 상태. 앱 전역에서 공유(상세에서 담고, 스토어 바/장바구니 화면에서 사용).
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// 같은 상품이면 수량 합산, 아니면 새 항목 추가.
  void add(Product product, int qty) {
    final idx = state.indexWhere((e) => e.product.name == product.name);
    if (idx >= 0) {
      final updated = [...state];
      updated[idx] = updated[idx].copyWith(qty: updated[idx].qty + qty);
      state = updated;
    } else {
      state = [...state, CartItem(product: product, qty: qty)];
    }
  }

  void setQty(int index, int qty) {
    if (qty < 1) return;
    final updated = [...state];
    updated[index] = updated[index].copyWith(qty: qty);
    state = updated;
  }

  void removeAt(int index) {
    state = [...state]..removeAt(index);
  }

  void clear() => state = const [];
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

/// 총 수량.
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (a, e) => a + e.qty),
);

/// 총 마일리지.
final cartTotalProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (a, e) => a + e.linePoints),
);
