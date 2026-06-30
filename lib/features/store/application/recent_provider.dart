import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product.dart';
import 'product_catalog.dart';

/// 최근 본 상품 목록(최신이 앞). 상품 상세를 열면 기록된다.
class RecentNotifier extends Notifier<List<Product>> {
  static const int _max = 20;

  // 데모용 초기 시드
  @override
  List<Product> build() => [
        kStoreProducts[2], // 보충제 1회분
        kStoreProducts[1], // 운동 타월
        kStoreProducts[4], // PT 1회 체험
      ];

  void add(Product p) {
    final list = [p, ...state.where((e) => e.name != p.name)];
    state = list.length > _max ? list.sublist(0, _max) : list;
  }
}

final recentProvider =
    NotifierProvider<RecentNotifier, List<Product>>(RecentNotifier.new);
