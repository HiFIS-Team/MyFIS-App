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
    this.percentOff = 0,
    this.amountOff = 0,
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

  /// 교환(마일리지)에 적용되는 할인. 퍼센트(%) 또는 정액(P).
  /// 둘 다 0이면 교환 할인 불가(예: 적립형·멤버십 전용).
  final int percentOff; // 0~100
  final int amountOff; // P

  /// 스토어 교환 시 쓸 수 있는 할인 쿠폰인지.
  bool get usableForExchange =>
      kind == CouponKind.store && (percentOff > 0 || amountOff > 0);

  /// 주어진 마일리지 합계에 대한 할인 포인트(합계를 넘지 않음).
  int discountFor(int total) {
    final d = percentOff > 0 ? (total * percentOff / 100).round() : amountOff;
    return d > total ? total : d;
  }
}
