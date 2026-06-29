import 'product.dart';

/// 장바구니 항목 — 상품 + 수량.
class CartItem {
  const CartItem({required this.product, required this.qty});

  final Product product;
  final int qty;

  int get linePoints => product.points * qty;

  CartItem copyWith({int? qty}) =>
      CartItem(product: product, qty: qty ?? this.qty);
}
