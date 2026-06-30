import '../domain/coupon.dart';

/// 보유 쿠폰 더미 목록. 쿠폰함·교환 쿠폰 선택에서 공용으로 사용.
const List<Coupon> kCoupons = [
  // 멤버십 (교환에는 사용 불가)
  Coupon(
    value: '10%',
    name: '멤버십 결제 할인',
    condition: '3개월권 이상',
    expiry: '2026.07.31',
    kind: CouponKind.membership,
  ),
  Coupon(
    value: '20,000원',
    name: '6개월권 재등록 할인',
    expiry: '2026.08.15',
    kind: CouponKind.membership,
  ),
  Coupon(
    value: '1개월',
    name: '락커 무료 이용권',
    condition: '멤버십 등록 회원',
    expiry: '2026.07.15',
    kind: CouponKind.membership,
  ),
  // 스토어 (교환 시 할인 적용)
  Coupon(
    value: '2,000P',
    name: '스토어 교환 할인',
    condition: '3,000P 이상 사용 시',
    expiry: '2026.07.10',
    kind: CouponKind.store,
    amountOff: 2000,
  ),
  Coupon(
    value: '50%',
    name: '음료 교환 할인',
    expiry: '2026.06.30',
    kind: CouponKind.store,
    percentOff: 50,
  ),
  Coupon(
    value: '1,000P',
    name: '신규 교환 적립',
    expiry: '2026.07.20',
    kind: CouponKind.store,
  ),
];
