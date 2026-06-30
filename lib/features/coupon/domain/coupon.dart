/// 쿠폰 분류 — 마이페이지 쿠폰함 탭(멤버십 / 스토어).
enum CouponKind { membership, store }

/// 보유 쿠폰. 현재는 더미 데이터.
class Coupon {
  const Coupon({
    required this.value,
    required this.name,
    required this.expiry,
    required this.kind,
    this.condition,
  });

  /// 크게 보여줄 할인값 표시 문자열 — 예: '10%', '2,000P', '20,000원'.
  final String value;

  /// 쿠폰 이름 — 예: '멤버십 결제 할인'.
  final String name;

  /// 사용 조건(없으면 null) — 예: '3개월권 이상', '3,000P 이상 사용 시'.
  final String? condition;

  /// 만료일 표시 — 예: '2026.07.31'.
  final String expiry;

  final CouponKind kind;
}
