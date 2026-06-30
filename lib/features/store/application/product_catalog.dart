import 'package:material_symbols_icons/symbols.dart';

import '../domain/product.dart';

/// 스토어 카테고리 필터 목록. 맨 앞 '전체'는 필터 없음.
const List<String> kStoreCategories = [
  '전체',
  '음료',
  '보충제',
  '용품',
  '이용권',
];

/// 스토어 상품 카탈로그(더미). 스토어 그리드·검색에서 공용으로 사용.
const List<Product> kStoreProducts = [
  Product(
      icon: Symbols.exercise,
      name: '프로틴 쉐이커',
      category: '용품',
      points: 1000,
      views: 1240,
      rating: 4.8,
      stock: 12),
  Product(
      icon: Symbols.dry_cleaning,
      name: '운동 타월',
      category: '용품',
      points: 500,
      views: 860,
      rating: 4.5,
      stock: 3),
  Product(
      icon: Symbols.nutrition,
      name: '보충제 1회분',
      category: '보충제',
      points: 800,
      views: 2030,
      rating: 4.9,
      stock: 27),
  Product(
      icon: Symbols.local_drink,
      name: '이온음료',
      category: '음료',
      points: 300,
      views: 3120,
      rating: 4.6,
      stock: 48),
  Product(
      icon: Symbols.sports_gymnastics,
      name: 'PT 1회 체험',
      category: '이용권',
      points: 5000,
      views: 540,
      rating: 4.7,
      stock: 5),
  Product(
      icon: Symbols.lock,
      name: '락커 1개월',
      category: '이용권',
      points: 3000,
      views: 410,
      rating: 4.4,
      stock: 8),
];
