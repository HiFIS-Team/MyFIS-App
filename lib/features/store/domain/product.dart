import 'package:flutter/widgets.dart';

/// 마일리지 스토어 상품 모델. 현재는 더미 데이터용.
/// 추후 백엔드 연동 시 freezed 모델로 교체 예정.
class Product {
  const Product({
    required this.icon,
    required this.name,
    required this.category,
    required this.points,
    required this.views,
    required this.rating,
    required this.stock,
  });

  final IconData icon;
  final String name;
  final String category; // 분류(음료·보충제·용품·이용권 …)
  final int points;
  final int views; // 조회수(몇 명이 봤는지)
  final double rating; // 평점
  final int stock; // 남은 재고
}
