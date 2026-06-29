import 'package:flutter/widgets.dart';

/// 마일리지 스토어 상품 모델. 현재는 더미 데이터용.
/// 추후 백엔드 연동 시 freezed 모델로 교체 예정.
class Product {
  const Product({
    required this.icon,
    required this.name,
    required this.points,
    required this.views,
    required this.rating,
  });

  final IconData icon;
  final String name;
  final int points;
  final int views; // 조회수(몇 명이 봤는지)
  final double rating; // 평점
}
