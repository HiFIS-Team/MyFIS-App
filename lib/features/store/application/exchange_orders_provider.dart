import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart_item.dart';
import '../domain/exchange_order.dart';

/// 교환권 목록 상태. 교환(체크아웃) 시 장바구니 항목만큼 카드가 쌓인다.
class ExchangeOrdersNotifier extends Notifier<List<ExchangeOrder>> {
  // 데모용 초기 더미 1건(없으면 핸들이 안 보임)
  @override
  List<ExchangeOrder> build() => const [
        ExchangeOrder(
            name: '이온음료', number: 'B7K10', qty: 1, date: '6/27', done: true),
      ];

  /// 장바구니 항목들을 교환권으로 추가(최신이 앞).
  void addFromCart(List<CartItem> items) {
    final now = DateTime.now();
    final date = '${now.month}/${now.day}';
    final created = [
      for (final item in items)
        ExchangeOrder(
          name: item.product.name,
          qty: item.qty,
          number: _genCode(),
          date: date,
          done: false,
        ),
    ];
    state = [...created, ...state];
  }

  String _genCode() {
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    final r = Random();
    final l =
        List.generate(2, (_) => letters[r.nextInt(letters.length)]).join();
    final d = (r.nextInt(900) + 100).toString();
    return '$l$d'; // 예: AB123
  }
}

final exchangeOrdersProvider =
    NotifierProvider<ExchangeOrdersNotifier, List<ExchangeOrder>>(
        ExchangeOrdersNotifier.new);
